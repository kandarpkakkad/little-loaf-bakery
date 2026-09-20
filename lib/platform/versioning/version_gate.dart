import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../sync/remote_store.dart';
import 'version.dart';

/// What the newest release is, and the oldest one still allowed.
class ReleaseInfo {
  const ReleaseInfo({
    required this.latest,
    this.minSupported,
    this.apkUrl,
    this.publishedAt,
  });

  final String latest;

  /// Only the peers carry this — a GitHub release has no field for it — so it
  /// is null whenever GitHub is the only source that answered.
  final String? minSupported;

  final String? apkUrl;
  final String? publishedAt;

  Map<String, Object?> toJson() => {
        'latest_version': latest,
        'min_supported_version': minSupported,
        'apk_url': apkUrl,
        'published_at': publishedAt,
      };

  static ReleaseInfo? fromJson(Map<String, Object?> j) {
    final latest = j['latest_version'];
    if (latest is! String || latest.isEmpty) return null;
    return ReleaseInfo(
      latest: latest,
      minSupported: j['min_supported_version'] as String?,
      apkUrl: j['apk_url'] as String?,
      publishedAt: j['published_at'] as String?,
    );
  }

  /// The stricter of two answers: the newer `latest`, and whichever
  /// `min_supported` either source knows about.
  ReleaseInfo mergedWith(ReleaseInfo? other) {
    if (other == null) return this;
    final newer = isOlder(latest, other.latest) ? other : this;
    final floor = [minSupported, other.minSupported].nonNulls.toList()
      ..sort(compareVersions);
    return ReleaseInfo(
      latest: newer.latest,
      minSupported: floor.isEmpty ? null : floor.last,
      apkUrl: newer.apkUrl ?? apkUrl ?? other.apkUrl,
      publishedAt: newer.publishedAt,
    );
  }
}

enum GateVerdict {
  /// Up to date, or no answer at all. The common case, and the safe one.
  ok,

  /// Newer build exists. A banner, dismissible.
  updateAvailable,

  /// Too old to be trusted with the shared data. Nothing else opens.
  blocked,
}

class GateResult {
  const GateResult(this.verdict, [this.info]);

  final GateVerdict verdict;
  final ReleaseInfo? info;

  bool get blocks => verdict == GateVerdict.blocked;
}

/// Somewhere that knows what the newest release is.
abstract class ReleaseSource {
  /// Null means "did not answer" — offline, 404, malformed. Never an error:
  /// an unreadable source must never block the app.
  Future<ReleaseInfo?> read();
}

/// The GitHub release the tag-driven pipeline publishes.
///
/// Answers with the tag name and the arm64 APK, and never with a floor — a
/// GitHub release has nowhere to put one. That number comes from the peers,
/// which is why the gate reads both.
class GitHubReleases implements ReleaseSource {
  GitHubReleases({http.Client? client, this.url = kReleasesApi})
      : _client = client ?? http.Client();

  final http.Client _client;
  final String url;

  @override
  Future<ReleaseInfo?> read() async {
    try {
      final res = await _client
          .get(Uri.parse(url), headers: {'Accept': 'application/vnd.github+json'})
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;

      final body = jsonDecode(res.body) as Map<String, Object?>;
      final tag = body['tag_name'];
      if (tag is! String || tag.isEmpty) return null;

      String? apk;
      for (final a in (body['assets'] as List? ?? const [])) {
        final name = '${(a as Map)['name']}';
        // arm64 is every phone made this decade; the arm32 build exists for
        // one old tablet and is not what an update prompt should hand out.
        if (name.endsWith('.apk') && name.contains('arm64')) {
          apk = a['browser_download_url'] as String?;
          break;
        }
      }

      return ReleaseInfo(
        latest: tag,
        apkUrl: apk ?? kReleasesPage,
        publishedAt: body['published_at'] as String?,
      );
    } on Exception {
      return null;
    }
  }
}

/// What the other devices in this bakery are running.
///
/// Every device publishes its version in its own `device.json` on every sync,
/// so this needs no new file and no extra write. It answers a question neither
/// other source can: not "what has been released" but "what is actually
/// installed around here" — which is what decides whether this build can still
/// talk to the others.
///
/// The floor it reports is the strictest any peer asks for. A newer build
/// carrying a higher `kMinSupported` therefore propagates its requirement
/// simply by syncing once.
class PeerVersions implements ReleaseSource {
  PeerVersions(this.store, {required this.deviceId});

  final RemoteStore store;
  final String deviceId;

  @override
  Future<ReleaseInfo?> read() async {
    try {
      String? newest;
      String? floor;

      for (final peer in await store.listDevices()) {
        if (peer == deviceId) continue;
        final text = await store.readDeviceMeta(peer);
        if (text == null) continue;
        final meta = jsonDecode(text) as Map<String, Object?>;

        final version = meta['app_version'];
        if (version is String && version.isNotEmpty) {
          if (newest == null || isOlder(newest, version)) newest = version;
        }
        final min = meta['min_supported'];
        if (min is String && min.isNotEmpty) {
          if (floor == null || isOlder(floor, min)) floor = min;
        }
      }

      if (newest == null && floor == null) return null;
      return ReleaseInfo(
        // A floor with no version attached still has to travel, and `latest`
        // is required. Reporting the floor as the latest would be a lie that
        // triggers an update banner, so it reports the floor as itself.
        latest: newest ?? floor!,
        minSupported: floor,
      );
    } on Exception {
      return null;
    }
  }
}

/// Whether this build may still run.
///
/// Reads both sources, because they answer different questions: GitHub knows
/// what has been released, the peers know what is actually installed and the
/// oldest build any of them will still talk to. Either may be unreachable, and
/// **unreadable never blocks** — an offline-first app that locks you out because Drive hiccuped
/// has got its priorities backwards.
/// docs/01-platform/versioning/lld.md §2
class VersionGate {
  VersionGate({
    required this.sources,
    this.onBlocked,
    Directory? cacheDir,
    String appVersion = kAppVersion,
  })  : _cacheDir = cacheDir,
        _appVersion = appVersion;

  final List<ReleaseSource> sources;

  /// Called before the block screen appears, to flush the outbox. A device
  /// about to be locked out still has work only it knows about.
  final Future<void> Function()? onBlocked;

  final Directory? _cacheDir;
  final String _appVersion;

  Future<GateResult> check() async {
    ReleaseInfo? known;
    var answered = false;
    for (final s in sources) {
      final one = await s.read();
      if (one == null) continue;
      answered = true;
      known = known == null ? one : known.mergedWith(one);
    }

    if (answered) {
      await _cache(known!);
    } else {
      // Nothing answered. The last thing we were told still stands: a device
      // that has been told to upgrade should stay told, even on a tunnel.
      known = await _cached();
    }
    // Nothing known, or this build is ahead of everything known. Either way
    // there is nothing to tell anyone: no file is written, because the only
    // thing that announces a version now is a device publishing its own
    // device.json, which the sync engine already does on every run.
    if (known == null || isOlder(known.latest, _appVersion)) {
      return const GateResult(GateVerdict.ok);
    }

    final floor = known.minSupported;
    if (floor != null && isOlder(_appVersion, floor)) {
      // Before the block, not after: everything this device knows goes out
      // while it still can.
      await onBlocked?.call();
      return GateResult(GateVerdict.blocked, known);
    }

    if (isOlder(_appVersion, known.latest)) {
      return GateResult(GateVerdict.updateAvailable, known);
    }
    return GateResult(GateVerdict.ok, known);
  }

  // The cache is a file rather than a settings column: it is per install, not
  // per bakery, and it must not be replicated — a restored snapshot carrying
  // someone else's idea of the newest version would be noise at best.
  Future<File> _file() async =>
      File(p.join((_cacheDir ?? await getApplicationDocumentsDirectory()).path,
          'release.json'));

  Future<void> _cache(ReleaseInfo info) async {
    try {
      await (await _file()).writeAsString(jsonEncode(info.toJson()));
    } on Exception {
      // A cache that cannot be written is not worth failing a launch over.
    }
  }

  Future<ReleaseInfo?> _cached() async {
    try {
      final f = await _file();
      if (!f.existsSync()) return null;
      return ReleaseInfo.fromJson(
          jsonDecode(await f.readAsString()) as Map<String, Object?>);
    } on Exception {
      return null;
    }
  }
}
