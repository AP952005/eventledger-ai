import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// PayGo Theme definitions — Material 3 with custom brand tokens
class PayGoTheme {
  PayGoTheme._();

  // ──────────────────────────────────────────────
  // Typography
  // ──────────────────────────────────────────────

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.5),
      displayMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.5),
      displaySmall: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w600, color: primary),
      headlineLarge: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600, color: primary),
      headlineMedium: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: primary),
      headlineSmall: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
      titleLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
      titleMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
      titleSmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: primary),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: primary),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: secondary),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: secondary),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: primary),
      labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: primary),
      labelSmall: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: secondary),
    );
  }

  // ──────────────────────────────────────────────
  // Light Theme
  // ──────────────────────────────────────────────

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: PayGoColors.deepNavy,
        onPrimary: PayGoColors.white,
        secondary: PayGoColors.oceanBlue,
        onSecondary: PayGoColors.white,
        tertiary: PayGoColors.lightBlue,
        surface: PayGoColors.lightSurface,
        onSurface: PayGoColors.lightTextPrimary,
        error: PayGoColors.error,
        onError: PayGoColors.white,
        outline: PayGoColors.lightDivider,
      ),
      scaffoldBackgroundColor: PayGoColors.lightBg,
      textTheme: _textTheme(PayGoColors.lightTextPrimary, PayGoColors.lightTextSecondary),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: PayGoColors.lightBg,
        foregroundColor: PayGoColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: PayGoColors.lightTextPrimary,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: PayGoColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: PayGoColors.lightDivider, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // Elevated Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PayGoColors.oceanBlue,
          foregroundColor: PayGoColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PayGoColors.oceanBlue,
          side: const BorderSide(color: PayGoColors.oceanBlue),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: PayGoColors.oceanBlue,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PayGoColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PayGoColors.lightDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PayGoColors.oceanBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PayGoColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: PayGoColors.lightTextTertiary),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: PayGoColors.lightSurface,
        selectedColor: PayGoColors.oceanBlue.withValues(alpha: 0.15),
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: PayGoColors.lightDivider),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: PayGoColors.lightBg,
        selectedItemColor: PayGoColors.oceanBlue,
        unselectedItemColor: PayGoColors.lightTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: PayGoColors.lightDivider,
        thickness: 0.5,
        space: 0,
      ),

      // List Tiles
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: PayGoColors.lightTextPrimary),
        subtitleTextStyle: GoogleFonts.inter(fontSize: 12, color: PayGoColors.lightTextSecondary),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: PayGoColors.oceanBlue,
        foregroundColor: PayGoColors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Dark Theme
  // ──────────────────────────────────────────────

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: PayGoColors.oceanBlue,
        onPrimary: PayGoColors.white,
        secondary: PayGoColors.lightBlue,
        onSecondary: PayGoColors.darkBg,
        tertiary: PayGoColors.paleBlue,
        surface: PayGoColors.darkSurface,
        onSurface: PayGoColors.darkTextPrimary,
        error: PayGoColors.error,
        onError: PayGoColors.white,
        outline: PayGoColors.darkDivider,
      ),
      scaffoldBackgroundColor: PayGoColors.darkBg,
      textTheme: _textTheme(PayGoColors.darkTextPrimary, PayGoColors.darkTextSecondary),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: PayGoColors.darkBg,
        foregroundColor: PayGoColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: PayGoColors.darkTextPrimary,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: PayGoColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: PayGoColors.darkDivider, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // Elevated Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PayGoColors.oceanBlue,
          foregroundColor: PayGoColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PayGoColors.lightBlue,
          side: const BorderSide(color: PayGoColors.oceanBlue),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: PayGoColors.lightBlue,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PayGoColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PayGoColors.darkDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PayGoColors.oceanBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PayGoColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: PayGoColors.darkTextTertiary),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: PayGoColors.darkSurface,
        selectedColor: PayGoColors.oceanBlue.withValues(alpha: 0.25),
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: PayGoColors.darkDivider),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: PayGoColors.darkSurface,
        selectedItemColor: PayGoColors.lightBlue,
        unselectedItemColor: PayGoColors.darkTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: PayGoColors.darkDivider,
        thickness: 0.5,
        space: 0,
      ),

      // List Tiles
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: PayGoColors.darkTextPrimary),
        subtitleTextStyle: GoogleFonts.inter(fontSize: 12, color: PayGoColors.darkTextSecondary),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: PayGoColors.oceanBlue,
        foregroundColor: PayGoColors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    );
  }
}
