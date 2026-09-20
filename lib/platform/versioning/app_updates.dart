import '../sync/sync_service.dart';
import 'version_gate.dart';

/// The version gate, assembled from whatever this device can actually reach.
///
/// Three sources, each answering a different question:
///
/// - **GitHub** — what has been *released*. Needs no account, so it answers on
///   a device that has never connected Drive.
/// - **`app.json`** — what the fleet has been told, written by the release
///   pipeline and by any app that finds itself newer.
/// - **the peers' own `device.json`** — what is actually *installed* around
///   here. This is the one that cannot be stale or forgotten, because a device
///   writes it every time it syncs.
///
/// None of them answering is a normal outcome, not an error.
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
    // the account is known, misses app.json — the only source with a floor —
    // and silently degrades to "GitHub said there is a newer tag".
    await _sync.restore();

    final store = await _sync.remoteStore();
    final drive = store == null ? null : DriveAppConfig(store);

    return VersionGate(
      sources: [
        _github,
        if (store != null) PeerVersions(store, deviceId: _sync.deviceId),
        if (drive != null) drive,
      ],
      publishTo: drive,
      // Everything this device knows goes out while it still can.
      onBlocked: () => _sync.syncNow(),
    ).check();
  }
}
