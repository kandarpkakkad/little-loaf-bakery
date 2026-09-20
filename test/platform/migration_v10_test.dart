import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/platform/storage/database.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

/// The v9 → v10 migration, run against a v9-shaped database with real rows in
/// it. The first migration that has to preserve meaning rather than start from
/// empty. docs/01-platform/storage/lld.md §5b
void main() {
  late AppDatabase db;
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('llb_mig');
    file = File('${dir.path}/v9.db');
  });

  tearDown(() async {
    await db.close();
    dir.deleteSync(recursive: true);
  });

  /// Writes the v9 shape with raw sqlite3 and closes it, so opening
  /// [AppDatabase] over the same file is a genuine upgrade rather than a
  /// reused connection — which is what made the first version of this test
  /// silently skip the migration entirely.
  Future<AppDatabase> openV9WithData(void Function(raw.Database) seed) async {
    final v9 = raw.sqlite3.open(file.path);
    v9.execute('''
      CREATE TABLE orders (
        id TEXT NOT NULL PRIMARY KEY, device_id TEXT NOT NULL,
        created_at INTEGER NOT NULL, updated_at_hlc TEXT NOT NULL,
        deleted_at INTEGER, field_hlc_json TEXT,
        order_no TEXT NOT NULL, customer_id TEXT NOT NULL, status TEXT NOT NULL,
        fulfilment TEXT NOT NULL, delivery_date INTEGER NOT NULL,
        delivery_time INTEGER, delivery_type TEXT, address_text TEXT,
        pin_lat REAL, pin_lng REAL, pin_url TEXT, tracking_url TEXT,
        discount_type TEXT, discount_value INTEGER,
        discount_amount INTEGER NOT NULL DEFAULT 0,
        delivery_charge INTEGER NOT NULL DEFAULT 0,
        requirements TEXT, item_message TEXT,
        dietary_flags INTEGER NOT NULL DEFAULT 0,
        requirements_changed_at INTEGER, requirements_ack_at INTEGER,
        source TEXT, notes TEXT, cancel_reason TEXT, delivered_at INTEGER)
    ''');
    v9.execute('''
      CREATE TABLE order_items (
        id TEXT NOT NULL PRIMARY KEY, device_id TEXT NOT NULL,
        created_at INTEGER NOT NULL, updated_at_hlc TEXT NOT NULL,
        deleted_at INTEGER,
        order_id TEXT NOT NULL, menu_item_id TEXT NOT NULL,
        item_name_snapshot TEXT NOT NULL, flavour TEXT,
        weight_value REAL, weight_unit TEXT,
        qty INTEGER NOT NULL DEFAULT 1, base_price INTEGER NOT NULL,
        note TEXT, position INTEGER NOT NULL)
    ''');
    v9.execute('''
      CREATE TABLE order_status_events (
        id TEXT NOT NULL PRIMARY KEY, device_id TEXT NOT NULL,
        created_at INTEGER NOT NULL, updated_at_hlc TEXT NOT NULL,
        deleted_at INTEGER,
        order_id TEXT NOT NULL, from_status TEXT, to_status TEXT NOT NULL,
        reason TEXT, at INTEGER NOT NULL)
    ''');
    v9.execute('PRAGMA user_version = 9');
    seed(v9);
    v9.close();

    final opened = AppDatabase(NativeDatabase(file));
    await opened.customSelect('SELECT 1').get(); // force the upgrade to run
    return opened;
  }

  void order(raw.Database e, String id,
      {required String status,
      int deliveryDate = 1000,
      int? deliveryTime,
      String fulfilment = 'delivery',
      String? deliveryType = 'local',
      String? address = '14 Turner Rd',
      int createdAt = 500,
      int? deliveredAt,
      String? cancelReason}) {
    e.execute(
      'INSERT INTO orders (id, device_id, created_at, updated_at_hlc, order_no, '
      'customer_id, status, fulfilment, delivery_date, delivery_time, '
      'delivery_type, address_text, delivered_at, cancel_reason) '
      'VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
      [
        id, 'dev', createdAt, '$createdAt:0:dev', 'LLB-0001', 'c1', status,
        fulfilment, deliveryDate, deliveryTime, deliveryType, address,
        deliveredAt, cancelReason,
      ],
    );
  }

  void line(raw.Database e, String id, String orderId, {int position = 0}) {
    e.execute(
      'INSERT INTO order_items (id, device_id, created_at, updated_at_hlc, '
      'order_id, menu_item_id, item_name_snapshot, base_price, position) '
      'VALUES (?,?,?,?,?,?,?,?,?)',
      [id, 'dev', 500, '500:0:dev', orderId, 'm1', 'Cake', 100000, position],
    );
  }

  Future<List<Map<String, Object?>>> rows(String table) async {
    final r = await db.customSelect('SELECT * FROM $table').get();
    return [for (final row in r) row.data];
  }

  tearDown(() => db.close());

  test('a v9 database is carried all the way to the current schema', () async {
    db = await openV9WithData((e) {});
    final v = await db.customSelect('PRAGMA user_version').getSingle();
    expect(v.data.values.first, kSchemaVersion,
        reason: 'every step in between ran, not just the first');
    expect(await rows('order_item_status_events'), isEmpty);
  });

  test('v11 moves what an item is for onto the item', () async {
    db = await openV9WithData((e) {
      order(e, 'o1', status: 'confirmed', deliveryDate: 7000);
      line(e, 'i1', 'o1');
      line(e, 'i2', 'o1');
      e.execute("UPDATE orders SET item_message = 'Happy 40th', "
          "requirements = 'no fondant', dietary_flags = 2, "
          "delivery_charge = 5000 WHERE id = 'o1'");
    });

    final items = await rows('order_items');
    for (final i in items) {
      expect(i['item_message'], 'Happy 40th');
      expect(i['requirements'], 'no fondant');
      expect(i['dietary_flags'], 2);
    }

    // One journey, so the charge lands on one item and the order still costs
    // one delivery rather than two.
    expect(items.map((i) => i['delivery_charge']).toList()..sort(),
        [0, 5000],
        reason: 'a charge on every item would bill one van twice');
  });

  test('a line inherits its order schedule, so nothing changes meaning',
      () async {
    db = await openV9WithData((e) {
      order(e, 'o1',
          status: 'confirmed', deliveryDate: 7000, deliveryTime: 540);
      line(e, 'i1', 'o1');
    });

    final i = (await rows('order_items')).single;
    expect(i['delivery_date'], 7000);
    expect(i['delivery_time'], 540);
    expect(i['fulfilment'], 'delivery');
    expect(i['delivery_type'], 'local');
    expect(i['address_text'], '14 Turner Rd');
  });

  test('order status maps down to the line vocabulary', () async {
    db = await openV9WithData((e) {
      order(e, 'created', status: 'created');
      order(e, 'confirmed', status: 'confirmed');
      order(e, 'inprod', status: 'in_production');
      order(e, 'ready', status: 'ready');
      order(e, 'out', status: 'out');
      order(e, 'delivered', status: 'delivered', deliveredAt: 9000);
      order(e, 'completed', status: 'completed', deliveredAt: 9000);
      order(e, 'cancelled', status: 'cancelled', cancelReason: 'no cake');
      var n = 0;
      for (final o in [
        'created', 'confirmed', 'inprod', 'ready', 'out',
        'delivered', 'completed', 'cancelled',
      ]) {
        line(e, 'i$n', o);
        n++;
      }
    });

    final byOrder = {
      for (final r in await rows('order_items')) r['order_id']: r['status'],
    };
    expect(byOrder['created'], 'created',
        reason: 'nothing has been made yet, so it is still editable');
    expect(byOrder['confirmed'], 'confirmed');
    expect(byOrder['inprod'], 'in_production');
    expect(byOrder['ready'], 'ready');
    expect(byOrder['out'], 'out');
    expect(byOrder['delivered'], 'delivered');
    expect(byOrder['completed'], 'delivered',
        reason: 'completed is an order-level fact; the line was delivered');
    expect(byOrder['cancelled'], 'cancelled');
  });

  test('the columns a CHECK pairs with a status are filled', () async {
    db = await openV9WithData((e) {
      order(e, 'd', status: 'delivered', deliveredAt: 9000);
      line(e, 'i1', 'd');
      // a cancelled order that never recorded why
      order(e, 'c', status: 'cancelled');
      line(e, 'i2', 'c');
    });

    final byId = {for (final r in await rows('order_items')) r['id']: r};
    expect(byId['i1']!['delivered_at'], 9000);
    expect(byId['i2']!['cancel_reason'], isNotNull,
        reason: 'the CHECK pairs cancelled with a reason, so one is invented');
  });

  test('confirmed_at is recovered from history, or inferred', () async {
    db = await openV9WithData((e) {
      order(e, 'withHistory', status: 'ready');
      line(e, 'i1', 'withHistory');
      e.execute(
        'INSERT INTO order_status_events (id, device_id, created_at, '
        'updated_at_hlc, order_id, to_status, at) VALUES (?,?,?,?,?,?,?)',
        ['e1', 'dev', 600, '600:0:dev', 'withHistory', 'confirmed', 6000],
      );
      // no events at all
      order(e, 'noHistory', status: 'ready', createdAt: 700);
      line(e, 'i2', 'noHistory');
      // never confirmed
      order(e, 'stillNew', status: 'created', createdAt: 800);
      line(e, 'i3', 'stillNew');
    });

    final byId = {for (final r in await rows('orders')) r['id']: r};
    expect(byId['withHistory']!['confirmed_at'], 6000);
    expect(byId['noHistory']!['confirmed_at'], 700,
        reason: 'fell back to created_at — it is past created, so it was confirmed');
    expect(byId['stillNew']!['confirmed_at'], isNull);
  });

  test('a multi-line order gives every line the same schedule', () async {
    db = await openV9WithData((e) {
      order(e, 'o1', status: 'in_production', deliveryDate: 4200);
      line(e, 'a', 'o1', position: 0);
      line(e, 'b', 'o1', position: 1);
      line(e, 'c', 'o1', position: 2);
    });

    final dates =
        (await rows('order_items')).map((r) => r['delivery_date']).toSet();
    expect(dates, {4200}, reason: 'a one-date order is still a one-date order');
  });
}
