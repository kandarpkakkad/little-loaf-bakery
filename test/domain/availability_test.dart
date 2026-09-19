import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/domain/menu/availability.dart';
import 'package:little_loaf/platform/storage/database.dart';

/// Seasons repeat, so they are stored without a year and compared as MMDD.
/// docs/02-domain/menu/lld.md §2
void main() {
  MenuItem item({
    bool active = true,
    int? from,
    int? to,
    int? deletedAt,
  }) =>
      MenuItem(
        id: 'm1',
        deviceId: 'dev',
        createdAt: 0,
        updatedAtHlc: '0:0:dev',
        deletedAt: deletedAt,
        name: 'Plum cake',
        leadDays: 0,
        active: active,
        seasonFrom: from,
        seasonTo: to,
      );

  DateTime on(int month, int day) => DateTime(2026, month, day);

  test('no season means always available', () {
    expect(availableOn(item(), on(1, 15)), isTrue);
    expect(availableOn(item(), on(7, 15)), isTrue);
  });

  test('an ordinary window inside one year', () {
    final mango = item(from: 301, to: 831); // Mar–Aug
    expect(availableOn(mango, on(3, 1)), isTrue, reason: 'first day');
    expect(availableOn(mango, on(6, 15)), isTrue);
    expect(availableOn(mango, on(8, 31)), isTrue, reason: 'last day');
    expect(availableOn(mango, on(2, 28)), isFalse);
    expect(availableOn(mango, on(9, 1)), isFalse);
  });

  test('a window that wraps the year — the case that matters', () {
    final plum = item(from: 1101, to: 131); // Nov–Jan
    expect(availableOn(plum, on(11, 1)), isTrue, reason: 'opens in November');
    expect(availableOn(plum, on(12, 25)), isTrue, reason: 'Christmas');
    expect(availableOn(plum, on(1, 31)), isTrue, reason: 'closes end of Jan');
    expect(availableOn(plum, on(2, 1)), isFalse);
    expect(availableOn(plum, on(6, 15)), isFalse,
        reason: 'a naive range check would say true here');
  });

  test('a single day is a legal season', () {
    final christmas = item(from: 1225, to: 1225);
    expect(availableOn(christmas, on(12, 25)), isTrue);
    expect(availableOn(christmas, on(12, 24)), isFalse);
  });

  test('inactive beats in-season', () {
    expect(availableOn(item(active: false, from: 101, to: 1231), on(6, 1)),
        isFalse,
        reason: 'someone has stopped making it, whatever the calendar says');
  });

  test('a removed item is never available', () {
    expect(availableOn(item(deletedAt: 1), on(6, 1)), isFalse);
  });

  test('the reason is said, not implied', () {
    expect(unavailableReason(item(), on(6, 1)), isNull);
    expect(unavailableReason(item(active: false), on(6, 1)),
        'Not being made');
    expect(unavailableReason(item(from: 1101, to: 131), on(6, 1)),
        'Out of season until Nov');
    expect(unavailableReason(item(deletedAt: 1), on(6, 1)), 'Removed');
  });

  test('the season reads as a person would say it', () {
    expect(seasonLabel(item(from: 1101, to: 131)), 'Nov to Jan');
    expect(seasonLabel(item()), isNull);
  });
}
