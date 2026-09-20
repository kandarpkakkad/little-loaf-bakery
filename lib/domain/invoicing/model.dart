import '../../common/money.dart';

/// The totals as they were when the invoice was issued.
///
/// An invoice is a statement about a moment. Recomputing it later from live
/// rows would let a cancelled item or an edited price silently rewrite a
/// document the customer already has — so the numbers are copied, not
/// referenced. docs/02-domain/invoicing/lld.md §3
class FrozenTotals {
  const FrozenTotals({
    required this.lines,
    required this.subtotal,
    required this.discount,
    required this.delivery,
    required this.total,
    this.discountLabel,
  });

  final List<FrozenLine> lines;
  final Money subtotal;
  final Money discount;
  final Money delivery;
  final Money total;

  /// "Discount 10%" or "Discount" — the percentage is resolved to an amount at
  /// issue, but *how it was agreed* is worth keeping.
  final String? discountLabel;

  Map<String, Object?> toJson() => {
        'lines': [for (final l in lines) l.toJson()],
        'subtotal': subtotal.paise,
        'discount': discount.paise,
        'delivery': delivery.paise,
        'total': total.paise,
        'discount_label': discountLabel,
      };

  static FrozenTotals fromJson(Map<String, Object?> j) => FrozenTotals(
        lines: [
          for (final l in (j['lines'] as List? ?? const []))
            FrozenLine.fromJson(Map<String, Object?>.from(l as Map)),
        ],
        subtotal: Money((j['subtotal'] as num?)?.toInt() ?? 0),
        discount: Money((j['discount'] as num?)?.toInt() ?? 0),
        delivery: Money((j['delivery'] as num?)?.toInt() ?? 0),
        total: Money((j['total'] as num?)?.toInt() ?? 0),
        discountLabel: j['discount_label'] as String?,
      );
}

class FrozenLine {
  const FrozenLine({
    required this.name,
    required this.qty,
    required this.unitPrice,
    required this.total,
    this.detail,
    this.addons = const [],
  });

  final String name;

  /// Flavour and weight, already joined — the invoice does not need to know
  /// they were separate columns.
  final String? detail;
  final int qty;
  final Money unitPrice;
  final Money total;
  final List<({String name, Money price})> addons;

  Map<String, Object?> toJson() => {
        'name': name,
        'detail': detail,
        'qty': qty,
        'unit_price': unitPrice.paise,
        'total': total.paise,
        'addons': [
          for (final a in addons) {'name': a.name, 'price': a.price.paise},
        ],
      };

  static FrozenLine fromJson(Map<String, Object?> j) => FrozenLine(
        name: j['name'] as String,
        detail: j['detail'] as String?,
        qty: (j['qty'] as num?)?.toInt() ?? 1,
        unitPrice: Money((j['unit_price'] as num?)?.toInt() ?? 0),
        total: Money((j['total'] as num?)?.toInt() ?? 0),
        addons: [
          for (final a in (j['addons'] as List? ?? const []))
            (
              name: (a as Map)['name'] as String,
              price: Money((a['price'] as num?)?.toInt() ?? 0),
            ),
        ],
      );
}
