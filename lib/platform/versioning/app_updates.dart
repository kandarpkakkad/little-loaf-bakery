import '../sync/sync_service.dart';
import 'version_gate.dart';

/// The version gate, assembled from whatever this device can actually reach.
///
/// Two sources, each answering a different question:
///
/// - **GitHub** — what has been *released*. Needs no account, so it answers on
///   a device that has never connected Drive, and it answers the moment CI
///   publishes.
/// - **the peers' own `device.json`** — what is actually *installed* around
///   here, and the strictest floor any of them asks for. It cannot go stale,
///   because a device rewrites it every time it syncs.
///
/// There is deliberately no third source announcing a floor from CI. A floor
/// written by the pipeline takes effect before any device has upgraded, so
/// raising it would block every device at once over an incompatibility that
/// has not happened yet — the bakery locked out of its own order book until
/// each device is updated by hand. A floor carried by the peers rises only as
/// devices actually move, which is when the incompatibility becomes real.
///
/// Neither answering is a normal outcome, not an error.
class AppUpdates {
  AppUpdates(this._sync, {ReleaseSource? github})
      : _github = github ?? GitHubReleases();

  final SyncService _sync;
  final ReleaseSource _github;

  /// Checked once per launch. Not on resume: a version does not change while
  /// the app is in the background, and a block that appears mid-order would
  /// be the app taking work away rather than protecting it.
  Future<GateResult> check() async {
    // The shell does this too, and it is idempotent: it reads the remembered
    // account from storage and never prompts. Without it the gate runs before
    // the account is known, misses the peers — the only source with a floor —
    // and silently degrades to "GitHub said there is a newer tag".
    await _sync.restore();

    final store = await _sync.remoteStore();

    return VersionGate(
      sources: [
        _github,
        if (store != null) PeerVersions(store, deviceId: _sync.deviceId),
      ],
      // Everything this device knows goes out while it still can.
      onBlocked: () => _sync.syncNow(),
    ).check();
  }
}
