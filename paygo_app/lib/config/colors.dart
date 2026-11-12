import 'package:flutter/material.dart';

/// EventTreasury AI Color Palette — PayPal Fintech Design System
/// Official colors:
/// PayPal Navy: #003087 | PayPal Blue: #0070E0 | Bright Blue: #009CDE
/// Sky Blue: #00A8EA | Deep Navy: #001C64 | Light Blue: #F3F8FF | Border Blue: #DCE7F5
class EventTreasuryColors {
  EventTreasuryColors._();

  // ── Primary Brand Palette (PayPal Inspired) ──
  static const Color paypalNavy = Color(0xFF003087);
  static const Color paypalBlue = Color(0xFF0070E0);
  static const Color brightBlue = Color(0xFF009CDE);
  static const Color skyBlue = Color(0xFF00A8EA);
  static const Color deepNavy = Color(0xFF001C64);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightBlue = Color(0xFFF3F8FF);
  static const Color borderBlue = Color(0xFFDCE7F5);

  // ── Aliases for backwards compatibility with legacy widgets ──
  static const Color oceanBlue = paypalBlue;
  static const Color paleBlue = borderBlue;
  static const Color gold = Color(0xFFFFB800);
  static const Color info = brightBlue;

  // ── Semantic Feedback ──
  static const Color success = Color(0xFF16A36A);
  static const Color warning = Color(0xFFE6A23C);
  static const Color error = Color(0xFFDC4545);
  static const Color information = Color(0xFF0070E0);
  static const Color neutral = Color(0xFF64748B);

  // ── Light Theme Surfaces ──
  static const Color lightBg = Color(0xFFF7F9FC);
  static const Color lightSurface = Color(0xFFF5F7FA);
  static const Color lightSidebar = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF10213A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextTertiary = Color(0xFF8E9AAF);
  static const Color lightHover = Color(0xFFEDF5FF);
  static const Color lightBorder = Color(0xFFE4EAF2);
  static const Color lightDivider = Color(0xFFE8ECF0);

  // ── Dark Theme Surfaces ──
  static const Color darkBg = Color(0xFF071426);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkSidebar = Color(0xFF0B1B32);
  static const Color darkCard = Color(0xFF10243E);
  static const Color darkElevatedCard = Color(0xFF142B49);
  static const Color darkCardElevated = Color(0xFF252D3D);
  static const Color darkTextPrimary = Color(0xFFF4F8FF);
  static const Color darkTextSecondary = Color(0xFFA9B9CC);
  static const Color darkTextTertiary = Color(0xFF6E7681);
  static const Color darkPrimaryAction = Color(0xFF1688F8);
  static const Color darkBorder = Color(0xFF243A55);
  static const Color darkDivider = Color(0xFF30363D);

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [paypalNavy, paypalBlue],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [paypalBlue, brightBlue],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB800), Color(0xFFFF8C00)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkCard, darkElevatedCard],
  );
}

// Backward compatibility alias during migration
typedef PayGoColors = EventTreasuryColors;
