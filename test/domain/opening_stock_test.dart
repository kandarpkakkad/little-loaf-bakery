import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/domain/stock/model.dart';

import '../support/harness.dart';

/// A material added mid-life usually already has some on the shelf. Recording
/// it as a `count` sets the level absolutely, the same as a stocktake — an `in`
/// movement would read as a purchase that never happened.
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
}
