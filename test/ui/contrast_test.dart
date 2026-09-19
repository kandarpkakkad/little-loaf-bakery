import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/ui/theme/tokens.dart';

/// The design system says every foreground clears WCAG AA on every ground it
/// sits on — "checked, not assumed". Nothing checked it until now, which is
/// how a palette drifts: each individual colour looks fine in isolation.
///
/// docs/03-frontend/design-system.md §1
void main() {
  double channel(double c) =>
      c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

  double luminance(Color c) =>
      0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);

  double contrast(Color a, Color b) {
    final la = luminance(a), lb = luminance(b);
    final hi = math.max(la, lb), lo = math.min(la, lb);
    return (hi + 0.05) / (lo + 0.05);
  }

  String hex(Color c) =>
      '#${((c.r * 255).round() << 16 | (c.g * 255).round() << 8 | (c.b * 255).round()).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  /// AA for body text. Everything here is read as text somewhere.
  const aa = 4.5;

  void checkPalette(String name, LoafColors p) {
    final grounds = {
      'paper': p.paper,
      'surface': p.surface,
      'surface2 (cream)': p.surface2,
    };
    final foregrounds = {
      'ink': p.ink,
      'ink2': p.ink2,
      'ink3': p.ink3,
      'accent': p.accent,
      'accent2': p.accent2,
      'good': p.good,
      'warn': p.warn,
      'bad': p.bad,
    };

    for (final fg in foregrounds.entries) {
      for (final g in grounds.entries) {
        final r = contrast(fg.value, g.value);
        expect(r, greaterThanOrEqualTo(aa),
            reason: '$name: ${fg.key} ${hex(fg.value)} on ${g.key} '
                '${hex(g.value)} is ${r.toStringAsFixed(2)}:1, below AA');
      }
    }
  }

  test('light palette clears AA on every ground', () {
    checkPalette('light', LoafColors.light);
  });

  test('dark palette clears AA on every ground', () {
    checkPalette('dark', LoafColors.dark);
  });

  test('the two logo colours are exact and must not drift', () {
    // Sampled from the logo. Everything else is derived; these two are not.
    expect(hex(LoafColors.light.brand), '#507991', reason: 'the logo slate');
    expect(hex(LoafColors.light.surface2), '#F8F0D8', reason: 'the logo cream');
  });

  test('a tint is quiet enough to carry its own text', () {
    // Semantic text sits on its own soft tint — the pairing the rules require
    // and the one most likely to be forgotten when a colour is adjusted.
    for (final (name, fg, bg) in [
      ('good', LoafColors.light.good, LoafColors.light.goodSoft),
      ('warn', LoafColors.light.warn, LoafColors.light.warnSoft),
      ('bad', LoafColors.light.bad, LoafColors.light.badSoft),
      ('accent', LoafColors.light.accent, LoafColors.light.accentSoft),
    ]) {
      final r = contrast(fg, bg);
      expect(r, greaterThanOrEqualTo(aa),
          reason: 'light: $name on its soft tint is ${r.toStringAsFixed(2)}:1');
    }
    for (final (name, fg, bg) in [
      ('good', LoafColors.dark.good, LoafColors.dark.goodSoft),
      ('warn', LoafColors.dark.warn, LoafColors.dark.warnSoft),
      ('bad', LoafColors.dark.bad, LoafColors.dark.badSoft),
      ('accent', LoafColors.dark.accent, LoafColors.dark.accentSoft),
    ]) {
      final r = contrast(fg, bg);
      expect(r, greaterThanOrEqualTo(aa),
          reason: 'dark: $name on its soft tint is ${r.toStringAsFixed(2)}:1');
    }
  });

  test('the text ramp steps far enough apart to read as a hierarchy', () {
    // ink → ink2 → ink3 must be visibly different, not three shades of the
    // same grey. Ratio between neighbours, not against a ground.
    for (final p in [LoafColors.light, LoafColors.dark]) {
      expect(contrast(p.ink, p.ink3), greaterThan(1.8),
          reason: 'body and caption text are too close to tell apart');
    }
  });
}
