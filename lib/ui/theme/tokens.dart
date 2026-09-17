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
    paper: Color(0xFFFCFAF3),
    surface: Color(0xFFFEFDFB),
    surface2: Color(0xFFF8F0D8), // the logo cream, exact
    ink: Color(0xFF1A2A32),
    ink2: Color(0xFF435660),
    ink3: Color(0xFF5C6F7A),
    rule: Color(0xFFE3DDC9),
    ruleSoft: Color(0xFFF3EFE2),
    brand: Color(0xFF507991), // the logo slate, exact
    accent: Color(0xFF46728B),
    accent2: Color(0xFF3A5E73),
    accentSoft: Color(0xFFDCE8EF),
    good: Color(0xFF3B7259),
    goodSoft: Color(0xFFDDEEE6),
    warn: Color(0xFF826026),
    warnSoft: Color(0xFFF3E5CD),
    bad: Color(0xFFA34B3E),
    badSoft: Color(0xFFF4DFDC),
  );

  static const dark = LoafColors(
    paper: Color(0xFF141B1F),
    surface: Color(0xFF1D252A),
    surface2: Color(0xFF293338),
    ink: Color(0xFFF1ECDF),
    ink2: Color(0xFFA9B5BC),
    ink3: Color(0xFF8D9CA5),
    rule: Color(0xFF374249),
    ruleSoft: Color(0xFF2A3237),
    brand: Color(0xFF29414D),
    accent: Color(0xFF92BBD3),
    accent2: Color(0xFFACCEE2),
    accentSoft: Color(0xFF263740),
    good: Color(0xFF81BBA0),
    goodSoft: Color(0xFF213129),
    warn: Color(0xFFD6B171),
    warnSoft: Color(0xFF332C1E),
    bad: Color(0xFFD68F85),
    badSoft: Color(0xFF372320),
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
