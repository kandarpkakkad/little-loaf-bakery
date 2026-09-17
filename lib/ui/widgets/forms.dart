import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/money.dart';
import '../../common/phone.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';

/// A required field is marked `*`. An optional one is marked with nothing at
/// all — writing "optional" on half the form makes the form look like a
/// negotiation. docs/03-frontend/design-system.md
class LoafField extends StatelessWidget {
  const LoafField({
    super.key,
    required this.label,
    required this.controller,
    this.required = false,
    this.hint,
    this.helper,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.prefix,
    this.suffix,
    this.validator,
    this.onChanged,
    this.autofocus = false,
  });

  final String label;
  final TextEditingController controller;
  final bool required;
  final String? hint;

  /// Sits under the field, always visible — for a rule the number alone cannot
  /// convey, like a price being per unit.
  final String? helper;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final String? prefix;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: Space.lg),
        child: TextFormField(
          controller: controller,
          autofocus: autofocus,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          onChanged: onChanged,
          textCapitalization: keyboardType == TextInputType.number
              ? TextCapitalization.none
              : TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: required ? '$label *' : label,
            hintText: hint,
            helperText: helper,
            prefixText: prefix,
            suffixIcon: suffix,
          ),
          validator: validator ??
              (required
                  ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
                  : null),
        ),
      );
}

/// Owns [controllers] for as long as [child] is mounted, disposing them when
/// it unmounts.
///
/// Sheets and dialogs build their controllers before `showModalBottomSheet`,
/// and cannot dispose them on the line after `await`: that future completes
/// when the route is popped, while the fields are still mounted and animating
/// out. Disposing there leaves a `TextFormField` reading a dead controller,
/// which throws inside its own teardown, which in turn leaves the enclosing
/// `Form` scope deactivating with live dependents — the
/// "_dependents.isEmpty: is not true" crash.
///
/// Deferring by a frame is not enough either: the animation runs for many
/// frames. Only unmounting is the right moment, and this is a widget so that
/// it gets one. Elements unmount depth-first, so its own fields are gone
/// before this disposes anything they might still be holding.
class ControllerHost extends StatefulWidget {
  const ControllerHost({
    super.key,
    required this.controllers,
    required this.child,
  });

  final List<ChangeNotifier> controllers;
  final Widget child;

  @override
  State<ControllerHost> createState() => _ControllerHostState();
}

class _ControllerHostState extends State<ControllerHost> {
  @override
  void dispose() {
    for (final c in widget.controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// A mobile number, with the dialling code shown as a fixed prefix.
///
/// One box, not two. While only one country is supported the code never varies,
/// so offering it as a field was an invitation to get it wrong — and a wrong
/// code produces a WhatsApp link that searches and fails rather than erroring.
/// Anything that is not a digit is stripped as it is typed, so the same person
/// cannot be saved twice by spacing the number differently.
class LoafPhoneField extends StatelessWidget {
  const LoafPhoneField({
    super.key,
    required this.controller,
    this.country = kDefaultCountry,
    this.label = 'WhatsApp number',
    this.required = true,
    this.helper,
    this.onChanged,
  });

  /// Holds the national digits — never the code.
  final TextEditingController controller;

  /// Fixed while only one country is supported. When a second is added this
  /// becomes the selected one and the prefix turns into a picker.
  final PhoneCountry country;
  final String label;
  final bool required;
  final String? helper;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) => LoafField(
        label: label,
        controller: controller,
        required: required,
        helper: helper,
        hint: '98765 43210',
        prefix: '${country.code} ',
        keyboardType: TextInputType.phone,
        onChanged: onChanged,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(country.nationalLength),
        ],
        validator: (v) {
          final p = Phone(Phone.digitsOf(v ?? ''), country: country);
          if (!required && p.national.isEmpty) return null;
          return p.problem;
        },
      );
}

/// Rupees in, paise out. The UI never holds a fractional amount as a double.
Money moneyFromField(String text) {
  final cleaned = text.replaceAll(',', '').trim();
  if (cleaned.isEmpty) return Money.zero;
  return Money.rupees(double.tryParse(cleaned) ?? 0);
}

String moneyToField(Money m) {
  if (m.isZero) return '';
  final r = m.paise / 100;
  return r == r.roundToDouble() ? r.toStringAsFixed(0) : r.toStringAsFixed(2);
}

final rupeeInput = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
];

final qtyInput = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
];

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: Space.xl, bottom: Space.sm),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text.toUpperCase(),
                style: context.text.labelSmall!.copyWith(
                  color: context.colors.ink3,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      );
}

/// A card that groups fields, so a long form reads as a few things rather than
/// a wall of inputs.
class LoafCard extends StatelessWidget {
  const LoafCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding ?? const EdgeInsets.all(Space.lg),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: context.colors.ruleSoft),
        ),
        child: child,
      );
}

/// A single-line text prompt. Used everywhere a name or a note is the whole
/// interaction and a full screen would be theatre.
Future<String?> promptText(
  BuildContext context, {
  required String title,
  String? initial,
  String? hint,
  String confirm = 'Save',
  TextInputType? keyboardType,
}) async {
  final c = TextEditingController(text: initial ?? '');
  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) => ControllerHost(
      controllers: [c],
      child: AlertDialog(
      title: Text(title),
      content: TextField(
        controller: c,
        autofocus: true,
        keyboardType: keyboardType,
        decoration: InputDecoration(hintText: hint),
        onSubmitted: (v) => Navigator.pop(dialogContext, v.trim()),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, c.text.trim()),
          child: Text(confirm),
        ),
      ],
      ),
    ),
  );
  return (result == null || result.isEmpty) ? null : result;
}

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirm = 'Confirm',
  bool destructive = false,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel')),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: context.colors.bad, foregroundColor: Colors.white)
              : null,
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(confirm),
        ),
      ],
    ),
  );
  return ok ?? false;
}
