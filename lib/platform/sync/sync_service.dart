import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../backup/restore.dart';
import 'remote_store.dart';
import '../backup/snapshot.dart';
import '../storage/database.dart';
import 'drive_auth.dart';
import 'drive_store.dart';
import 'mutations.dart';
import 'sync_engine.dart';

/// What a backup run did, both halves of it.
///
/// A snapshot is only worth what the database held when it was taken, so every
/// backup pulls first. [sync] is null when there was nothing to pull through
/// (no account, no network), and carries the report otherwise — including a
/// failed one, because the snapshot is taken anyway and the difference is
/// worth saying out loud.
class BackupRun {
  const BackupRun({required this.snapshot, this.sync});

  final SnapshotResult snapshot;
  final SyncReport? sync;

  /// True when the database really was up to date first.
  bool get freshData => sync?.ok ?? false;

  /// Reached Drive to back up, but could not read a peer on the way.
  bool get mayBeBehind => !freshData && snapshot.outcome == SnapshotOutcome.uploaded;
}

/// Why sync is not running, when it is not.
enum SyncBlocker {
  /// Nobody has connected a Google account on this device.
  notConnected,

  /// The grant went away — revoked, expired, or the project is still in
  /// Testing, where Google expires refresh tokens after seven days.
  needsReconnect,
}

class SyncStatus {
  const SyncStatus({
    this.busy = false,
    this.email,
    this.lastSyncAt,
    this.lastReport,
    this.blocker,
    this.owner,
    this.backupKnown = false,
  });

  final bool busy;
  final String? email;
  final DateTime? lastSyncAt;
  final SyncReport? lastReport;
  final SyncBlocker? blocker;

  /// Who takes the nightly snapshot, and when the last one landed. Null means
  /// nobody has claimed the job — which is different from not having looked.
  final SnapshotOwner? owner;

  /// Whether the owner file has been read at all this session.
  final bool backupKnown;

  bool get connected => email != null;

  /// Three days without a snapshot. Worth saying, because journals cannot
  /// compact while this is true.
  bool get backupStale =>
      backupKnown &&
      (owner == null ||
          owner!.isStaleAt(DateTime.now().millisecondsSinceEpoch));

  SyncStatus copyWith({
    bool? busy,
    String? email,
    DateTime? lastSyncAt,
    SyncReport? lastReport,
    SyncBlocker? blocker,
    SnapshotOwner? owner,
    bool? backupKnown,
    bool clearBlocker = false,
    bool clearEmail = false,
    bool clearOwner = false,
  }) =>
      SyncStatus(
        busy: busy ?? this.busy,
        email: clearEmail ? null : (email ?? this.email),
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        lastReport: lastReport ?? this.lastReport,
        blocker: clearBlocker ? null : (blocker ?? this.blocker),
        owner: clearOwner ? null : (owner ?? this.owner),
        backupKnown: backupKnown ?? this.backupKnown,
      );
}

/// The app's single entry point to Drive sync.
///
/// Holds the account, builds an engine per run (the access token is short
/// lived, so the Drive client is not worth keeping), and publishes enough state
/// for one screen to describe what is going on.
class SyncService extends ChangeNotifier {
  SyncService({
    required this.db,
    required this.mutations,
    required this.deviceId,
    DriveAuth? auth,
    RemoteStore Function(String token)? storeFactory,
    Future<Directory> Function()? workDir,
  })  : auth = auth ?? DriveAuth(),
        _workDir = workDir ?? getTemporaryDirectory,
        // A seam, and the only reason it exists: without it nothing above
        // SyncEngine can be tested at all, and the ordering this class is
        // responsible for — pull, then snapshot — is exactly the kind of
        // wiring that looks obviously right and silently stops happening.
        _storeFactory = storeFactory ?? DriveStore.withToken;

  final AppDatabase db;
  final Mutations mutations;
  final String deviceId;
  final DriveAuth auth;
  final RemoteStore Function(String token) _storeFactory;

  /// Where a snapshot is built before it is uploaded. Injectable for the same
  /// reason as [_storeFactory]: the real one is a platform channel, and a
  /// test that cannot reach it cannot check this class at all.
  final Future<Directory> Function() _workDir;

  /// Snapshots run one at a time, and a claim skips while one is under way.
  ///
  /// They all build the copy at the same path — `snapshot-<date>.db` in the
  /// work directory — so two at once delete and attach the same file and fail
  /// with a disk I/O error that reads like a corrupt database. It is easy to
  /// arrange without meaning to: every backup now pulls first, and a
  /// successful pull triggers `refreshBackup`, which claims an unowned
  /// snapshot by taking one.
  Future<void> _snapshotLock = Future<void>.value();
  bool _snapshotBusy = false;

  Future<SnapshotResult> _runSnapshot(
    RemoteStore store, {
    bool takeOver = false,
  }) {
    final result = _snapshotLock.then((_) async {
      _snapshotBusy = true;
      try {
        final service = SnapshotService(
          db: db,
          store: store,
          deviceId: deviceId,
          workDir: await _workDir(),
        );
        return takeOver ? await service.takeOver() : await service.run();
      } finally {
        _snapshotBusy = false;
      }
    });
    _snapshotLock = result.then((_) {}, onError: (_) {});
    return result;
  }

  SyncStatus _status = const SyncStatus();
  SyncStatus get status => _status;

  void _set(SyncStatus next) {
    _status = next;
    notifyListeners();
  }

  /// Called at startup. Reads the app's own record of who connected — no call
  /// to Google at all, so opening the app can never raise an account prompt.
  Future<void> restore() async {
    final email = await auth.rememberedEmail();
    _set(_status.copyWith(
      email: email,
      clearEmail: email == null,
      blocker: email == null ? SyncBlocker.notConnected : null,
      clearBlocker: email != null,
    ));
  }

  /// Offers Drive once, on the first launch that has no account.
  ///
  /// Sync is the difference between one device and a bakery, and between
  /// having a backup and not — so it is offered on the way in rather than left
  /// behind three taps in Settings for someone to discover. Asked once: if it
  /// is dismissed, Today carries a banner instead and this never raises a
  /// sheet again on its own.
  ///
  /// This is the *interactive* path, and it is meant to prompt. It is the
  /// opposite of [syncNow], which must never prompt at all.
  Future<void> offerOnFirstRun() async {
    if (_status.connected) return;
    if (await auth.hasBeenOffered()) return;
    await auth.markOffered();
    await connect();
  }

  /// The connect button. Must be called from a tap.
  Future<bool> connect() async {
    _set(_status.copyWith(busy: true));
    try {
      await auth.connect();
      final email = await auth.rememberedEmail();
      _set(_status.copyWith(busy: false, email: email, clearBlocker: true));
      await syncNow();
      return true;
    } catch (e) {
      _set(_status.copyWith(
        busy: false,
        lastReport: SyncReport(error: e),
        blocker: SyncBlocker.notConnected,
      ));
      return false;
    }
  }

  Future<void> disconnect() async {
    await auth.disconnect();
    _set(const SyncStatus(blocker: SyncBlocker.notConnected));
  }

  /// One upload-then-pull cycle. Safe to call often: the engine drops a second
  /// run while one is in flight.
  Future<SyncReport> syncNow() async {
    if (_status.busy) return const SyncReport();

    // Nobody has connected, so there is nothing to sync and nothing to ask
    // Google. This is the common case on a fresh install and it must stay
    // completely silent — the timer and every resume come through here.
    if (!_status.connected) return const SyncReport();

    _set(_status.copyWith(busy: true));
    final token = await auth.silentToken();
    if (token == null) {
      // The account is still remembered, so this is the grant needing
      // interaction again rather than a disconnection. Surfacing it as
      // "Reconnect" beats failing silently, which is how a sync app quietly
      // stops syncing for a month — but it must never prompt on its own.
      _set(_status.copyWith(busy: false, blocker: SyncBlocker.needsReconnect));
      return const SyncReport(error: 'not authorised');
    }

    final engine = SyncEngine(
      db: db,
      mutations: mutations,
      store: _storeFactory(token),
      deviceId: deviceId,
    );
    final report = await engine.sync();

    // Drive refused the token we had. Drop it so the next run asks for a
    // fresh one instead of retrying a dead one until someone notices.
    if (!report.ok && '${report.error}'.contains('401')) auth.forgetToken();

    _set(_status.copyWith(
      busy: false,
      lastReport: report,
      lastSyncAt: report.ok ? DateTime.now() : null,
      clearBlocker: report.ok,
    ));
    if (report.ok) unawaited(refreshBackup());
    return report;
  }

  // ─────────────────────────────── backup ────────────────────────────────

  /// Reads `snapshot/owner.json`. Quiet on failure: not knowing who owns the
  /// snapshot is not a reason to make the sync screen look broken.
  Future<void> refreshBackup() async {
    final store = await _store();
    if (store == null) return;
    try {
      var owner = SnapshotOwner.parse(await store.readSnapshotMeta());

      // Nobody owns the snapshot, so this device takes it — now, rather than
      // at the first midnight it happens to be awake for.
      //
      // A first install used to own nothing until 00:02, which left the only
      // copy of a bakery's first day on one phone; and compaction waits for a
      // snapshot, so the journal could not shrink either. Whoever connects
      // first is the obvious owner: on a single-phone bakery it is the only
      // candidate, and on two it is the one that got there first, which is as
      // good a rule as any.
      //
      // Deliberately the same claim the nightly run makes, so two devices
      // connecting at once resolve the way they always did: last write wins
      // the file and the loser skips from the following night.
      if (owner == null) {
        await _claimSnapshot(store);
        owner = SnapshotOwner.parse(await store.readSnapshotMeta());
      }

      _set(_status.copyWith(
        owner: owner,
        clearOwner: owner == null,
        backupKnown: true,
      ));
    } catch (_) {
      // leave the previous answer standing
    }
  }

  /// Claims ownership and takes the first snapshot.
  ///
  /// Quiet on failure: an unclaimed folder is the state we were already in,
  /// and a bakery that cannot take a snapshot this minute still has an app
  /// that works. The nightly run tries again.
  Future<void> _claimSnapshot(RemoteStore store) async {
    // Somebody is already taking one, which is all this wanted.
    if (_snapshotBusy) return;
    try {
      await _runSnapshot(store);
    } catch (_) {
      // next time
    }
  }

  /// Pulls before a snapshot is taken, so the copy is of the whole bakery
  /// rather than of this phone's share of it.
  ///
  /// Best effort on purpose. If Drive is unreachable the upload would fail
  /// too, so the case this covers is a reachable Drive and one unreadable
  /// peer — and a snapshot missing an hour of one device beats no snapshot.
  /// The report comes back either way so the caller can say which it was.
  Future<SyncReport?> _pullBeforeSnapshot() async {
    try {
      return await syncNow();
    } catch (e) {
      return SyncReport(error: e);
    }
  }

  /// Takes a snapshot now, whatever the hour.
  ///
  /// The same job the nightly task runs, which means the same ownership rule:
  /// on a device that is not the snapshot owner this returns [
  /// SnapshotOutcome.notOwner] and changes nothing.
  Future<BackupRun> backUpNow() async {
    final sync = await _pullBeforeSnapshot();

    final store = await _store();
    if (store == null) {
      return BackupRun(
        sync: sync,
        snapshot: const SnapshotResult(SnapshotOutcome.failed,
            error: 'not authorised'),
      );
    }
    final result = await _runSnapshot(store);
    await refreshBackup();
    return BackupRun(sync: sync, snapshot: result);
  }

  /// Moves the backup job to this device.
  ///
  /// Pulls first for the same reason [backUpNow] does — the snapshot that
  /// proves the hand-off should hold everything, not just this phone's share.
  Future<BackupRun> takeOverBackups() async {
    final sync = await _pullBeforeSnapshot();

    final store = await _store();
    if (store == null) {
      return BackupRun(
        sync: sync,
        snapshot: const SnapshotResult(SnapshotOutcome.failed,
            error: 'not authorised'),
      );
    }
    final result = await _runSnapshot(store, takeOver: true);
    await refreshBackup();
    return BackupRun(sync: sync, snapshot: result);
  }

  Future<List<SnapshotChoice>> restoreChoices() async {
    final store = await _store();
    if (store == null) return const [];
    return RestoreService(store: store).available();
  }

  /// Downloads and parks a snapshot. It is swapped in at the next launch —
  /// see [applyPendingRestore].
  Future<void> stageRestore(String name) async {
    final store = await _store();
    if (store == null) throw StateError('Connect Google Drive first.');
    await RestoreService(store: store).stage(name);
  }

  /// The Drive folder, if this device can reach it. Used by the version gate,
  /// which reads what each peer is running from its `device.json`.
  Future<RemoteStore?> remoteStore() => _store();

  Future<RemoteStore?> _store() async {
    if (!_status.connected) return null;
    final token = await auth.silentToken();
    return token == null ? null : _storeFactory(token);
  }
}
