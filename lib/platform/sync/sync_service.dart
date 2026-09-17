import 'package:flutter/foundation.dart';

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
  });

  final bool busy;
  final String? email;
  final DateTime? lastSyncAt;
  final SyncReport? lastReport;
  final SyncBlocker? blocker;

  bool get connected => email != null;

  SyncStatus copyWith({
    bool? busy,
    String? email,
    DateTime? lastSyncAt,
    SyncReport? lastReport,
    SyncBlocker? blocker,
    bool clearBlocker = false,
    bool clearEmail = false,
  }) =>
      SyncStatus(
        busy: busy ?? this.busy,
        email: clearEmail ? null : (email ?? this.email),
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        lastReport: lastReport ?? this.lastReport,
        blocker: clearBlocker ? null : (blocker ?? this.blocker),
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

    _set(_status.copyWith(
      busy: false,
      lastReport: report,
      lastSyncAt: report.ok ? DateTime.now() : null,
      clearBlocker: report.ok,
    ));
    return report;
  }
}
