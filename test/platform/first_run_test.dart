import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/platform/storage/database.dart';

/// docs/01-platform/storage/schema.md § First run
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<List<String>> namesOf(String type) async {
    final rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = ? "
            "AND name NOT LIKE 'sqlite_%' ORDER BY name",
            variables: [Variable.withString(type)])
        .get();
    return rows.map((r) => r.read<String>('name')).toList();
  }

  test('creates every table on first open', () async {
    final tables = await namesOf('table');
    expect(tables, hasLength(19));
    expect(
      tables,
      containsAll([
        'customers', 'customer_addresses', 'menu_items', 'orders', 'order_items',
        'order_item_addons',
        'order_status_events', 'attachments', 'payments', 'invoices',
        'materials', 'stock_transactions', 'share_log',
        'devices', 'conflict_log', 'outbox', 'applied_ops', 'peer_cursors',
        'settings',
      ]),
    );
  });

  test('creates every index on first open', () async {
    final ix = await namesOf('index');
    expect(ix, hasLength(20));
    // the app's main sort, and the partial uniques that make offline dedupe work
    expect(ix, containsAll(['ix_orders_delivery', 'ux_cust_phone', 'ux_orders_no',
                            'ux_inv_order', 'ix_share_unsent', 'ix_addr_cust']));
  });

  test('seeds the settings singleton so no screen meets a missing row', () async {
    final s = await db.select(db.settings).getSingle();
    expect(s.id, 'singleton');
    expect(s.businessName, 'Little Loaf Bakery');
    expect(s.invoicePrefix, 'LLB');
    expect(s.orderSeq, 0);
    expect(s.gstEnabled, isFalse);
  });

  test('records its schema version, so an upgrade knows where to start', () async {
    final v = await db.customSelect('PRAGMA user_version').getSingle();
    expect(v.read<int>('user_version'), kSchemaVersion);
  });

  test('enforces the constraints that encode decisions', () async {
    // a pickup can carry neither a delivery type nor a tracking link
    await db.into(db.customers).insert(CustomersCompanion.insert(
        id: 'c1', deviceId: 'd', createdAt: 0, updatedAtHlc: 'h',
        name: 'Meera', phoneE164: '+919876543210'));
    expect(
      () => db.into(db.orders).insert(OrdersCompanion.insert(
          id: 'o1', deviceId: 'd', createdAt: 0, updatedAtHlc: 'h',
          orderNo: 'LLB-0001-AAAA', customerId: 'c1', status: 'created',
          fulfilment: 'pickup', deliveryDate: 0,
          trackingUrl: const Value('https://x'))),
      throwsA(isA<SqliteException>()),
    );
  });

  test('a refund must be negative, and only a refund may be', () async {
    await db.into(db.customers).insert(CustomersCompanion.insert(
        id: 'c1', deviceId: 'd', createdAt: 0, updatedAtHlc: 'h',
        name: 'Meera', phoneE164: '+919876543210'));
    await db.into(db.orders).insert(OrdersCompanion.insert(
        id: 'o1', deviceId: 'd', createdAt: 0, updatedAtHlc: 'h',
        orderNo: 'LLB-0001-AAAA', customerId: 'c1', status: 'delivered',
        fulfilment: 'delivery', deliveryDate: 0));
    expect(
      () => db.into(db.payments).insert(PaymentsCompanion.insert(
          id: 'p1', deviceId: 'd', createdAt: 0, updatedAtHlc: 'h',
          orderId: 'o1', amount: 5000, kind: 'refund', mode: 'upi', paidAt: 0)),
      throwsA(isA<SqliteException>()),
    );
  });
}
