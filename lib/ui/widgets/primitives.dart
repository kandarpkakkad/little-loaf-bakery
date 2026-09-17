import 'package:flutter/material.dart';

import '../../common/money.dart';
import '../theme/format.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';

/// Uppercase section marker. docs/03-frontend/design-system.md §2 `micro`.
class Micro extends StatelessWidget {
  const Micro(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: Space.sm),
        child: Text(text.toUpperCase(), style: context.text.labelSmall),
      );
}

/// A label/value row. **Renders nothing when the amount is zero** — the row
/// does not exist, rather than showing ₹0. (D10)
class MoneyRow extends StatelessWidget {
  const MoneyRow(this.label, this.amount, {super.key, this.strong = false, this.showZero = false});

  final String label;
  final Money amount;
  final bool strong;
  final bool showZero;

  @override
  Widget build(BuildContext context) {
    final text = money(amount, showZero: showZero);
    if (text == null) return const SizedBox.shrink();
    final style = strong
        ? context.text.bodyLarge!.copyWith(fontWeight: FontWeight.w600)
        : context.text.bodyMedium!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.xs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(text,
              style: style.copyWith(
                color: context.colors.ink,
                fontFeatures: const [FontFeature.tabularFigures()],
              )),
        ],
      ),
    );
  }
}

enum AlertTone { good, warn, bad }

class LoafAlert extends StatelessWidget {
  const LoafAlert(this.message,
      {super.key, this.tone = AlertTone.warn, this.action, this.onAction, this.icon});

  final String message;
  final AlertTone tone;
  final String? action;
  final VoidCallback? onAction;

  /// Use a Material icon rather than a Unicode glyph. ⚑ (U+2691) and friends
  /// are not in Android's default font and render as tofu.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (fg, bg) = switch (tone) {
      AlertTone.good => (c.good, c.goodSoft),
      AlertTone.warn => (c.warn, c.warnSoft),
      AlertTone.bad => (c.bad, c.badSoft),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Radii.sm)),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: Space.sm),
          ],
          Expanded(
            child: Text(message,
                style: context.text.bodySmall!.copyWith(color: fg, fontSize: 13)),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: action == '>'
                  ? Icon(Icons.chevron_right, size: 18, color: fg)
                  : Text(action!,
                      style: context.text.labelLarge!
                          .copyWith(color: fg, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

/// Icon, one line of what goes here, and the action that fills it.
/// Never a blank list. docs/03-frontend/design-system.md §7.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.message, this.action, this.onAction});

  final IconData icon;
  final String message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Space.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: context.colors.ink3),
              const SizedBox(height: Space.md),
              Text(message,
                  textAlign: TextAlign.center, style: context.text.bodyMedium),
              if (action != null) ...[
                const SizedBox(height: Space.lg),
                OutlinedButton(onPressed: onAction, child: Text(action!)),
              ],
            ],
          ),
        ),
      );
}

/// The stock bar: fills to the reference, notched at the threshold.
///
/// Scale is `max(reference, threshold)` — the second branch is the case where
/// the last restock fell short, and the notch lands hard at the right edge,
/// reading as *that restock didn't get you there*. (D18)
class StockBar extends StatelessWidget {
  const StockBar({super.key, required this.level, required this.reference, required this.threshold});

  final double level, reference, threshold;

  double get _scale => reference > threshold ? reference : threshold;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fill = _scale <= 0 ? 0.0 : (level / _scale).clamp(0.0, 1.0);
    final notch = _scale <= 0 ? 1.0 : (threshold / _scale).clamp(0.0, 1.0);
    // colour carries urgency, but position is the real signal
    final colour = level < threshold
        ? c.bad
        : level < threshold * 1.15
            ? c.warn
            : c.good;

    return SizedBox(
      height: 12,
      child: LayoutBuilder(
        builder: (context, box) => Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: c.ruleSoft,
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 8,
                width: box.maxWidth * fill,
                decoration: BoxDecoration(
                  color: colour,
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
              ),
            ),
            // drawn over the fill as well as the track, so it stays readable
            Positioned(
              left: (box.maxWidth * notch) - 1,
              top: 0,
              bottom: 0,
              width: 2,
              child: Container(color: c.ink.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
