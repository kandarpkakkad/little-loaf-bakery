import 'package:drift/drift.dart';

import 'tables.dart';

part 'database.g.dart';

/// Schema version — see docs/01-platform/storage/schema.md.
const int kSchemaVersion = 16;

@DriftDatabase(
  tables: [
    Customers,
    CustomerAddresses,
    MenuItems,
    Orders,
    SubOrders,
    OrderItems,
    OrderItemStatusEvents,
    OrderItemAddons,
    OrderStatusEvents,
    Attachments,
    Payments,
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

  /// One entry per version transition.
  /// The first migration to run against real data on two devices at once, so
  /// the order of the steps is the whole difficulty. See
  /// docs/01-platform/storage/lld.md §5b.
  /// One entry per version transition, forward only.
  ///
  /// **The history before v12 is gone**, and deliberately. v12 made the
  /// journey a table of its own (D28), which moved nine columns off every
  /// item and rebuilt two tables to change their CHECKs. Carrying v9 and v10
  /// rows through that would have meant inventing a sub-order per distinct
  /// schedule and renumbering them — code written once, run never, and
  /// impossible to test against rows that will not exist, because the app is
  /// being started again from empty.
  ///
  /// A database older than v11 therefore fails to open with "no migration step
  /// from schema vN", which is the truth: reinstall.
  static final Map<int, Future<void> Function(Migrator)> _steps = {
    11: _v11ToV12,
    12: _v12ToV13,
    13: _v13ToV14,
    14: _v14ToV15,
    15: _v15ToV16,
  };

  /// The journey becomes a row of its own (D28).
  ///
  /// Rebuilds the order side of the schema rather than carrying it across.
  /// See the note on [_steps] for why.
  static Future<void> _v11ToV12(Migrator m) async {
    final db = m.database as AppDatabase;

    await db.customStatement('PRAGMA foreign_keys = OFF');
    for (final t in [
      'order_item_addons',
      'order_item_status_events',
      'order_items',
      'order_status_events',
      'payments',
      'invoices', // v12 still had one; v13 removed invoicing entirely
      'sub_orders',
      'orders',
    ]) {
      await db.customStatement('DROP TABLE IF EXISTS $t');
    }

    await m.createTable(db.orders);
    await m.createTable(db.subOrders);
    await m.createTable(db.orderItems);
    await m.createTable(db.orderItemAddons);
    await m.createTable(db.orderStatusEvents);
    await m.createTable(db.orderItemStatusEvents);
    await m.createTable(db.payments);
    await db.customStatement('PRAGMA foreign_keys = ON');
  }

  /// Invoicing removed.
  ///
  /// The bakery does not raise bills — a payment is acknowledged over WhatsApp
  /// and that is the whole of it. The table, its GST columns and the settings
  /// that fed it go with it; `invoice_prefix` stays because it prefixes ORDER
  /// numbers. A peer still sending `invoices` ops is handled for free: the
  /// applier reads a table's columns from the database and skips an entity it
  /// cannot find (`sync/apply.dart`).
  static Future<void> _v12ToV13(Migrator m) async {
    final db = m.database as AppDatabase;

    await db.customStatement('PRAGMA foreign_keys = OFF');
    await db.customStatement('DROP TABLE IF EXISTS invoices');
    // Recreated from the current definition, copying what still exists —
    // logo_path, terms_line, gstin, gst_enabled and invoice_seq do not.
    await m.alterTable(TableMigration(db.settings));
    await db.customStatement('PRAGMA foreign_keys = ON');
  }

  /// The discount moves to the item.
  ///
  /// Additive: the order's own columns stay, because a v13 peer reads them and
  /// because they are still written — as a flat amount summed from the items,
  /// which is the only shape that can represent a basket of mixed percentages
  /// and amounts.
  ///
  /// Existing orders keep their discount where it is. Nothing is backfilled
  /// onto their items: splitting one order-level figure across several items
  /// would invent a per-item price nobody agreed, and the cache on the order
  /// still carries the real number.
  static Future<void> _v13ToV14(Migrator m) async {
    final db = m.database as AppDatabase;
    await m.addColumn(db.orderItems, db.orderItems.discountType);
    await m.addColumn(db.orderItems, db.orderItems.discountValue);
  }

  /// An item is weighed or measured; how many there are is the quantity.
  ///
  /// `pcs` and `dozen` said the same thing twice — "1 pcs × 2" — so the app
  /// offers `g`, `kg`, `ml` and `l` now. The CHECK is **widened**, not
  /// narrowed: rows written before this still carry the old two, and a
  /// constraint that rejected them would make an existing order unsaveable.
  static Future<void> _v14ToV15(Migrator m) async {
    final db = m.database as AppDatabase;
    await db.customStatement('PRAGMA foreign_keys = OFF');
    // The CHECK is part of the table definition, so it is a rebuild and copy.
    await m.alterTable(TableMigration(db.orderItems));
    await db.customStatement('PRAGMA foreign_keys = ON');
  }

  /// The bakery's own details start replicating.
  ///
  /// `settings` was the one domain table with no `updated_at_hlc`, so it could
  /// not take part in the merge at all and the business details were silently
  /// per-phone. It gains the sync columns here.
  ///
  /// A rebuild rather than addColumn, because the table is recreated from its
  /// current definition and the rows copied across. Every new column must be
  /// named in `newColumns`: without that, drift copies it from the old table
  /// and the migration dies on `no such column: field_hlc_json`. They are
  /// filled from the defaults in the table definition.
  ///
  /// The seed `0:0:seed` is older than any real HLC, so whichever phone saves
  /// first wins the field rather than losing to a row nobody has edited.
  ///
  /// Only [kSharedSettings] ever travels — see the note on the table.
  static Future<void> _v15ToV16(Migrator m) async {
    final db = m.database as AppDatabase;
    await db.customStatement('PRAGMA foreign_keys = OFF');
    await m.alterTable(TableMigration(
      db.settings,
      newColumns: [
        db.settings.deviceId,
        db.settings.createdAt,
        db.settings.updatedAtHlc,
        db.settings.deletedAt,
        db.settings.fieldHlcJson,
      ],
    ));
    await db.customStatement('PRAGMA foreign_keys = ON');
  }

  Future<void> _createIndexes(Migrator m) async {
    const statements = [
      // the app's main sort: date → time → creation (untimed last, NULLs sort last)
      'CREATE INDEX ix_orders_delivery ON orders(delivery_date, delivery_time, created_at) WHERE deleted_at IS NULL',
      'CREATE INDEX ix_orders_status ON orders(status) WHERE deleted_at IS NULL',
      'CREATE INDEX ix_orders_customer ON orders(customer_id) WHERE deleted_at IS NULL',
      'CREATE UNIQUE INDEX ux_orders_no ON orders(order_no) WHERE deleted_at IS NULL',
      'CREATE INDEX ix_items_order ON order_items(order_id, position)',
      'CREATE INDEX ix_items_sub ON order_items(sub_order_id)',
      // the app's main sort lives here now: "what is due next" is a question
      // about journeys, not orders and not items (D28)
      'CREATE INDEX ix_subs_due ON sub_orders(delivery_date, delivery_time) '
          "WHERE deleted_at IS NULL AND status NOT IN ('delivered','cancelled')",
      'CREATE UNIQUE INDEX ux_sub_seq ON sub_orders(order_id, seq) '
          'WHERE deleted_at IS NULL',
      'CREATE INDEX ix_item_status ON order_item_status_events(order_item_id, at)',
      'CREATE INDEX ix_items_menu ON order_items(menu_item_id)',
      'CREATE INDEX ix_addons_item ON order_item_addons(order_item_id, position)',
      'CREATE INDEX ix_status_order ON order_status_events(order_id, at)',
      'CREATE INDEX ix_pay_order ON payments(order_id, paid_at) WHERE deleted_at IS NULL',
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
