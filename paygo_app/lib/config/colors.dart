import 'package:flutter/material.dart';

/// PayGo brand color palette
/// Light theme: White bg, deep navy primary, ocean blue accent
/// Dark theme: Black/dark grey bg, ocean blue primary, lighter blue accent
class PayGoColors {
  PayGoColors._();

  // ── Primary Brand Colors ──
  static const Color deepNavy = Color(0xFF0A1F44);
  static const Color oceanBlue = Color(0xFF0077B6);
  static const Color lightBlue = Color(0xFF48CAE4);
  static const Color paleBlue = Color(0xFF90E0EF);
  static const Color white = Color(0xFFFFFFFF);

  // ── Accent / Status Colors ──
  static const Color gold = Color(0xFFFFB800);
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFFF1744);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);

  // ── Light Theme Surfaces ──
  static const Color lightBg = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF5F7FA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFE8ECF0);
  static const Color lightTextPrimary = Color(0xFF0A1F44);
  static const Color lightTextSecondary = Color(0xFF5A6B7F);
  static const Color lightTextTertiary = Color(0xFF8E9AAF);

  // ── Dark Theme Surfaces ──
  static const Color darkBg = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkCard = Color(0xFF1C2333);
  static const Color darkCardElevated = Color(0xFF252D3D);
  static const Color darkDivider = Color(0xFF30363D);
  static const Color darkTextPrimary = Color(0xFFE6EDF3);
  static const Color darkTextSecondary = Color(0xFF8B949E);
  static const Color darkTextTertiary = Color(0xFF6E7681);

  // ── Gradient Presets ──
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepNavy, oceanBlue],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [oceanBlue, lightBlue],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB800), Color(0xFFFF8C00)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkCard, darkCardElevated],
  );
}
