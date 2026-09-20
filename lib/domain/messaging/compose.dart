import '../../common/money.dart';
import '../../ui/theme/format.dart';
import '../orders/model.dart';

enum MessageKind { confirmation, outForDelivery, delivery, paymentReceived, invoice }

/// What the app needs to write a message. Deliberately a plain value object —
/// composition is pure, so every variant is testable without a database.
class MessageContext {
  const MessageContext({
    required this.customerFirstName,
    required this.orderNo,
    required this.totals,
    required this.lines,
    required this.businessName,
    this.deliveryDateLabel,
    this.deliveryTimeLabel,
    this.addressText,
    this.trackingUrl,
    this.itemMessage,
    this.requirements,
    this.upiId,
    this.paymentPhone,
    this.hadBalance = false,
    this.lastPayment,
    this.dropLines = const [],
    this.isUpdate = false,
    this.invoiceNo,
    this.voidedReason,
  });

  final String customerFirstName;
  final String orderNo;
  final OrderTotals totals;
  final List<OrderLine> lines;
  final String businessName;
  final String? deliveryDateLabel, deliveryTimeLabel, addressText;
  final String? trackingUrl, itemMessage, requirements;
  final String? upiId, paymentPhone;

  /// Whether a balance existed *before* the final payment — by the time
  /// Completed is reached the balance is zero by definition.
  final bool hadBalance;

  /// What was just handed over, when this message follows a payment.
  final Money? lastPayment;

  /// The lines this message is about, when it is about some of them rather
  /// than the whole order.
  ///
  /// A two-day order is two handovers, and one "your order has been delivered"
  /// on the Friday would be a lie about the Sunday box. Empty means the whole
  /// order, which is what a single-drop order always is.
  final List<OrderLine> dropLines;

  /// The order already existed and has changed — an item added, usually.
  /// The same listing, opening with what happened rather than pretending it is
  /// the first time the customer has seen it.
  final bool isUpdate;

  /// The invoice number, once one has been issued. Until then the document is
  /// quoted against the order number — it is a statement of what is owed, not
  /// yet a bill.
  final String? invoiceNo;

  /// Set when the invoice has been voided, so a copy resent by accident says
  /// so rather than looking current.
  final String? voidedReason;

  /// True when this message covers only part of the order.
  bool get isPartialDrop =>
      dropLines.isNotEmpty && dropLines.length < lines.length;
}

/// Whether a message is offered at all. Two of the four are conditional.
bool isOffered(MessageKind kind, MessageContext c) => switch (kind) {
      MessageKind.confirmation => true,
      // the link is what the message is *for*
      MessageKind.outForDelivery => c.trackingUrl != null && c.trackingUrl!.isNotEmpty,
      MessageKind.delivery => true,
      // they know what they paid — and if there was never a balance, the
      // delivery message already thanked them
      // Every payment earns a receipt, partial or final. The old rule —
      // only when a balance existed — never fired for a part payment at
      // all, because the order sits at the same status before and after.
      MessageKind.paymentReceived => true,
      MessageKind.invoice => true,
    };

String compose(MessageKind kind, MessageContext c) => switch (kind) {
      MessageKind.confirmation => _confirmation(c),
      MessageKind.outForDelivery => _onItsWay(c),
      MessageKind.delivery => _delivery(c),
      MessageKind.paymentReceived => _paymentReceived(c),
      MessageKind.invoice => _invoice(c),
    };

/// What is on this message: the lines being dropped, or all of them.
List<OrderLine> _subject(MessageContext c) =>
    c.dropLines.isEmpty ? c.lines : c.dropLines;

/// The rest of the order, named so the customer knows nothing was forgotten.
String _stillToCome(MessageContext c) {
  final dropped = _subject(c).toSet();
  final rest = c.lines.where((l) => !dropped.contains(l)).map((l) => l.itemName);
  return rest.join(', ');
}

List<String> _itemLines(MessageContext c) => [
      for (final l in _subject(c)) ...[
        '${[
          l.itemName,
          if (l.flavour != null) l.flavour!,
          if (l.weight != null) l.weight!.label,
        ].join(' · ')} × ${l.qty}',
        if (l.addons.isNotEmpty)
          '  + ${l.addons.map((a) => a.name).join(', ')}',
      ],
    ];

/// The money line, built by **dropping clauses rather than printing zeros**.
///
/// `money()` returns null when an amount is zero — that is the "zero never
/// shows" rule (D10) — so interpolating it directly puts the literal word
/// "null" in front of a customer. It did: "Paid null", and "Balance due null"
/// on any order paid in full. Every amount here goes through [_clause], which
/// omits itself when there is nothing to say.
String _moneyLine(MessageContext c) {
  final t = c.totals;
  return [
    // The total always prints, even at ₹0 — an order with no total is a fact
    // worth stating, not one to hide.
    'Total ${money(t.total, showZero: true)}',
    if (t.paid.isZero)
      ..._clause('Payable on delivery', t.total)
    else ...[
      ..._clause('Advance received', t.paid),
      ..._clause('Balance due', t.balanceDue),
    ],
  ].join(' · ');
}

/// `['Label ₹500']`, or nothing at all when the amount is zero.
List<String> _clause(String label, Money amount) {
  final text = money(amount);
  return text == null ? const [] : ['$label $text'];
}

String _confirmation(MessageContext c) => [
      if (c.isUpdate)
        'Hi ${c.customerFirstName}, your order has been updated 🍞'
      else
        'Hi ${c.customerFirstName}, your order with ${c.businessName} is confirmed 🍞',
      '',
      'Order: ${c.orderNo}',
      ..._itemLines(c),
      if (c.itemMessage != null) 'Message on item: "${c.itemMessage}"',
      if (c.requirements != null) 'Notes: ${c.requirements}',
      '',
      if (c.deliveryDateLabel != null)
        'Delivery: ${c.deliveryDateLabel}'
            '${c.deliveryTimeLabel != null ? ', ${c.deliveryTimeLabel}' : ''}',
      if (c.addressText != null) c.addressText!,
      '',
      _moneyLine(c),
      '',
      'Please check the details above and tell us if anything is wrong.',
    ].join('\n');

/// Deliberately bare. The customer wants the link, not a restatement.
String _onItsWay(MessageContext c) => [
      'Hi ${c.customerFirstName}, your order is on its way 🚚',
      '',
      'Order: ${c.orderNo}',
      'Track it here: ${c.trackingUrl}',
      '',
      '— ${c.businessName}',
    ].join('\n');

List<String> _payLines(MessageContext c) => [
      if (c.upiId != null) 'Pay by UPI to ${c.upiId}',
      if (c.paymentPhone != null)
        '${c.upiId != null ? 'or to ' : 'Pay by UPI to '}${c.paymentPhone}',
    ];

/// One function, two shapes. It always goes out — a customer who has just
/// received a cake should hear from the bakery. When money is owed it carries
/// the balance; when nothing is owed those lines are simply absent.
String _delivery(MessageContext c) {
  final owed = c.totals.balanceDue;
  // Money is the whole order's (D27), so it is only quoted once everything has
  // arrived. Asking for the balance while a box is still to come reads as a
  // demand for something not yet delivered.
  final owes = owed.paise > 0 && !c.isPartialDrop;
  return [
    if (c.isPartialDrop)
      'Hi ${c.customerFirstName}, part of your order has arrived 🎂'
    else
      'Hi ${c.customerFirstName}, your order has been delivered 🎂',
    '',
    'Order: ${c.orderNo}',
    ..._itemLines(c),
    if (c.isPartialDrop) ...[
      '',
      'Still to come: ${_stillToCome(c)}',
    ],
    '',
    if (owes) ...[
      [
        'Total ${money(c.totals.total, showZero: true)}',
        ..._clause('Paid', c.totals.paid),
      ].join(' · '),
      '*Balance due ${money(owed, showZero: true)}*',
      '',
      ..._payLines(c),
      if (_payLines(c).isNotEmpty) '',
      'Thank you for ordering from ${c.businessName}',
    ] else
      'Thank you for ordering from ${c.businessName}. We hope you enjoyed it — '
          'we would love to bake for you again.',
  ].join('\n');
}

/// No amount, no summary. They know what they paid, because they just paid it.
/// Offered after **every** payment, including a partial one, and it says what
/// is still owed. A receipt that omits the balance invites the question it was
/// meant to prevent — and a part payment is exactly when the customer is least
/// sure where they stand.
String _paymentReceived(MessageContext c) {
  final owed = c.totals.balanceDue;
  return [
    if (c.lastPayment != null)
      'Hi ${c.customerFirstName}, we have received '
          '${money(c.lastPayment!, showZero: true)}. Thank you!'
    else
      'Hi ${c.customerFirstName}, we have received your payment. Thank you!',
    '',
    'Order: ${c.orderNo}',
    if (owed.paise > 0) 'Still to pay: ${money(owed, showZero: true)}',
    if (owed.isZero) 'That settles it — paid in full.',
    if (owed.paise < 0)
      'That leaves ${money(Money(-owed.paise), showZero: true)} to refund to you.',
    '',
    '— ${c.businessName}',
  ].join('\n');
}

// ── the invoice, as a formatted message ──────────────────────────────────

/// Every line stays within this width, and amounts right-align to it.
/// WhatsApp's monospace block **wraps rather than scrolls**, and a wrapped line
/// destroys the alignment that made it readable.
const int kMonoWidth = 26;

String _row(String label, Money amount, {String? suffix}) {
  final r = moneyPlain(amount) + (suffix ?? '');
  final room = kMonoWidth - r.length;
  final l = label.length > room ? label.substring(0, room) : label;
  return l.padRight(room) + r;
}

String _invoice(MessageContext c) {
  final t = c.totals;
  final mono = <String>[];

  for (final l in c.lines) {
    mono.add(l.itemName); // own line — may wrap harmlessly
    final sub = [
      if (l.flavour != null) l.flavour!,
      if (l.weight != null) l.weight!.label,
    ];
    if (sub.isNotEmpty) mono.add(sub.join(' · '));
    mono.add(_row('  ${l.qty} x ${moneyPlain(l.basePrice)}', l.basePrice.times(l.qty)));
    for (final a in l.addons) {
      mono.add(_row('  + ${a.name}', a.price));
    }
  }

  mono.add('-' * kMonoWidth);
  mono.add(_row('Subtotal', t.subtotal));
  // a zero row is absent, never printed as zero
  if (!t.discount.isZero) {
    final label = t.discountType == DiscountType.percent
        ? 'Discount ${t.discountValue ~/ 100}%'
        : 'Discount';
    mono.add(_row(label, -t.discount));
  }
  if (!t.deliveryCharge.isZero) mono.add(_row('Delivery', t.deliveryCharge));
  mono.add(_row('TOTAL', t.total));

  if (t.balanceDue.isZero) {
    mono.add(_row('PAID · thank you', Money.zero, suffix: ''));
  } else if (!t.paid.isZero) {
    mono.add(_row('Advance paid', t.paid));
    mono.add(_row('BALANCE DUE', t.balanceDue));
  } else {
    mono.add(_row('AMOUNT DUE', t.balanceDue));
  }

  return [
    '*${c.businessName}*',
    '',
    if (c.voidedReason != null) ...[
      '*VOIDED* — ${c.voidedReason}',
      'This bill no longer stands.',
      '',
    ],
    '*Bill of Supply*',
    // The invoice number once there is one; the order number until then.
    c.invoiceNo ?? c.orderNo,
    '',
    'To: ${c.customerFirstName}',
    '',
    '```',
    ...mono,
    '```',
    '',
    if (!t.balanceDue.isZero) ..._payLines(c),
  ].join('\n');
}

/// `https://wa.me/919876543210?text=…` — WhatsApp's documented Click-to-Chat.
/// It opens that exact chat with the text pre-filled, and takes no attachment.
Uri waMeUri({required String phoneE164, required String text}) => Uri.parse(
      'https://wa.me/${waMeNumber(phoneE164)}'
      '?text=${Uri.encodeComponent(text)}',
    );

/// Digits only, no plus.
///
/// Stripping just the '+' was not enough: a number saved as "+91 98765 43210"
/// kept its spaces, and wa.me answers a malformed number with a search screen
/// that spins and then fails — which looks like WhatsApp being broken rather
/// than the link being wrong.
String waMeNumber(String phoneE164) =>
    phoneE164.replaceAll(RegExp(r'[^0-9]'), '');

/// Whether a number can be messaged at all.
///
/// wa.me needs the **full international** number. A bare ten-digit local number
/// resolves for the one person whose phone already knows it — the owner's own —
/// and fails for everybody else, which is a confusing way to find out the
/// country code is missing. Better to say so before opening WhatsApp.
bool canMessage(String phoneE164) {
  final digits = waMeNumber(phoneE164);
  return phoneE164.trim().startsWith('+') &&
      digits.length >= 11 &&
      digits.length <= 15;
}
