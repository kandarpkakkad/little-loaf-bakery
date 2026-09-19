import 'package:flutter/material.dart';

/// Every colour derives from the logo's two: slate (hue 202°) and cream (hue 45°).
/// Every pair below clears WCAG AA (4.5:1) on every ground it sits on, in both
/// themes — checked against paper, surface *and* the cream fill.
/// See docs/03-frontend/design-system.md §1.
class LoafColors extends ThemeExtension<LoafColors> {
  const LoafColors({
    required this.paper,
    required this.surface,
    required this.surface2,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.rule,
    required this.ruleSoft,
    required this.brand,
    required this.accent,
    required this.accent2,
    required this.accentSoft,
    required this.good,
    required this.goodSoft,
    required this.warn,
    required this.warnSoft,
    required this.bad,
    required this.badSoft,
  });

  final Color paper, surface, surface2;
  final Color ink, ink2, ink3;
  final Color rule, ruleSoft;

  /// The logo colour, exact. App bar only.
  final Color brand;

  /// Same hue, 3% darker, so body-size links clear 4.5:1.
  final Color accent, accent2, accentSoft;

  final Color good, goodSoft, warn, warnSoft, bad, badSoft;

  static const light = LoafColors(
    paper: Color(0xFFFBF8EF),
    surface: Color(0xFFFFFDF7),
    surface2: Color(0xFFF8F0D8), // the logo cream, exact
    ink: Color(0xFF16242B),
    ink2: Color(0xFF3A505B),
    ink3: Color(0xFF566A75),
    rule: Color(0xFFE6DFC9),
    ruleSoft: Color(0xFFF4F0E0),
    brand: Color(0xFF507991), // the logo slate, exact
    accent: Color(0xFF3B6C8A),
    accent2: Color(0xFF2B5268),
    accentSoft: Color(0xFFE2EEF4),
    good: Color(0xFF2D6A4F),
    goodSoft: Color(0xFFDBEEE4),
    warn: Color(0xFF7D5613),
    warnSoft: Color(0xFFF5E6C8),
    bad: Color(0xFF98392D),
    badSoft: Color(0xFFF6DED9),
  );

  static const dark = LoafColors(
    paper: Color(0xFF11181C),
    surface: Color(0xFF1B2429),
    surface2: Color(0xFF28333A),
    ink: Color(0xFFF3EEE1),
    ink2: Color(0xFFAEBAC1),
    ink3: Color(0xFF93A2AB),
    rule: Color(0xFF38444B),
    ruleSoft: Color(0xFF2A3339),
    brand: Color(0xFF2B4553),
    accent: Color(0xFF9CC5DC),
    accent2: Color(0xFFB8D6E8),
    accentSoft: Color(0xFF22343E),
    good: Color(0xFF7FC5A5),
    goodSoft: Color(0xFF1F3129),
    warn: Color(0xFFE2BA74),
    warnSoft: Color(0xFF342C1D),
    bad: Color(0xFFE4958B),
    badSoft: Color(0xFF382320),
  );

  @override
  LoafColors copyWith() => this;

  @override
  LoafColors lerp(ThemeExtension<LoafColors>? other, double t) =>
      t < 0.5 ? this : (other as LoafColors? ?? this);
}

/// A 4pt grid. Nothing off it.
abstract final class Space {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const huge = 48.0;

  /// Never smaller, whatever the design wants — this is used with flour on hands.
  static const minTap = 48.0;
}

abstract final class Radii {
  static const sm = 6.0;
  static const md = 10.0;
  static const lg = 14.0;
  static const pill = 999.0;
}
