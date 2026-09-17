/// Integer paise. Never a double, at any layer.
///
/// See docs/01-platform/storage/schema.md — "Money | INTEGER paise".
extension type const Money(int paise) implements Object {
  static const zero = Money(0);

  factory Money.rupees(num r) => Money((r * 100).round());

  Money operator +(Money o) => Money(paise + o.paise);
  Money operator -(Money o) => Money(paise - o.paise);
  Money operator -() => Money(-paise);
  Money times(int n) => Money(paise * n);

  bool operator <(Money o) => paise < o.paise;
  bool operator >(Money o) => paise > o.paise;
  bool operator <=(Money o) => paise <= o.paise;
  bool operator >=(Money o) => paise >= o.paise;

  bool get isZero => paise == 0;
  bool get isNegative => paise < 0;
  Money get abs => Money(paise.abs());

  /// A percentage of this amount, in basis points, **rounded half-up to the
  /// nearest rupee** so no invoice ever carries stray paise.
  ///
  /// 10% of ₹1,890 → 18900000 bp-paise → ₹189.00 exactly.
  Money percent(int basisPoints) {
    final exactPaise = paise * basisPoints / 10000;
    final rupees = (exactPaise / 100).round(); // half-up via Dart's round()
    return Money(rupees * 100);
  }

  /// Clamps to a lower bound of zero. Used where a total must never go negative.
  Money clampAtZero() => paise < 0 ? zero : this;
}
