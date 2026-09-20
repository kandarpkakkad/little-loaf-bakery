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
    Future<void> Function()? onBlocked,
  }) =>
      VersionGate(
        sources: sources,
        onBlocked: onBlocked,
        cacheDir: cache,
        appVersion: app,
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

    test('a source that cannot parse what it read says nothing', () async {
      // ReleaseInfo.fromJson returns null rather than throwing on anything it
      // does not recognise, and null is "no answer".
      expect(ReleaseInfo.fromJson({'latest_version': 12345}), isNull,
          reason: 'a number is not a version');
      expect(ReleaseInfo.fromJson({'latest_version': ''}), isNull);
      expect(ReleaseInfo.fromJson(const {}), isNull);

      final r = await gate([_Source(null)]).check();
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
          reason: 'only the peers carry a floor, and it must survive');
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

  group('what the other devices are running', () {
    InMemoryRemoteStore withPeers(Map<String, Map<String, Object?>> peers) {
      final store = InMemoryRemoteStore();
      peers.forEach((id, meta) => store.meta[id] = jsonEncode({
            'device_id': id,
            'last_seen_at': 0,
            'cursors': <String, int>{},
            ...meta,
          }));
      return store;
    }

    test('reports the newest version anyone is on', () async {
      final store = withPeers({
        'phone': {'app_version': '0.1.2'},
        'tablet': {'app_version': '0.1.9'},
        'counter': {'app_version': '0.1.4'},
      });

      final info = await PeerVersions(store, deviceId: 'me').read();
      expect(info!.latest, '0.1.9');
    });

    test('this device does not count as a peer', () async {
      final store = withPeers({
        'me': {'app_version': '9.9.9'},
        'phone': {'app_version': '0.1.2'},
      });

      final info = await PeerVersions(store, deviceId: 'me').read();
      expect(info!.latest, '0.1.2',
          reason: 'asking yourself what version you are is not an answer');
    });

    test('the strictest floor any peer asks for wins', () async {
      final store = withPeers({
        'phone': {'app_version': '0.2.0', 'min_supported': '0.2.0'},
        'tablet': {'app_version': '0.1.1', 'min_supported': '0.1.0'},
      });

      final info = await PeerVersions(store, deviceId: 'me').read();
      expect(info!.minSupported, '0.2.0',
          reason: 'a newer build propagates its requirement by syncing once');
    });

    test('a fleet of one has nothing to say', () async {
      final store = withPeers({'me': {'app_version': '0.1.2'}});
      expect(await PeerVersions(store, deviceId: 'me').read(), isNull);
    });

    test('peers from before versions were published are skipped', () async {
      final store = withPeers({'old': <String, Object?>{}});
      expect(await PeerVersions(store, deviceId: 'me').read(), isNull,
          reason: 'an older build writes no version, and silence is not zero');
    });

    test('a peer on a newer build blocks one below its floor', () async {
      final store = withPeers({
        'tablet': {'app_version': '0.3.0', 'min_supported': '0.3.0'},
      });

      final r = await gate([PeerVersions(store, deviceId: 'me')],
              app: '0.2.0')
          .check();
      expect(r.blocks, isTrue);
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
