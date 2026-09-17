import 'package:flutter/material.dart';

import 'tokens.dart';

/// One size per role. There is no 14 and no 17.
/// docs/03-frontend/design-system.md §2
TextTheme _text(LoafColors c) => TextTheme(
      displaySmall: TextStyle(fontSize: 28, height: 1.15, fontWeight: FontWeight.w600, color: c.ink),
      titleLarge: TextStyle(fontSize: 20, height: 1.25, fontWeight: FontWeight.w600, color: c.ink),
      titleMedium: TextStyle(fontSize: 16, height: 1.3, fontWeight: FontWeight.w600, color: c.ink),
      bodyLarge: TextStyle(fontSize: 15, height: 1.45, color: c.ink),
      bodyMedium: TextStyle(fontSize: 15, height: 1.45, color: c.ink2),
      labelLarge: TextStyle(fontSize: 13, height: 1.35, fontWeight: FontWeight.w500, color: c.ink),
      bodySmall: TextStyle(fontSize: 12, height: 1.35, color: c.ink3),
      labelSmall: TextStyle(
        fontSize: 11, height: 1.2, fontWeight: FontWeight.w700,
        letterSpacing: 0.88, color: c.ink3,
      ),
    );

ThemeData loafTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? LoafColors.dark : LoafColors.light;

  return ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: c.paper,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: brightness == Brightness.dark ? const Color(0xFF12191D) : Colors.white,
      secondary: c.accent2,
      onSecondary: Colors.white,
      surface: c.surface,
      onSurface: c.ink,
      error: c.bad,
      onError: Colors.white,
      surfaceContainerHighest: c.surface2,
      outline: c.rule,
      outlineVariant: c.ruleSoft,
    ),
    textTheme: _text(c),
    extensions: [c],

    // the logo colour, used literally, and only here
    appBarTheme: AppBarTheme(
      backgroundColor: c.brand,
      foregroundColor: brightness == Brightness.dark ? c.ink : Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w600,
        color: brightness == Brightness.dark ? c.ink : Colors.white,
      ),
    ),

    // borders, not shadows
    cardTheme: CardThemeData(
      color: c.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.md),
        side: BorderSide(color: c.rule),
      ),
    ),
    dividerTheme: DividerThemeData(color: c.ruleSoft, thickness: 1, space: Space.md),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.brand,
        foregroundColor: Colors.white,
        // Height only. `Size.fromHeight` would set the *width* to infinity,
        // which reads as "full width" inside a Column but becomes a tight
        // infinite width for a non-flex child of a Row — the row then
        // collapses and the button disappears. Buttons that should fill their
        // line are stretched by their parent instead.
        minimumSize: const Size(0, Space.minTap),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.sm)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.accent,
        side: BorderSide(color: c.accent),
        // Height only. `Size.fromHeight` would set the *width* to infinity,
        // which reads as "full width" inside a Column but becomes a tight
        // infinite width for a non-flex child of a Row — the row then
        // collapses and the button disappears. Buttons that should fill their
        // line are stretched by their parent instead.
        minimumSize: const Size(0, Space.minTap),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.sm)),
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surface2,
      indicatorColor: c.accentSoft,
      elevation: 0,
      height: 64,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c.ink2),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.sm),
        borderSide: BorderSide(color: c.rule),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.md),
      labelStyle: TextStyle(color: c.ink3, fontSize: 13),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: c.surface2,
      side: BorderSide(color: c.rule),
      labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.ink2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.pill)),
    ),

    // sheets are the one place a shadow is allowed
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.lg)),
      ),
    ),
  );
}

extension LoafTheme on BuildContext {
  LoafColors get colors => Theme.of(this).extension<LoafColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
}
