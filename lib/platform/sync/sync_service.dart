import 'dart:async';

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
  }) : auth = auth ?? DriveAuth();

  final AppDatabase db;
  final Mutations mutations;
  final String deviceId;
  final DriveAuth auth;

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
      store: DriveStore.withToken(token),
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
      final owner = SnapshotOwner.parse(await store.readSnapshotMeta());
      _set(_status.copyWith(
        owner: owner,
        clearOwner: owner == null,
        backupKnown: true,
      ));
    } catch (_) {
      // leave the previous answer standing
    }
  }

  /// Takes a snapshot now, whatever the hour.
  ///
  /// The same job the nightly task runs, which means the same ownership rule:
  /// on a device that is not the snapshot owner this returns [
  /// SnapshotOutcome.notOwner] and changes nothing.
  Future<SnapshotResult> backUpNow() async {
    final store = await _store();
    if (store == null) {
      return const SnapshotResult(SnapshotOutcome.failed,
          error: 'not authorised');
    }
    final result = await SnapshotService(
      db: db,
      store: store,
      deviceId: deviceId,
      workDir: await getTemporaryDirectory(),
    ).run();
    await refreshBackup();
    return result;
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

  Future<DriveStore?> _store() async {
    if (!_status.connected) return null;
    final token = await auth.silentToken();
    return token == null ? null : DriveStore.withToken(token);
  }
}
