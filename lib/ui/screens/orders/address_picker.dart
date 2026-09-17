import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/scope.dart';
import '../../../common/maps_link.dart';
import '../../../platform/storage/database.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/forms.dart';

/// An address on its way into the database, or already there.
///
/// Kept separate from the drift row so the order form can hold a one-off
/// address that was never saved against the customer.
class AddressDraft {
  AddressDraft({
    this.id,
    this.label = 'Home',
    this.addressText = '',
    this.pinLat,
    this.pinLng,
    this.pinUrl,
  });

  factory AddressDraft.of(CustomerAddress a) => AddressDraft(
        id: a.id,
        label: a.label,
        addressText: a.addressText,
        pinLat: a.pinLat,
        pinLng: a.pinLng,
        pinUrl: a.pinUrl,
      );

  final String? id;
  String label;
  String addressText;
  double? pinLat;
  double? pinLng;
  String? pinUrl;

  bool get hasPin => pinLat != null && pinLng != null;

  /// One line for a list tile — "Home · 14 Turner Rd, Bandra West".
  String get summary => '$label · $addressText';
}

/// Add or edit one address. Returns null if the sheet was dismissed.
Future<AddressDraft?> editAddress(BuildContext context,
        {AddressDraft? existing}) =>
    showModalBottomSheet<AddressDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddressSheet(existing: existing),
    );

class _AddressSheet extends StatefulWidget {
  const _AddressSheet({this.existing});

  final AddressDraft? existing;

  @override
  State<_AddressSheet> createState() => _AddressSheetState();
}

class _AddressSheetState extends State<_AddressSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _label =
      TextEditingController(text: widget.existing?.label ?? 'Home');
  late final _address =
      TextEditingController(text: widget.existing?.addressText ?? '');
  late final _link = TextEditingController(text: widget.existing?.pinUrl ?? '');

  late double? _lat = widget.existing?.pinLat;
  late double? _lng = widget.existing?.pinLng;

  @override
  void dispose() {
    for (final c in [_label, _address, _link]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Opens Maps already searching for whatever address has been typed, so the
  /// user is not retyping it on the other side. They then share the place back
  /// into the link field.
  Future<void> _openMaps() async {
    final uri = mapsSearchUri(_address.text);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')));
    }
  }

  /// Re-reads the pin every time the link changes, so the chip under the field
  /// always describes what is actually in the box.
  void _readLink(String value) {
    final pin = parseMapsLink(value);
    setState(() {
      _lat = pin?.lat;
      _lng = pin?.lng;
    });
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) return;
    _link.text = text;
    _readLink(text);
  }

  Widget _pinStatus(BuildContext context) {
    final c = context.colors;
    final text = _link.text.trim();
    final (icon, label, colour) = switch ((text.isEmpty, _lat != null)) {
      (true, _) => (Icons.info_outline, 'No pin yet — the address text is still used.', c.ink3),
      (false, true) => (Icons.place, 'Pin found: $_lat, $_lng', c.accent2),
      // a short link is a real link we simply cannot read offline
      (false, false) when isMapsLink(text) => (
          Icons.link,
          'Link saved. Short links carry no coordinates until opened.',
          c.ink3
        ),
      _ => (Icons.error_outline, 'That does not look like a Maps link.', c.ink3),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: colour),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Text(label,
                style: context.text.bodySmall!.copyWith(color: colour)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(
          left: Space.lg,
          right: Space.lg,
          top: Space.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + Space.lg,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(widget.existing == null ? 'Add address' : 'Edit address',
                    style: context.text.titleMedium),
                const SizedBox(height: Space.lg),
                LoafField(
                  label: 'Label',
                  controller: _label,
                  required: true,
                  hint: 'Home, Office…',
                ),
                LoafField(
                  label: 'Address',
                  controller: _address,
                  required: true,
                  maxLines: 3,
                ),
                LoafField(
                  label: 'Google Maps link',
                  controller: _link,
                  onChanged: _readLink,
                  hint: 'Paste a link from Google Maps',
                  suffix: IconButton(
                    icon: const Icon(Icons.content_paste, size: 18),
                    tooltip: 'Paste',
                    onPressed: _paste,
                  ),
                ),
                _pinStatus(context),
                OutlinedButton.icon(
                  onPressed: _openMaps,
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('Search on Google Maps'),
                ),
                const SizedBox(height: Space.sm),
                Text(
                  'Search there, tap Share, copy the link, then paste it above.',
                  style: context.text.bodySmall!
                      .copyWith(color: context.colors.ink3),
                ),
                const SizedBox(height: Space.lg),
                FilledButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    final link = _link.text.trim();
                    Navigator.pop(
                      context,
                      AddressDraft(
                        id: widget.existing?.id,
                        label: _label.text.trim(),
                        addressText: _address.text.trim(),
                        pinLat: _lat,
                        pinLng: _lng,
                        pinUrl: link.isEmpty ? null : link,
                      ),
                    );
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      );
}

/// Picks one of a customer's saved addresses, or starts a new one.
///
/// Returns null when dismissed. A returned draft with a null id was typed here
/// and has not been saved against the customer yet.
Future<AddressDraft?> pickAddress(
  BuildContext context, {
  required String customerId,
}) async {
  final saved = await context.app.customers.addresses(customerId);
  if (!context.mounted) return null;
  if (saved.isEmpty) return editAddress(context);

  return showModalBottomSheet<AddressDraft>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Deliver to', style: sheetContext.text.titleMedium),
            const SizedBox(height: Space.md),
            for (final a in saved)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  a.isDefault ? Icons.star : Icons.place_outlined,
                  size: 20,
                  color: sheetContext.colors.ink3,
                ),
                title: Text(a.label),
                subtitle: Text(a.addressText),
                trailing: a.pinLat != null
                    ? Icon(Icons.map_outlined,
                        size: 18, color: sheetContext.colors.ink3)
                    : null,
                onTap: () =>
                    Navigator.pop(sheetContext, AddressDraft.of(a)),
              ),
            const SizedBox(height: Space.sm),
            OutlinedButton.icon(
              onPressed: () async {
                final made = await editAddress(sheetContext);
                if (made != null && sheetContext.mounted) {
                  Navigator.pop(sheetContext, made);
                }
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New address'),
            ),
          ],
        ),
      ),
    ),
  );
}
