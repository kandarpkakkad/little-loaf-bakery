import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/platform/sync/remote_store.dart';
import 'package:little_loaf/platform/versioning/version.dart';
import 'package:little_loaf/platform/versioning/version_gate.dart';

/// Letting devices run different versions, and stopping the ones that cannot.
/// docs/01-platform/versioning/lld.md §6
void main() {
  late Directory cache;

  setUp(() async {
    cache = await Directory.systemTemp.createTemp('loaf-version');
  });

  tearDown(() async {
    if (cache.existsSync()) await cache.delete(recursive: true);
  });

  VersionGate gate(
    List<ReleaseSource> sources, {
    String app = '0.2.0',
    String minSupported = '0.1.0',
    DriveAppConfig? publish,
    Future<void> Function()? onBlocked,
  }) =>
      VersionGate(
        sources: sources,
        publishTo: publish,
        onBlocked: onBlocked,
        cacheDir: cache,
        appVersion: app,
        minSupported: minSupported,
      );

  group('comparing versions', () {
    test('orders by each part in turn', () {
      expect(isOlder('0.1.9', '0.2.0'), isTrue);
      expect(isOlder('0.2.0', '0.10.0'), isTrue,
          reason: '10 is a number, not a character');
      expect(isOlder('1.0.0', '0.9.9'), isFalse);
    });

    test('a tag and a version are the same thing', () {
      expect(compareVersions('v0.1.1', '0.1.1'), 0);
      expect(compareVersions('0.1', '0.1.0'), 0);
      expect(compareVersions('v0.2.0+7', '0.2.0'), 0,
          reason: 'the build number does not change the ordering');
    });

    test('nonsense sorts as zero rather than throwing', () {
      expect(compareVersions('', '0.0.0'), 0);
      expect(isOlder('not a version', '0.1.0'), isTrue);
    });
  });

  group('the verdict', () {
    test('up to date is silent', () async {
      final r = await gate([_Source(const ReleaseInfo(latest: '0.2.0'))]).check();
      expect(r.verdict, GateVerdict.ok);
    });

    test('behind the newest release is a banner, not a block', () async {
      final r = await gate([
        _Source(const ReleaseInfo(latest: 'v0.3.0', minSupported: '0.1.0'))
      ]).check();
      expect(r.verdict, GateVerdict.updateAvailable);
      expect(r.info!.latest, 'v0.3.0');
    });

    test('below the floor blocks', () async {
      final r = await gate([
        _Source(const ReleaseInfo(latest: '0.4.0', minSupported: '0.3.0'))
      ]).check();
      expect(r.verdict, GateVerdict.blocked);
    });

    test('the outbox is flushed before the block is shown', () async {
      final order = <String>[];
      final r = await gate(
        [_Source(const ReleaseInfo(latest: '0.4.0', minSupported: '0.3.0'))],
        onBlocked: () async => order.add('flushed'),
      ).check();

      order.add('blocked');
      expect(r.blocks, isTrue);
      expect(order, ['flushed', 'blocked'],
          reason: 'a device about to be locked out still has work only it '
              'knows about');
    });

    test('a release with no floor never blocks', () async {
      // GitHub alone — a release has nowhere to carry min_supported.
      final r =
          await gate([_Source(const ReleaseInfo(latest: '9.9.9'))]).check();
      expect(r.verdict, GateVerdict.updateAvailable);
    });
  });

  group('when nothing answers', () {
    test('no source at all carries on', () async {
      final r = await gate([_Source(null), _Source(null)]).check();
      expect(r.verdict, GateVerdict.ok);
    });

    test('the last answer still stands on the next launch', () async {
      await gate([
        _Source(const ReleaseInfo(latest: '0.4.0', minSupported: '0.3.0'))
      ]).check();

      // offline now, and still too old
      final r = await gate([_Source(null)]).check();
      expect(r.verdict, GateVerdict.blocked,
          reason: 'a device told to upgrade stays told, even on a tunnel');
    });

    test('a malformed app.json is no answer, not a bad one', () async {
      final store = _ConfigStore('{"latest_version": 12345}'); // not a string
      final r = await gate([DriveAppConfig(store)]).check();
      expect(r.verdict, GateVerdict.ok);
    });

    test('an empty file is no answer either', () async {
      final r = await gate([DriveAppConfig(_ConfigStore(''))]).check();
      expect(r.verdict, GateVerdict.ok);
    });
  });

  group('two sources', () {
    test('the newer release wins, and the floor is kept', () async {
      final r = await gate([
        _Source(const ReleaseInfo(latest: 'v0.5.0', apkUrl: 'https://gh/apk')),
        _Source(const ReleaseInfo(latest: '0.3.0', minSupported: '0.1.0')),
      ]).check();

      expect(r.verdict, GateVerdict.updateAvailable);
      expect(r.info!.latest, 'v0.5.0', reason: 'GitHub had the newer tag');
      expect(r.info!.minSupported, '0.1.0',
          reason: 'only app.json carries a floor, and it must survive');
      expect(r.info!.apkUrl, 'https://gh/apk');
    });

    test('the stricter floor wins when both name one', () async {
      final r = await gate([
        _Source(const ReleaseInfo(latest: '0.4.0', minSupported: '0.1.0')),
        _Source(const ReleaseInfo(latest: '0.4.0', minSupported: '0.3.0')),
      ]).check();
      expect(r.blocks, isTrue);
    });

    test('one source down does not lose the other', () async {
      final r = await gate([
        _Source(null),
        _Source(const ReleaseInfo(latest: '0.4.0', minSupported: '0.1.0')),
      ]).check();
      expect(r.verdict, GateVerdict.updateAvailable);
    });
  });

  group('publishing', () {
    test('a build newer than anything known announces itself', () async {
      final store = _ConfigStore(
          jsonEncode(const ReleaseInfo(latest: '0.1.0').toJson()));
      final drive = DriveAppConfig(store);

      final r = await gate(
        [drive],
        app: '0.2.0',
        minSupported: '0.1.5',
        publish: drive,
      ).check();

      expect(r.verdict, GateVerdict.ok);
      final written =
          jsonDecode(store.text!) as Map<String, Object?>;
      expect(written['latest_version'], '0.2.0');
      expect(written['min_supported_version'], '0.1.5');
    });

    test('the very first install creates app.json', () async {
      // Nothing has ever written it, and on a private repo GitHub never
      // answers either — so no source knows anything. This is the first
      // launch of the first device, and it has to be the one that says what
      // the fleet is on. Otherwise app.json is never created, never answers,
      // and therefore never gets created: a closed loop with no floor in it.
      final store = _ConfigStore(null);
      final drive = DriveAppConfig(store);

      final r = await gate(
        [_Source(null), drive],
        app: '0.1.3',
        minSupported: '0.1.0',
        publish: drive,
      ).check();

      expect(r.verdict, GateVerdict.ok);
      expect(store.text, isNotNull,
          reason: 'somebody has to go first');
      final written = jsonDecode(store.text!) as Map<String, Object?>;
      expect(written['latest_version'], '0.1.3');
      expect(written['min_supported_version'], '0.1.0');
    });

    test('with nowhere to publish it simply carries on', () async {
      final r = await gate([_Source(null)], app: '0.1.3').check();
      expect(r.verdict, GateVerdict.ok,
          reason: 'Drive not connected is not a reason to stop');
    });

    test('a build that is merely current writes nothing', () async {
      final store = _ConfigStore(
          jsonEncode(const ReleaseInfo(latest: '0.2.0').toJson()));
      final before = store.writes;

      await gate([DriveAppConfig(store)],
              app: '0.2.0', publish: DriveAppConfig(store))
          .check();
      expect(store.writes, before);
    });
  });

  test('the constants match pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final line = RegExp(r'^version:\s*(.+)$', multiLine: true)
        .firstMatch(pubspec)!
        .group(1)!
        .trim();
    final [version, build] = line.split('+');

    expect(kAppVersion, version,
        reason: 'the gate compares against this, so it cannot drift');
    expect(kAppBuild, int.parse(build));
    expect(compareVersions(kMinSupported, kAppVersion), lessThanOrEqualTo(0),
        reason: 'a build that does not support itself blocks every device');
  });
}

class _Source implements ReleaseSource {
  _Source(this.info);
  final ReleaseInfo? info;

  @override
  Future<ReleaseInfo?> read() async => info;
}

/// Only the two app.json methods matter here; the rest of RemoteStore is a
/// different story with its own tests.
class _ConfigStore implements RemoteStore {
  _ConfigStore(this.text);

  String? text;
  int writes = 0;

  @override
  Future<String?> readAppConfig() async => text;

  @override
  Future<void> writeAppConfig(String json) async {
    writes++;
    text = json;
  }

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}
