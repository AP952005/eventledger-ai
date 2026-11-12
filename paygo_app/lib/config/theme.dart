import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// EventTreasury AI Theme Configuration
/// Enterprise fintech aesthetic with light & dark mode support.
class EventTreasuryTheme {
  EventTreasuryTheme._();

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: EventTreasuryColors.paypalBlue,
      scaffoldBackgroundColor: EventTreasuryColors.lightBg,
      cardColor: EventTreasuryColors.lightCard,
      dividerColor: EventTreasuryColors.lightBorder,
      colorScheme: const ColorScheme.light(
        primary: EventTreasuryColors.paypalBlue,
        secondary: EventTreasuryColors.brightBlue,
        surface: EventTreasuryColors.lightCard,
        error: EventTreasuryColors.error,
        onPrimary: EventTreasuryColors.white,
        onSurface: EventTreasuryColors.lightTextPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: EventTreasuryColors.white,
        foregroundColor: EventTreasuryColors.paypalNavy,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: EventTreasuryColors.paypalNavy,
        ),
        iconTheme: const IconThemeData(color: EventTreasuryColors.paypalNavy),
      ),
      cardTheme: CardThemeData(
        color: EventTreasuryColors.lightCard,
        elevation: 1,
        shadowColor: EventTreasuryColors.paypalNavy.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: EventTreasuryColors.lightBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: EventTreasuryColors.paypalBlue,
          foregroundColor: EventTreasuryColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: EventTreasuryColors.paypalBlue,
          side: const BorderSide(color: EventTreasuryColors.borderBlue),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      textTheme: textTheme.apply(
        bodyColor: EventTreasuryColors.lightTextPrimary,
        displayColor: EventTreasuryColors.paypalNavy,
      ),
    );
  }

  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: EventTreasuryColors.darkPrimaryAction,
      scaffoldBackgroundColor: EventTreasuryColors.darkBg,
      cardColor: EventTreasuryColors.darkCard,
      dividerColor: EventTreasuryColors.darkBorder,
      colorScheme: const ColorScheme.dark(
        primary: EventTreasuryColors.darkPrimaryAction,
        secondary: EventTreasuryColors.brightBlue,
        surface: EventTreasuryColors.darkCard,
        error: EventTreasuryColors.error,
        onPrimary: EventTreasuryColors.white,
        onSurface: EventTreasuryColors.darkTextPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: EventTreasuryColors.darkSidebar,
        foregroundColor: EventTreasuryColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: EventTreasuryColors.darkTextPrimary,
        ),
        iconTheme: const IconThemeData(color: EventTreasuryColors.darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: EventTreasuryColors.darkCard,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: EventTreasuryColors.darkBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: EventTreasuryColors.darkPrimaryAction,
          foregroundColor: EventTreasuryColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: EventTreasuryColors.darkPrimaryAction,
          side: const BorderSide(color: EventTreasuryColors.darkBorder),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      textTheme: textTheme.apply(
        bodyColor: EventTreasuryColors.darkTextPrimary,
        displayColor: EventTreasuryColors.darkTextPrimary,
      ),
    );
  }
}

// Backward compatibility alias
typedef PayGoTheme = EventTreasuryTheme;
