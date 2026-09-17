import 'package:drift/drift.dart';

import '../../common/ids.dart';
import '../../platform/storage/database.dart';
import '../../platform/sync/mutations.dart';
import '../../platform/sync/op.dart';

/// The fixed items the bakery makes — "Cake", "Croissant", "Focaccia". The item
/// *is* the category; there is no second grouping level. Maintained from Config
/// — an order picks from here and then customises, so the menu carries no price.
/// docs/02-domain/menu/hld.md
class MenuRepository {
  MenuRepository(this.db, this.mutations);

  final AppDatabase db;
  final Mutations mutations;

  Stream<List<MenuItem>> watchAll({bool activeOnly = false}) {
    final q = db.select(db.menuItems)..where((t) => t.deletedAt.isNull());
    if (activeOnly) q.where((t) => t.active.equals(true));
    q.orderBy([(t) => OrderingTerm.asc(t.name)]);
    return q.watch();
  }

  /// A snapshot, for a form that opens once and does not need to react.
  Future<List<MenuItem>> list({bool activeOnly = false}) {
    final q = db.select(db.menuItems)..where((t) => t.deletedAt.isNull());
    if (activeOnly) q.where((t) => t.active.equals(true));
    q.orderBy([(t) => OrderingTerm.asc(t.name)]);
    return q.get();
  }

  Future<String> create({
    required String name,
    int leadDays = 0,
  }) async {
    final id = Uuid7.generate();
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await db.into(db.menuItems).insert(MenuItemsCompanion.insert(
            id: id,
            deviceId: mutations.deviceId,
            createdAt: now,
            updatedAtHlc: mutations.lastHlc.toString(),
            name: name,
            leadDays: Value(leadDays),
          ));
      await mutations.record('menu_items', id, OpKind.upsert, {
        'name': name,
        'lead_days': leadDays,
        'active': true,
      });
    });
    return id;
  }

  Future<void> update(
    String id, {
    String? name,
    int? leadDays,
    bool? active,
  }) async {
    final fields = <String, Object?>{
      if (name != null) 'name': name,
      if (leadDays != null) 'lead_days': leadDays,
      if (active != null) 'active': active,
    };
    if (fields.isEmpty) return;
    await db.transaction(() async {
      await (db.update(db.menuItems)..where((t) => t.id.equals(id))).write(
        MenuItemsCompanion(
          name: name == null ? const Value.absent() : Value(name),
          leadDays: leadDays == null ? const Value.absent() : Value(leadDays),
          active: active == null ? const Value.absent() : Value(active),
          updatedAtHlc: Value(mutations.lastHlc.toString()),
        ),
      );
      await mutations.record('menu_items', id, OpKind.upsert, fields);
    });
  }

  /// Soft delete — the row stays so an old order can still resolve the item it
  /// was built from, and so the delete itself can replicate.
  Future<void> remove(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await (db.update(db.menuItems)..where((t) => t.id.equals(id)))
          .write(MenuItemsCompanion(deletedAt: Value(now)));
      await mutations.record('menu_items', id, OpKind.delete, const {});
    });
  }
}
