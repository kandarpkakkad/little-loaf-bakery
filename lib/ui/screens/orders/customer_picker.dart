import 'package:flutter/material.dart';
import '../../../common/phone.dart';

import '../../../app/scope.dart';
import '../../../platform/storage/database.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/primitives.dart';
import '../../widgets/forms.dart';

/// Search the people who have ordered before, by name or number.
///
/// The order form can still type a new customer straight in — this is the
/// shortcut for the ones already known, not a gate in front of them.
Future<Customer?> pickCustomer(BuildContext context) =>
    loafSheet<Customer>(
      context,
      builder: (_) => const _CustomerSheet(),
    );

class _CustomerSheet extends StatefulWidget {
  const _CustomerSheet();

  @override
  State<_CustomerSheet> createState() => _CustomerSheetState();
}

class _CustomerSheetState extends State<_CustomerSheet> {
  final _term = TextEditingController();
  List<Customer>? _results;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _term.dispose();
    super.dispose();
  }

  /// An empty term lists everyone, so opening the sheet already shows something
  /// to tap rather than an empty box waiting to be typed into.
  Future<void> _search(String term) async {
    // Resolved before the await: reaching through context afterwards is what
    // the async-gap lint is about.
    final repo = context.app.customers;
    final found = await repo.search(term.trim());
    if (mounted) setState(() => _results = found);
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Padding(
      padding: EdgeInsets.only(
        left: Space.lg,
        right: Space.lg,
        top: Space.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + Space.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Existing customer', style: context.text.titleMedium),
          const SizedBox(height: Space.lg),
          TextField(
            controller: _term,
            autofocus: true,
            onChanged: _search,
            decoration: const InputDecoration(
              labelText: 'Search',
              hintText: 'Name or number',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: Space.md),
          if (results == null)
            const Padding(
              padding: EdgeInsets.all(Space.xl),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (results.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: Space.xl),
              child: EmptyState(
                icon: Icons.person_search_outlined,
                message: 'Nobody matches that.',
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final cust in results)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(cust.name),
                      subtitle: Text(Phone.parse(cust.phoneE164).pretty),
                      onTap: () => Navigator.pop(context, cust),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
