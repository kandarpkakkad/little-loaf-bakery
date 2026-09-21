import 'package:flutter/material.dart';

import '../../../app/scope.dart';
import '../../../common/money.dart';
import '../../../domain/orders/repository.dart';
import '../../../domain/reporting/repository.dart';
import '../orders/order_card.dart';
import '../orders/order_detail_screen.dart';
import '../../theme/breakpoints.dart';
import '../../theme/format.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/forms.dart';
import '../../widgets/line_chart.dart';
import '../../widgets/primitives.dart';

/// What the month looked like.
///
/// Four questions, in the order they get asked: how much came in, what is
/// still to come, what sells, and what the shelf is worth. Anything else is a
/// spreadsheet, and this app is not one.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Future<_Report>? _future;

  /// Which month is being looked at. Starts on this one.
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  /// How far back the charts reach. Six months by default — long enough to
  /// show a season, short enough that each month is still a readable step.
  int _range = 6;
  Future<List<OrderView>>? _monthOrders;
  DateTime? _earliest;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  void _setRange(int months) {
    setState(() {
      _range = months;
      _future = _load();
    });
  }

  void _showMonth(DateTime m) {
    setState(() {
      _month = m;
      _monthOrders = context.app.reports.ordersIn(m.year, m.month);
    });
  }

  Future<_Report> _load() async {
    final r = context.app.reports;
    _earliest = await r.firstMonth();
    _monthOrders = r.ordersIn(_month.year, _month.month);
    return _Report(
      months: await r.salesByMonth(months: _range),
      products: await r.byProduct(),
      outstanding: await r.outstanding(),
      credit: await r.credit(),
      stock: await r.stockValue(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.paper,
      appBar: AppBar(title: const Text('Reports')),
      body: ContentWidth(
        max: 760,
        child: FutureBuilder<_Report>(
          future: _future,
          builder: (context, snap) {
            final r = snap.data;
            if (r == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (r.months.isEmpty && r.outstanding.isZero) {
              return const EmptyState(
                icon: Icons.insights_outlined,
                message: 'Nothing to report yet.\nDeliver an order and it '
                    'appears here.',
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                  Space.lg, Space.md, Space.lg, Space.xxl),
              children: [
                // Over time first, then the month you are standing in.
                _Trend(months: r.months, range: _range, onRange: _setRange),

                _MonthBar(
                  month: _month,
                  earliest: _earliest,
                  onChange: _showMonth,
                ),
                _MonthFigures(months: r.months, month: _month),
                _MonthOrders(
                  month: _month,
                  future: _monthOrders,
                  onOpen: (v) => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(orderId: v.order.id))),
                ),

                if (!r.outstanding.isZero || !r.credit.isZero) ...[
                  const SectionLabel('Money'),
                  LoafCard(
                    child: Column(
                      children: [
                        if (!r.outstanding.isZero)
                          MoneyRow('Still to collect', r.outstanding,
                              strong: true),
                        // Shown apart from what is owed, because it runs the
                        // other way: this is money to give back.
                        if (!r.credit.isZero)
                          MoneyRow('To refund', r.credit, strong: true),
                      ],
                    ),
                  ),
                ],

                const SectionLabel('By month'),
                LoafCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < r.months.length; i++) ...[
                        if (i > 0) Divider(height: 1, color: c.ruleSoft),
                        // Tapping a month up here moves the view at the top
                        // to it, so the overview and the detail are one thing
                        // rather than two ways of asking the same question.
                        _MonthRow(
                          month: r.months[i],
                          onTap: () => _showMonth(
                              DateTime.fromMillisecondsSinceEpoch(
                                  r.months[i].month)),
                        ),
                      ],
                    ],
                  ),
                ),

                if (r.products.isNotEmpty) ...[
                  const SectionLabel('What sells'),
                  LoafCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < r.products.length; i++) ...[
                          if (i > 0) Divider(height: 1, color: c.ruleSoft),
                          ListTile(
                            dense: true,
                            title: Text(r.products[i].name),
                            subtitle: Micro('${r.products[i].qty} sold'),
                            trailing: Text(
                                money(r.products[i].revenue, showZero: true)!,
                                style: context.text.bodyLarge),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                if (r.stock.isNotEmpty) ...[
                  const SectionLabel('What the shelf is worth'),
                  LoafCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < r.stock.length; i++) ...[
                          if (i > 0) Divider(height: 1, color: c.ruleSoft),
                          ListTile(
                            dense: true,
                            title: Text(r.stock[i].name),
                            subtitle: Micro(_qty(r.stock[i].onHand)),
                            trailing: Text(
                              // Never valued at zero when the price is simply
                              // unknown — that would read as worthless.
                              r.stock[i].value == null
                                  ? 'price unknown'
                                  : money(r.stock[i].value!, showZero: true)!,
                              style: context.text.bodyMedium!.copyWith(
                                color: r.stock[i].value == null ? c.ink3 : null,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  static String _qty(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}

class _MonthRow extends StatelessWidget {
  const _MonthRow({required this.month, this.onTap});

  final MonthOfSales month;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final d = DateTime.fromMillisecondsSinceEpoch(month.month);
    return ListTile(
      onTap: onTap,
      title: Text(monthYear(d)),
      subtitle: Micro('${month.orders} order${month.orders == 1 ? '' : 's'}'
          '${month.outstanding.isZero ? '' : ' · ${money(month.outstanding)} still to collect'}'),
      trailing: Text(money(month.revenue, showZero: true)!,
          style: context.text.titleMedium!
              .copyWith(color: context.colors.accent2)),
    );
  }
}

class _Report {
  const _Report({
    required this.months,
    required this.products,
    required this.outstanding,
    required this.credit,
    required this.stock,
  });

  final List<MonthOfSales> months;
  final List<ProductSales> products;
  final Money outstanding;
  final Money credit;
  final List<StockValue> stock;
}

/// Which month is being looked at, and the way back through the others.
///
/// Arrows for the month either side, because "last month" is the common ask
/// and one tap should answer it. The label itself opens a picker for anything
/// further back, and neither can leave the range that has orders in it —
/// paging into empty years reads as a broken screen.
/// Orders and money over time, and how far back to look.
///
/// **Two charts, not two lines on one.** A count of orders and a pile of
/// rupees are different kinds of measure: share an axis and the orders line
/// lies flat along the bottom, give them an axis each and the shape of the
/// correlation becomes whatever you pinned the scales to. Stacked over one
/// month axis, both are readable and neither is asserting anything about the
/// other that is not there.
class _Trend extends StatelessWidget {
  const _Trend({required this.months, required this.range, required this.onRange});

  final List<MonthOfSales> months;
  final int range;
  final ValueChanged<int> onRange;

  static const _ranges = <int, String>{
    3: '3 months',
    6: '6 months',
    12: '1 year',
    24: '2 years',
    36: '3 years',
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (months.isEmpty) return const SizedBox.shrink();

    final labels = [for (final m in months) _short(m.month)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Space.sm),
          child: Row(
            children: [
              Expanded(
                child: Text('Over time', style: context.text.titleMedium),
              ),
              DropdownButton<int>(
                value: range,
                underline: const SizedBox.shrink(),
                items: [
                  for (final e in _ranges.entries)
                    DropdownMenuItem(value: e.key, child: Text(e.value)),
                ],
                onChanged: (v) => onRange(v ?? 6),
              ),
            ],
          ),
        ),
        LoafCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Orders',
                  style: context.text.bodySmall!.copyWith(color: c.ink3)),
              LineChart(
                values: [for (final m in months) m.orders.toDouble()],
                labels: labels,
                format: (v) => '${v.round()}',
              ),
              const SizedBox(height: Space.lg),
              Text('Order value',
                  style: context.text.bodySmall!.copyWith(color: c.ink3)),
              LineChart(
                values: [for (final m in months) m.revenue.paise / 100],
                labels: labels,
                format: (v) => money(Money.rupees(v), showZero: true)!,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The month you are standing in, in three figures.
class _MonthFigures extends StatelessWidget {
  const _MonthFigures({required this.months, required this.month});

  final List<MonthOfSales> months;
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final key = month.millisecondsSinceEpoch;
    final m = months.where((x) => x.month == key).firstOrNull;

    return Padding(
      padding: const EdgeInsets.only(bottom: Space.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Figure(label: 'Orders', value: '${m?.orders ?? 0}'),
          _Figure(
              label: 'Order value',
              value: money(m?.revenue ?? Money.zero, showZero: true)!),
          // Kept beside the other two rather than under "Money", because what
          // a month earned and what is still owed on it are one question.
          _Figure(
              label: 'Pending',
              value: money(m?.outstanding ?? Money.zero, showZero: true)!,
              muted: (m?.outstanding ?? Money.zero).isZero),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value, this.muted = false});

  final String label;
  final String value;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.text.bodySmall!.copyWith(color: c.ink3)),
          const SizedBox(height: 2),
          Text(value,
              style: context.text.titleMedium!
                  .copyWith(color: muted ? c.ink3 : c.ink)),
        ],
      ),
    );
  }
}

/// "Sep", or "Sep 25" when the range crosses a year.
String _short(int ms) {
  const names = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  final thisYear = DateTime.now().year;
  return d.year == thisYear
      ? names[d.month - 1]
      : '${names[d.month - 1]} ${d.year % 100}';
}

class _MonthBar extends StatelessWidget {
  const _MonthBar({
    required this.month,
    required this.earliest,
    required this.onChange,
  });

  final DateTime month;
  final DateTime? earliest;
  final ValueChanged<DateTime> onChange;

  DateTime get _latest {
    final n = DateTime.now();
    return DateTime(n.year, n.month);
  }

  bool get _canGoBack =>
      earliest == null || month.isAfter(earliest!);
  bool get _canGoForward => month.isBefore(_latest);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: Space.md),
        child: Row(
          children: [
            IconButton(
              onPressed: _canGoBack
                  ? () => onChange(DateTime(month.year, month.month - 1))
                  : null,
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Previous month',
            ),
            Expanded(
              child: TextButton(
                onPressed: () => _pick(context),
                child: Text(monthYear(month), style: context.text.titleMedium),
              ),
            ),
            IconButton(
              onPressed: _canGoForward
                  ? () => onChange(DateTime(month.year, month.month + 1))
                  : null,
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Next month',
            ),
          ],
        ),
      );

  Future<void> _pick(BuildContext context) async {
    final first = earliest ?? _latest;
    final months = <DateTime>[];
    for (var m = _latest;
        !m.isBefore(first);
        m = DateTime(m.year, m.month - 1)) {
      months.add(m);
    }

    final picked = await loafSheet<DateTime>(
      context,
      builder: (sheet) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final m in months)
              ListTile(
                title: Text(monthYear(m)),
                selected: m == month,
                onTap: () => Navigator.pop(sheet, m),
              ),
          ],
        ),
      ),
    );
    if (picked != null) onChange(picked);
  }
}

/// What one month held: how many orders, what they came to, and which ones.
class _MonthOrders extends StatelessWidget {
  const _MonthOrders({
    required this.month,
    required this.future,
    required this.onOpen,
  });

  final DateTime month;
  final Future<List<OrderView>>? future;
  final ValueChanged<OrderView> onOpen;

  @override
  Widget build(BuildContext context) => FutureBuilder<List<OrderView>>(
        future: future,
        builder: (context, snap) {
          final list = snap.data;
          if (list == null) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: Space.xl),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (list.isEmpty) {
            return LoafCard(
              child: Text('No orders due in ${monthYear(month)}.',
                  style: context.text.bodyMedium!
                      .copyWith(color: context.colors.ink3)),
            );
          }

          final value = list.fold(
              Money.zero, (Money a, OrderView v) => a + v.totals.total);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LoafCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Micro('Orders'),
                          Text('${list.length}',
                              style: context.text.headlineSmall),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Micro('Total value'),
                          Text(money(value, showZero: true)!,
                              style: context.text.headlineSmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Space.sm),
              for (final v in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.sm),
                  child: OrderCard(
                      view: v, showDate: true, onTap: () => onOpen(v)),
                ),
            ],
          );
        },
      );
}

/// "September 2026" — a month a person would say out loud.
String monthYear(DateTime d) {
  const names = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return '${names[d.month - 1]} ${d.year}';
}
