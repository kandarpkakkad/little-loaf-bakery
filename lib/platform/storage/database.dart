import 'package:drift/drift.dart';

import 'tables.dart';

part 'database.g.dart';

/// Schema version — see docs/01-platform/storage/schema.md.
const int kSchemaVersion = 11;

@DriftDatabase(
  tables: [
    Customers,
    CustomerAddresses,
    MenuItems,
    Orders,
    OrderItems,
    OrderItemStatusEvents,
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

  /// One entry per version transition.
  /// The first migration to run against real data on two devices at once, so
  /// the order of the steps is the whole difficulty. See
  /// docs/01-platform/storage/lld.md §5b.
  static final Map<int, Future<void> Function(Migrator)> _steps = {
    9: _v9ToV10,
    10: _v10ToV11,
  };

  /// What an item is for moves down to the item (D25, finished).
  ///
  /// The message piped on it, its special requirements, its dietary flags and
  /// what it costs to send were all asked for at order level *and* per item.
  /// Each order's values are copied onto every one of its items, so nothing a
  /// person typed is lost — an order with one message ends up with that
  /// message on each item, which is what it already meant.
  static Future<void> _v10ToV11(Migrator m) async {
    final db = m.database as AppDatabase;
    final items = db.orderItems;

    await m.addColumn(items, items.itemMessage);
    await m.addColumn(items, items.requirements);
    await m.addColumn(items, items.dietaryFlags);
    await m.addColumn(items, items.deliveryCharge);

    await db.customStatement('''
      UPDATE order_items SET
        item_message  = (SELECT o.item_message  FROM orders o WHERE o.id = order_items.order_id),
        requirements  = (SELECT o.requirements  FROM orders o WHERE o.id = order_items.order_id),
        dietary_flags = COALESCE((SELECT o.dietary_flags FROM orders o WHERE o.id = order_items.order_id), 0)
    ''');

    // The charge is per journey, not per item, so it lands on **one** item of
    // each journey and the rest of that journey carry zero. Splitting it
    // evenly would invent figures nobody agreed; putting it on all of them
    // would charge one delivery several times.
    await db.customStatement('''
      UPDATE order_items SET delivery_charge = COALESCE((
        SELECT o.delivery_charge FROM orders o WHERE o.id = order_items.order_id
      ), 0)
      WHERE id IN (
        SELECT MIN(i.id) FROM order_items i
         WHERE i.order_id = order_items.order_id
           AND i.deleted_at IS NULL
         GROUP BY i.order_id,
                  COALESCE(i.delivery_date, -1),
                  COALESCE(i.delivery_time, -1),
                  COALESCE(i.fulfilment, ''),
                  COALESCE(i.address_text, '')
      )
    ''');
  }

  /// Scheduling moves from the order down to the line (D25-D27).
  static Future<void> _v9ToV10(Migrator m) async {
    final db = m.database as AppDatabase;
    final items = db.orderItems;
    final orders = db.orders;

    // 1 - additive only, so a v9 build that reads this file after a rollback
    //     still works.
    for (final c in [
      items.status,
      items.deliveryDate,
      items.deliveryTime,
      items.fulfilment,
      items.deliveryType,
      items.addressText,
      items.pinLat,
      items.pinLng,
      items.pinUrl,
      items.trackingUrl,
      items.deliveredAt,
      items.cancelReason,
    ]) {
      await m.addColumn(items, c);
    }
    await m.addColumn(orders, orders.confirmedAt);
    await m.addColumn(orders, orders.completedAt);
    await m.createTable(db.orderItemStatusEvents);

    // 2 - every existing line inherits its order's schedule. This is what
    //     makes a one-date order still mean the same thing afterwards.
    await db.customStatement('''
      UPDATE order_items SET
        delivery_date = (SELECT o.delivery_date FROM orders o WHERE o.id = order_id),
        delivery_time = (SELECT o.delivery_time FROM orders o WHERE o.id = order_id),
        fulfilment    = (SELECT o.fulfilment    FROM orders o WHERE o.id = order_id),
        delivery_type = (SELECT o.delivery_type FROM orders o WHERE o.id = order_id),
        address_text  = (SELECT o.address_text  FROM orders o WHERE o.id = order_id),
        pin_lat       = (SELECT o.pin_lat       FROM orders o WHERE o.id = order_id),
        pin_lng       = (SELECT o.pin_lng       FROM orders o WHERE o.id = order_id),
        pin_url       = (SELECT o.pin_url       FROM orders o WHERE o.id = order_id),
        tracking_url  = (SELECT o.tracking_url  FROM orders o WHERE o.id = order_id)
    ''');

    // 3 - and its order's status, mapped down. The order vocabulary is wider
    //     than the line's: created/confirmed both collapse to "not started",
    //     and completed lands on delivered.
    await db.customStatement('''
      UPDATE order_items SET status = CASE
        (SELECT o.status FROM orders o WHERE o.id = order_id)
          WHEN 'created'       THEN 'created'
          WHEN 'confirmed'     THEN 'confirmed'
          WHEN 'in_production' THEN 'in_production'
          WHEN 'ready'         THEN 'ready'
          WHEN 'out'           THEN 'out'
          WHEN 'delivered'     THEN 'delivered'
          WHEN 'completed'     THEN 'delivered'
          WHEN 'cancelled'     THEN 'cancelled'
          ELSE 'created'
        END
    ''');

    // 4 - the two columns a CHECK pairs with a status.
    await db.customStatement('''
      UPDATE order_items
         SET delivered_at = COALESCE(
               (SELECT o.delivered_at FROM orders o WHERE o.id = order_id),
               (SELECT o.created_at   FROM orders o WHERE o.id = order_id))
       WHERE status = 'delivered'
    ''');
    await db.customStatement('''
      UPDATE order_items
         SET cancel_reason = COALESCE(
               (SELECT o.cancel_reason FROM orders o WHERE o.id = order_id),
               'cancelled before per-line cancellation existed')
       WHERE status = 'cancelled'
    ''');

    // 5 - confirmed_at / completed_at, which the derivation needs and the old
    //     model never stored. Recovered from the status history where there is
    //     one, from the row's own timestamps where there is not.
    await db.customStatement('''
      UPDATE orders SET confirmed_at = COALESCE(
        (SELECT MIN(e.at) FROM order_status_events e
          WHERE e.order_id = orders.id AND e.to_status = 'confirmed'),
        CASE WHEN status = 'created' THEN NULL ELSE created_at END)
    ''');
    await db.customStatement('''
      UPDATE orders SET completed_at = (
        SELECT MIN(e.at) FROM order_status_events e
         WHERE e.order_id = orders.id AND e.to_status = 'completed')
    ''');

    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS ix_items_due '
      'ON order_items(delivery_date, delivery_time) '
      "WHERE deleted_at IS NULL AND status NOT IN ('delivered','cancelled')",
    );
  }

  Future<void> _createIndexes(Migrator m) async {
    const statements = [
      // the app's main sort: date → time → creation (untimed last, NULLs sort last)
      'CREATE INDEX ix_orders_delivery ON orders(delivery_date, delivery_time, created_at) WHERE deleted_at IS NULL',
      'CREATE INDEX ix_orders_status ON orders(status) WHERE deleted_at IS NULL',
      'CREATE INDEX ix_orders_customer ON orders(customer_id) WHERE deleted_at IS NULL',
      'CREATE UNIQUE INDEX ux_orders_no ON orders(order_no) WHERE deleted_at IS NULL',
      'CREATE INDEX ix_items_order ON order_items(order_id, position)',
      // the app's main sort lives here now: "what is due next" is a
      // question about lines, not orders (D25)
      'CREATE INDEX ix_items_due ON order_items(delivery_date, delivery_time) '
          "WHERE deleted_at IS NULL AND status NOT IN ('delivered','cancelled')",
      'CREATE INDEX ix_item_status ON order_item_status_events(order_item_id, at)',
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
