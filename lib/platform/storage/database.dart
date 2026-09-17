import 'package:drift/drift.dart';

import 'tables.dart';

part 'database.g.dart';

/// Schema version — see docs/01-platform/storage/schema.md.
const int kSchemaVersion = 9;

@DriftDatabase(
  tables: [
    Customers,
    CustomerAddresses,
    MenuItems,
    Orders,
    OrderItems,
    OrderItemAddons,
    OrderStatusEvents,
    Attachments,
    Payments,
    Invoices,
    Materials,
    StockTransactions,
    ShareLog,
    Devices,
    ConflictLog,
    Outbox,
    AppliedOps,
    PeerCursors,
    Settings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => kSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createIndexes(m);
          await into(settings).insert(
            const SettingsCompanion(id: Value('singleton')),
            mode: InsertMode.insertOrIgnore,
          );
        },
        onUpgrade: (m, from, to) async {
          // Forward-only, one step per version. Additive by default: a column
          // that must go is emptied in release n and dropped in n+1, so a
          // rollback survives. See docs/01-platform/storage/schema.md.
          for (var v = from; v < to; v++) {
            final step = _steps[v];
            if (step == null) {
              throw StateError('no migration step from schema v$v');
            }
            await step(m);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// One entry per version transition. Deliberately empty while the app is
  /// pre-release: a schema change means uninstall and start again, and an
  /// empty map makes that explicit by throwing rather than silently opening a
  /// database written by an older build.
  static final Map<int, Future<void> Function(Migrator)> _steps = {};

  Future<void> _createIndexes(Migrator m) async {
    const statements = [
      // the app's main sort: date → time → creation (untimed last, NULLs sort last)
      'CREATE INDEX ix_orders_delivery ON orders(delivery_date, delivery_time, created_at) WHERE deleted_at IS NULL',
      'CREATE INDEX ix_orders_status ON orders(status) WHERE deleted_at IS NULL',
      'CREATE INDEX ix_orders_customer ON orders(customer_id) WHERE deleted_at IS NULL',
      'CREATE UNIQUE INDEX ux_orders_no ON orders(order_no) WHERE deleted_at IS NULL',
      'CREATE INDEX ix_items_order ON order_items(order_id, position)',
      'CREATE INDEX ix_items_menu ON order_items(menu_item_id)',
      'CREATE INDEX ix_addons_item ON order_item_addons(order_item_id, position)',
      'CREATE INDEX ix_status_order ON order_status_events(order_id, at)',
      'CREATE INDEX ix_pay_order ON payments(order_id, paid_at) WHERE deleted_at IS NULL',
      'CREATE UNIQUE INDEX ux_inv_order ON invoices(order_id) WHERE deleted_at IS NULL',
      'CREATE UNIQUE INDEX ux_inv_no ON invoices(invoice_no) WHERE deleted_at IS NULL',
      'CREATE UNIQUE INDEX ux_cust_phone ON customers(phone_e164) WHERE deleted_at IS NULL',
      'CREATE INDEX ix_cust_name ON customers(name) WHERE deleted_at IS NULL',
      'CREATE INDEX ix_addr_cust ON customer_addresses(customer_id) WHERE deleted_at IS NULL',
      'CREATE INDEX ix_menu_name ON menu_items(name) WHERE deleted_at IS NULL',
      'CREATE INDEX ix_mat_cat ON materials(category, name) WHERE deleted_at IS NULL',
      'CREATE INDEX ix_stock_mat ON stock_transactions(material_id, at) WHERE deleted_at IS NULL',
      'CREATE INDEX ix_share_order ON share_log(order_id, composed_at) WHERE deleted_at IS NULL',
      'CREATE INDEX ix_share_unsent ON share_log(order_id) WHERE shared_at IS NULL AND deleted_at IS NULL',
      'CREATE INDEX ix_outbox_pending ON outbox(seq) WHERE uploaded_at IS NULL',
    ];
    for (final s in statements) {
      await customStatement(s);
    }
  }
}
