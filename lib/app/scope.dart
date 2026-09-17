import 'package:flutter/widgets.dart';

import '../domain/customers/repository.dart';
import '../domain/menu/repository.dart';
import '../domain/orders/repository.dart';
import '../domain/stock/repository.dart';
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
  })  : menu = MenuRepository(db, mutations),
        customers = CustomerRepository(db, mutations),
        orders = OrderRepository(db, mutations),
        stock = StockRepository(db, mutations),
        sync = SyncService(db: db, mutations: mutations, deviceId: deviceId);

  final AppDatabase db;
  final String deviceId;
  final Mutations mutations;

  final MenuRepository menu;
  final CustomerRepository customers;
  final OrderRepository orders;
  final StockRepository stock;
  final SyncService sync;

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
