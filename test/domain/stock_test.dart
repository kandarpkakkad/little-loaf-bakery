import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/common/money.dart';
import 'package:little_loaf/domain/stock/model.dart';

StockMovement _m(StockKind k, double q, int at, {Money? amount}) =>
    StockMovement(kind: k, qty: q, at: at, amount: amount);

void main() {
  group('level', () {
    test('adds stock-ins and subtracts everything else', () {
      expect(
        levelOf([
          _m(StockKind.stockIn, 8, 1),
          _m(StockKind.consume, 5, 2),
          _m(StockKind.waste, 0.5, 3),
        ]),
        2.5,
      );
    });

    test('a count is a reset point, not another delta', () {
      final level = levelOf([
        _m(StockKind.stockIn, 8, 1),
        _m(StockKind.consume, 5, 2),
        _m(StockKind.count, 2, 3), // someone counted 2, not 3
        _m(StockKind.consume, 0.5, 4),
      ]);
      expect(level, 1.5); // from the count, not from the arithmetic
    });

    test('goes negative when a stock-in was missed, and says so', () {
      expect(levelOf([_m(StockKind.consume, 3, 1)]), -3);
    });

    test('is order-independent', () {
      final a = [_m(StockKind.stockIn, 8, 1), _m(StockKind.count, 2, 3), _m(StockKind.consume, 5, 2)];
      final b = [_m(StockKind.count, 2, 3), _m(StockKind.consume, 5, 2), _m(StockKind.stockIn, 8, 1)];
      expect(levelOf(a), levelOf(b));
    });
  });

  group('the bar', () {
    test('the worked example: 2.5 left of the 8 last stocked', () {
      final ms = [_m(StockKind.stockIn, 8, 1), _m(StockKind.consume, 5.5, 2)];
      expect(referenceOf(ms), 8);
      expect(levelOf(ms), 2.5);
    });

    test('stocking 2 onto 2.5 makes the bar full again at 4.5', () {
      final ms = [
        _m(StockKind.stockIn, 8, 1),
        _m(StockKind.consume, 5.5, 2),
        _m(StockKind.stockIn, 2, 3),
      ];
      expect(levelOf(ms), 4.5);
      expect(referenceOf(ms), 4.5); // reference resets — the bar reads 4.5 / 4.5
    });

    test('normally scales to the reference', () {
      expect(barScale(reference: 8, threshold: 6), 8);
    });

    test('when the last restock fell short, scales to the threshold', () {
      // notch lands at the right edge: "that restock didn't get you there"
      expect(barScale(reference: 4.5, threshold: 8), 8);
    });

    test('with nothing ever stocked in, scales to the threshold', () {
      expect(referenceOf([_m(StockKind.count, 3, 1)]), 0);
      expect(barScale(reference: 0, threshold: 6), 6);
    });

    test('colour follows position, in three bands', () {
      expect(stockStateOf(level: 2.5, threshold: 6), StockState.below);
      expect(stockStateOf(level: 6.5, threshold: 6), StockState.near);
      expect(stockStateOf(level: 12, threshold: 6), StockState.ok);
      expect(stockStateOf(level: 6, threshold: 6), StockState.near); // exactly at the line
    });
  });

  group('price history', () {
    test('derives the rate from the last stock-in that recorded an amount', () {
      final ms = [
        _m(StockKind.stockIn, 4, 1, amount: Money.rupees(1920)), // ₹480/kg
        _m(StockKind.stockIn, 5, 2, amount: Money.rupees(2600)), // ₹520/kg
      ];
      expect(lastRateOf(ms), Money.rupees(520));
    });

    test('ignores a stock-in with no amount — an honest gap stays a gap', () {
      final ms = [
        _m(StockKind.stockIn, 4, 1, amount: Money.rupees(1920)),
        _m(StockKind.stockIn, 5, 2), // amount skipped
      ];
      expect(lastRateOf(ms), Money.rupees(480));
    });

    test('returns null when nothing was ever priced', () {
      expect(lastRateOf([_m(StockKind.stockIn, 5, 1)]), isNull);
      expect(suggestedAmount(movements: [_m(StockKind.stockIn, 5, 1)], qty: 5), isNull);
    });

    test('use last price shows its working: 520/kg x 5 kg = 2,600', () {
      final ms = [_m(StockKind.stockIn, 4, 1, amount: Money.rupees(2080))]; // ₹520/kg
      expect(suggestedAmount(movements: ms, qty: 5), Money.rupees(2600));
    });
  });
}
