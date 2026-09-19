import 'package:flutter/material.dart';

import '../../../app/scope.dart';
import '../../../common/money.dart';
import '../../../domain/reporting/repository.dart';
import '../../theme/breakpoints.dart';
import '../../theme/format.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/forms.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<_Report> _load() async {
    final r = context.app.reports;
    return _Report(
      months: await r.salesByMonth(),
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
                        _MonthRow(month: r.months[i]),
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
  const _MonthRow({required this.month});

  final MonthOfSales month;

  @override
  Widget build(BuildContext context) {
    final d = DateTime.fromMillisecondsSinceEpoch(month.month);
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return ListTile(
      title: Text('${names[d.month - 1]} ${d.year}'),
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
