import 'package:flutter/widgets.dart';

import '../domain/customers/repository.dart';
import '../domain/invoicing/repository.dart';
import '../domain/menu/repository.dart';
import '../domain/orders/repository.dart';
import '../domain/reporting/repository.dart';
import '../domain/stock/repository.dart';
import '../platform/security/app_lock.dart';
import '../platform/versioning/app_updates.dart';
import '../platform/storage/database.dart';
import '../platform/sync/mutations.dart';
import '../platform/sync/sync_service.dart';

/// Everything the app needs, opened once and handed down.
///
/// Deliberately not a service locator: a screen reaches what it needs through
/// the tree, so a test can wrap a subtree with an in-memory database and the
/// screen is none the wiser.
class AppServices {
  AppServices({
    required this.db,
    required this.deviceId,
    required this.mutations,
    AppLock? lock,
  })  : lock = lock ?? AppLock(db: db),
        menu = MenuRepository(db, mutations),
        customers = CustomerRepository(db, mutations),
        orders = OrderRepository(db, mutations),
        stock = StockRepository(db, mutations),
        invoices = InvoiceRepository(db, mutations),
        sync = SyncService(db: db, mutations: mutations, deviceId: deviceId) {
    reports = ReportRepository(db, orders);
    updates = AppUpdates(sync);
  }

  final AppDatabase db;
  final String deviceId;
  final Mutations mutations;

  final MenuRepository menu;
  final CustomerRepository customers;
  final OrderRepository orders;
  final StockRepository stock;
  final InvoiceRepository invoices;

  /// Built after the field initialisers because it reads through
  /// [orders] rather than the database directly — one definition of a
  /// total, not two.
  late final ReportRepository reports;
  final SyncService sync;

  /// Whether the app asks for the device PIN before it shows anything. Off by
  /// default, and the switch is in Business details.
  final AppLock lock;

  /// Whether this build is too old to carry on. Reads GitHub Releases and
  /// what the other devices say they are running.
  late final AppUpdates updates;

  Future<Setting> settings() => db.select(db.settings).getSingle();
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope above this widget');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppScope old) => old.services != services;
}

extension AppScopeX on BuildContext {
  AppServices get app => AppScope.of(this);
  AppDatabase get db => AppScope.of(this).db;
}
