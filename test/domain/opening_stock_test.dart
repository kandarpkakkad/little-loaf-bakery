import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/common/money.dart';
import 'package:little_loaf/domain/stock/model.dart';

import '../support/harness.dart';

/// A material added mid-life usually already has some on the shelf.
///
/// With a price it is recorded as a purchase (`in`), which sets the level *and*
/// teaches the app what the material costs — the figure "use last price" reads.
/// Without one it is a stocktake (`count`): you have it, you cannot say what it
/// cost, and inventing a number would be worse than leaving it blank.
void main() {
  late AppServicesFixture f;

  setUp(() async => f = await AppServicesFixture.make());
  tearDown(() => f.close());

  test('opening stock sets the level', () async {
    final id = await f.services.stock.createMaterial(
        name: 'Flour', category: 'raw', unit: 'kg', thresholdQty: 5);
    await f.services.stock
        .addMovement(materialId: id, kind: StockKind.count, qty: 12);

    final levels = await f.services.stock.watchLevels().first;
    final flour = levels.firstWhere((l) => l.material.id == id);
    expect(flour.level, 12);
  });

  test('a material with no opening stock starts at zero', () async {
    final id = await f.services.stock.createMaterial(
        name: 'Sugar', category: 'raw', unit: 'kg', thresholdQty: 5);
    final levels = await f.services.stock.watchLevels().first;
    expect(levels.firstWhere((l) => l.material.id == id).level, 0);
  });

  test('opening stock is below threshold when it should be', () async {
    final id = await f.services.stock.createMaterial(
        name: 'Butter', category: 'raw', unit: 'kg', thresholdQty: 10);
    await f.services.stock
        .addMovement(materialId: id, kind: StockKind.count, qty: 3);

    final levels = await f.services.stock.watchLevels().first;
    expect(levels.firstWhere((l) => l.material.id == id).state,
        StockState.below,
        reason: '3 on hand against a threshold of 10');
  });

  test('opening stock with a price is a purchase, and sets the rate', () async {
    final id = await f.services.stock.createMaterial(
        name: 'Butter', category: 'raw', unit: 'kg', thresholdQty: 2);
    await f.services.stock.addMovement(
      materialId: id,
      kind: StockKind.stockIn,
      qty: 4,
      amount: Money.rupees(2000),
    );

    final levels = await f.services.stock.watchLevels().first;
    final butter = levels.firstWhere((l) => l.material.id == id);
    expect(butter.level, 4);
    expect(butter.lastRate, Money.rupees(500),
        reason: '₹2000 for 4 kg — what the next purchase will offer');
  });

  test('opening stock without a price leaves the rate unknown', () async {
    final id = await f.services.stock.createMaterial(
        name: 'Flour', category: 'raw', unit: 'kg', thresholdQty: 5);
    await f.services.stock
        .addMovement(materialId: id, kind: StockKind.count, qty: 12);

    final levels = await f.services.stock.watchLevels().first;
    final flour = levels.firstWhere((l) => l.material.id == id);
    expect(flour.level, 12);
    expect(flour.lastRate, isNull,
        reason: 'no invented number — the app says it does not know');
  });

  test('a later purchase replaces an unknown opening rate', () async {
    final id = await f.services.stock.createMaterial(
        name: 'Sugar', category: 'raw', unit: 'kg', thresholdQty: 5);
    await f.services.stock
        .addMovement(materialId: id, kind: StockKind.count, qty: 3);
    await f.services.stock.addMovement(
      materialId: id,
      kind: StockKind.stockIn,
      qty: 2,
      amount: Money.rupees(120),
    );

    final levels = await f.services.stock.watchLevels().first;
    final sugar = levels.firstWhere((l) => l.material.id == id);
    expect(sugar.level, 5, reason: 'the count, plus what was bought');
    expect(sugar.lastRate, Money.rupees(60));
  });
}
