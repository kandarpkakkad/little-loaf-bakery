import 'package:drift/drift.dart';

import '../../common/ids.dart';
import '../../common/money.dart';
import '../../platform/storage/database.dart';
import '../../platform/sync/mutations.dart';
import '../../platform/sync/op.dart';
import 'model.dart';

/// A material plus everything derived from its movements. Nothing here is
/// stored — levels are computed, so two devices cannot hold different numbers.
class StockLevel {
  const StockLevel({
    required this.material,
    required this.level,
    required this.reference,
    required this.movements,
  });

  final RawMaterial material;
  final double level;
  final double reference;
  final List<StockMovement> movements;

  double get threshold => material.thresholdQty;
  double get scale => barScale(reference: reference, threshold: threshold);
  StockState get state => stockStateOf(level: level, threshold: threshold);
  Money? get lastRate => lastRateOf(movements);
}

class StockRepository {
  StockRepository(this.db, this.mutations);

  final AppDatabase db;
  final Mutations mutations;

  Stream<List<RawMaterial>> watchMaterials({bool activeOnly = false}) {
    final q = db.select(db.materials)..where((t) => t.deletedAt.isNull());
    if (activeOnly) q.where((t) => t.active.equals(true));
    q.orderBy([(t) => OrderingTerm.asc(t.category), (t) => OrderingTerm.asc(t.name)]);
    return q.watch();
  }

  /// Levels for every active material, recomputed whenever either table moves.
  ///
  /// The left join is what makes that true: the query reads `materials` **and**
  /// `stock_transactions`, so drift re-runs it when either one changes. A
  /// material with no movements still comes back, with a null transaction.
  Stream<List<StockLevel>> watchLevels() {
    final q = db.select(db.materials).join([
      leftOuterJoin(
        db.stockTransactions,
        db.stockTransactions.materialId.equalsExp(db.materials.id) &
            db.stockTransactions.deletedAt.isNull(),
      ),
    ])
      ..where(db.materials.deletedAt.isNull() & db.materials.active.equals(true))
      ..orderBy([OrderingTerm.asc(db.materials.name)]);

    return q.watch().map((rows) {
      final mats = <String, RawMaterial>{};
      final byMaterial = <String, List<StockMovement>>{};
      for (final row in rows) {
        final m = row.readTable(db.materials);
        mats[m.id] = m;
        byMaterial.putIfAbsent(m.id, () => []);
        final t = row.readTableOrNull(db.stockTransactions);
        if (t != null) {
          byMaterial[m.id]!.add(StockMovement(
            kind: StockKind.parse(t.kind),
            qty: t.qty,
            at: t.at,
            amount: t.amount == null ? null : Money(t.amount!),
          ));
        }
      }
      return [
        for (final m in mats.values)
          () {
            final ms = byMaterial[m.id]!;
            return StockLevel(
              material: m,
              level: levelOf(ms),
              reference: referenceOf(ms),
              movements: ms,
            );
          }()
      ];
    });
  }

  Future<String> createMaterial({
    required String name,
    required String category,
    required String unit,
    required double thresholdQty,
  }) async {
    final id = Uuid7.generate();
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await db.into(db.materials).insert(MaterialsCompanion.insert(
            id: id,
            deviceId: mutations.deviceId,
            createdAt: now,
            updatedAtHlc: mutations.lastHlc.toString(),
            name: name,
            category: category,
            unit: unit,
            thresholdQty: thresholdQty,
          ));
      await mutations.record('materials', id, OpKind.upsert, {
        'name': name,
        'category': category,
        'unit': unit,
        'threshold_qty': thresholdQty,
        'active': true,
      });
    });
    return id;
  }

  Future<void> updateMaterial(
    String id, {
    String? name,
    String? unit,
    double? thresholdQty,
    bool? active,
  }) async {
    final fields = <String, Object?>{
      if (name != null) 'name': name,
      if (unit != null) 'unit': unit,
      if (thresholdQty != null) 'threshold_qty': thresholdQty,
      if (active != null) 'active': active,
    };
    if (fields.isEmpty) return;
    await db.transaction(() async {
      await (db.update(db.materials)..where((t) => t.id.equals(id))).write(
        MaterialsCompanion(
          name: name == null ? const Value.absent() : Value(name),
          unit: unit == null ? const Value.absent() : Value(unit),
          thresholdQty:
              thresholdQty == null ? const Value.absent() : Value(thresholdQty),
          active: active == null ? const Value.absent() : Value(active),
          updatedAtHlc: Value(mutations.lastHlc.toString()),
        ),
      );
      await mutations.record('materials', id, OpKind.upsert, fields);
    });
  }

  Future<void> removeMaterial(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await (db.update(db.materials)..where((t) => t.id.equals(id)))
          .write(MaterialsCompanion(deletedAt: Value(now)));
      await mutations.record('materials', id, OpKind.delete, const {});
    });
  }

  /// One movement. `count` carries an absolute level; everything else a delta.
  /// [amount] is only meaningful on a stock-in, and stays null when the price
  /// was not recorded — an honest gap rather than a zero.
  Future<void> addMovement({
    required String materialId,
    required StockKind kind,
    required double qty,
    Money? amount,
    String? reason,
  }) async {
    final id = Uuid7.generate();
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await db.into(db.stockTransactions).insert(StockTransactionsCompanion.insert(
            id: id,
            deviceId: mutations.deviceId,
            createdAt: now,
            updatedAtHlc: mutations.lastHlc.toString(),
            materialId: materialId,
            kind: kind.wire,
            qty: qty,
            amount: Value(kind == StockKind.stockIn ? amount?.paise : null),
            reason: Value(kind == StockKind.waste ? reason : null),
            at: now,
          ));
      await mutations.record('stock_transactions', id, OpKind.upsert, {
        'material_id': materialId,
        'kind': kind.wire,
        'qty': qty,
        'amount': kind == StockKind.stockIn ? amount?.paise : null,
        'reason': kind == StockKind.waste ? reason : null,
        'at': now,
      });
    });
  }
}
