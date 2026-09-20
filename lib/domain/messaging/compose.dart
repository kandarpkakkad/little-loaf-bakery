import '../../common/money.dart';
import '../../ui/theme/format.dart';
import '../invoicing/model.dart';
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
    this.upiId,
    this.paymentPhone,
    this.lastPayment,
    this.dropLines = const [],
    this.journeys = const [],
    this.isPickup = false,
    this.isUpdate = false,
    this.invoiceNo,
    this.frozen,
    this.voidedReason,
  });

  final String customerFirstName;
  final String orderNo;
  final OrderTotals totals;
  final List<OrderLine> lines;
  final String businessName;
  final String? deliveryDateLabel, deliveryTimeLabel, addressText;
  final String? trackingUrl;
  final String? upiId, paymentPhone;

  /// What was just handed over, when this message follows a payment.
  final Money? lastPayment;

  /// The lines this message is about, when it is about some of them rather
  /// than the whole order.
  ///
  /// A two-day order is two handovers, and one "your order has been delivered"
  /// on the Friday would be a lie about the Sunday box. Empty means the whole
  /// order, which is what a single-drop order always is.
  final List<OrderLine> dropLines;

  /// Every journey in this order: a day, a time, a way out and a place, with
  /// what travels on it. A message about the whole order reads this; a message
  /// about one handover reads [dropLines].
  ///
  /// Empty means the caller had none to give, and the message falls back to the
  /// single date and address it was handed.
  final List<SubOrder> journeys;

  /// Whether this handover was collected rather than delivered. Nothing
  /// "arrives" when the customer drove to the bakery for it.
  final bool isPickup;

  /// The order already existed and has changed — an item added, usually.
  /// The same listing, opening with what happened rather than pretending it is
  /// the first time the customer has seen it.
  final bool isUpdate;

  /// The invoice number, once one has been issued. Until then the document is
  /// quoted against the order number — it is a statement of what is owed, not
  /// yet a bill.
  final String? invoiceNo;

  /// The totals as they stood when the invoice was issued, once one has been.
  ///
  /// Null until then, and the document renders from live rows — at that point
  /// it is a statement of what is owed, not yet a bill.
  final FrozenTotals? frozen;

  /// Set when the invoice has been voided, so a copy resent by accident says
  /// so rather than looking current.
  final String? voidedReason;

  /// What the customer is still waiting for after this message: every line
  /// that is neither already handed over, nor cancelled, nor on this message.
  ///
  /// It is a question about **status**, not a count. Comparing the size of the
  /// drop against the size of the order announced the last cake of three as
  /// "part of your order has arrived", and subtracting only the current drop
  /// listed the two delivered on Friday as still to come on Sunday.
  List<OrderLine> get outstanding {
    // By id: the order is re-read after the move, so the lines on this message
    // are equal to those in `lines` but are not the same objects.
    final onThisMessage =
        dropLines.map((l) => l.id).whereType<String>().toSet();
    return [
      for (final l in lines)
        if (l.status != LineStatus.delivered &&
            l.status != LineStatus.cancelled &&
            !onThisMessage.contains(l.id))
          l,
    ];
  }

  /// True when something is still to come after this message.
  bool get isPartialDrop => dropLines.isNotEmpty && outstanding.isNotEmpty;
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

/// What is on this message: the lines being dropped, or all of them —
/// **never a cancelled one**.
///
/// Only `OrderTotals` filtered cancelled lines, so every listing disagreed
/// with the sum underneath it. On the invoice that was two ₹800 items over a
/// ₹800 subtotal: a bill the customer can add up, and it was wrong.
List<OrderLine> _subject(MessageContext c) =>
    [for (final l in c.dropLines.isEmpty ? c.lines : c.dropLines) if (l.isLive) l];

/// What an item is called, in one line. Shared with `_itemLines` so a cake
/// cannot be "Cake · Chocolate · 500 g" in one part of a message and a bare
/// "Cake" in the next — three outstanding cakes read "Cake, Cake, Cake" and
/// told the customer nothing.
String _itemLabel(OrderLine l) => [
      l.itemName,
      if (l.flavour != null) l.flavour!,
      if (l.weight != null) l.weight!.label,
    ].join(' · ');

/// The rest of the order, named so the customer knows nothing was forgotten.
String _stillToCome(MessageContext c) =>
    c.outstanding.map(_itemLabel).join(', ');

/// Each item, and what is particular to it.
///
/// The message, the requirements and the dietary flags sit under the item they
/// belong to rather than once at the bottom: an order of a piped birthday cake
/// and a plain box of buns has one message, and printing it under "your order"
/// left the customer to guess which one it was for.
List<String> _itemLines(MessageContext c) => _linesOf(_subject(c));

List<String> _linesOf(Iterable<OrderLine> lines) => [
      for (final l in lines) ...[
        '${_itemLabel(l)} × ${l.qty}',
        if (l.addons.isNotEmpty)
          '  + ${l.addons.map((a) => a.name).join(', ')}',
        if (l.itemMessage != null) '  Piped: "${l.itemMessage}"',
        if (l.requirements != null) '  ${l.requirements}',
        if (dietaryLabels(l.dietaryFlags).isNotEmpty)
          '  ${dietaryLabels(l.dietaryFlags).join(', ')}',
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

/// The journeys worth naming: live, and with something on them.
List<SubOrder> _liveJourneys(MessageContext c) => [
      for (final j in c.journeys)
        if (j.isLive && j.liveLines.isNotEmpty) j,
    ]..sort((a, b) => a.deliveryDate.compareTo(b.deliveryDate));

/// "Fri 22 Sep, 4:00 pm". The time is dropped when there is none rather than
/// printed as "Any time", which is a thing to show the baker, not the customer.
String _when(int date, int? time) =>
    [dayLabel(date), if (time != null) timeLabel(time)].join(', ');

/// One heading per journey, with what travels on it underneath.
///
/// An order can be two handovers on two days to two places. Quoting one date
/// over a list of everything told a customer expecting a cake on Friday that
/// their order was coming on Sunday.
List<String> _journeySections(List<SubOrder> journeys) => [
      for (final j in journeys) ...[
        '',
        '*${j.isPickup ? 'Collect' : 'Delivery'}: '
            '${_when(j.deliveryDate, j.deliveryTime)}*',
        if (!j.isPickup && j.addressText != null) j.addressText!,
        ..._linesOf(j.liveLines),
      ],
    ];

/// When and where, for an order that is a single handover — the common case,
/// which keeps the shape it always had rather than growing a heading.
List<String> _whenAndWhere(MessageContext c, SubOrder? only) {
  final pickup = only?.isPickup ?? c.isPickup;
  final label = pickup ? 'Collect' : 'Delivery';
  final address = only == null ? c.addressText : only.addressText;
  return [
    if (only != null)
      '$label: ${_when(only.deliveryDate, only.deliveryTime)}'
    else if (c.deliveryDateLabel != null)
      '$label: ${c.deliveryDateLabel}'
          '${c.deliveryTimeLabel != null ? ', ${c.deliveryTimeLabel}' : ''}',
    // Nothing to show a customer who is coming to fetch it themselves.
    if (!pickup && address != null) address,
  ];
}

String _confirmation(MessageContext c) {
  final journeys = _liveJourneys(c);
  final grouped = journeys.length > 1;
  return [
    if (c.isUpdate)
      'Hi ${c.customerFirstName}, your order has been updated 🍞'
    else
      'Hi ${c.customerFirstName}, your order with ${c.businessName} is confirmed 🍞',
    '',
    'Order: ${c.orderNo}',
    if (grouped)
      ..._journeySections(journeys)
    else ...[
      ..._itemLines(c),
      '',
      ..._whenAndWhere(c, journeys.isEmpty ? null : journeys.first),
    ],
    '',
    _moneyLine(c),
    '',
    'Please check the details above and tell us if anything is wrong.',
  ].join('\n');
}

/// Deliberately bare. The customer wants the link, not a restatement.
///
/// [MessageContext.trackingUrl] is the **moving journey's** link. The order
/// caches one too, but it is the finishing journey's — sending Friday's van
/// off quoted the link for Sunday's.
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
  // Nothing "arrives" when the customer came and fetched it.
  final landed = c.isPickup ? 'been collected' : 'arrived';
  return [
    if (c.isPartialDrop)
      'Hi ${c.customerFirstName}, part of your order has $landed 🎂'
    else if (c.isPickup)
      'Hi ${c.customerFirstName}, your order has been collected 🎂'
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
    ] else if (c.isPartialDrop)
      'We will let you know when the rest is on its way. Thank you for '
          'ordering from ${c.businessName}.'
    else
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
  final f = c.frozen;
  final mono = <String>[];

  // An invoice is a statement about a moment. Once issued it renders from the
  // snapshot taken then, so cancelling an item or editing a price cannot
  // rewrite a document the customer is already holding — which is what this
  // function did for as long as it read live rows, under the original number.
  // The snapshot was being written on issue and read by nothing but tests.
  // docs/02-domain/invoicing/lld.md §3.
  if (f != null) {
    for (final l in f.lines) {
      mono.add(l.name); // own line — may wrap harmlessly
      if (l.detail != null) mono.add(l.detail!);
      mono.add(_row('  ${l.qty} x ${moneyPlain(l.unitPrice)}', l.total));
      for (final a in l.addons) {
        mono.add(_row('  + ${a.name}', a.price));
      }
    }
  } else {
    // No invoice yet: the same layout, showing what is currently owed. Live
    // lines only — `OrderTotals` has always excluded cancelled ones, so
    // itemising them here put two ₹800 rows above an ₹800 subtotal.
    for (final l in c.lines.where((l) => l.isLive)) {
      mono.add(l.itemName);
      final sub = [
        if (l.flavour != null) l.flavour!,
        if (l.weight != null) l.weight!.label,
      ];
      if (sub.isNotEmpty) mono.add(sub.join(' · '));
      mono.add(
          _row('  ${l.qty} x ${moneyPlain(l.basePrice)}', l.basePrice.times(l.qty)));
      for (final a in l.addons) {
        mono.add(_row('  + ${a.name}', a.price));
      }
    }
  }

  final discount = f?.discount ?? t.discount;
  final delivery = f?.delivery ?? t.deliveryCharge;
  final total = f?.total ?? t.total;
  // Payments are deliberately NOT frozen. Money that arrived after the bill
  // was issued is real, and a balance quoted from the snapshot would ask the
  // customer to pay what they have already paid.
  final balance = total - t.paid;

  mono.add('-' * kMonoWidth);
  mono.add(_row('Subtotal', f?.subtotal ?? t.subtotal));
  // a zero row is absent, never printed as zero
  if (!discount.isZero) {
    mono.add(_row(
        f?.discountLabel ??
            (t.discountType == DiscountType.percent
                ? 'Discount ${t.discountValue ~/ 100}%'
                : 'Discount'),
        -discount));
  }
  if (!delivery.isZero) mono.add(_row('Delivery', delivery));
  mono.add(_row('TOTAL', total));

  if (balance.isZero) {
    mono.add(_row('PAID · thank you', Money.zero, suffix: ''));
  } else if (!t.paid.isZero) {
    mono.add(_row('Advance paid', t.paid));
    mono.add(_row('BALANCE DUE', balance));
  } else {
    mono.add(_row('AMOUNT DUE', balance));
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
