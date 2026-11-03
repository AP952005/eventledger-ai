/// PayGo — BadgeChip Widget
/// Small badge label for promotions and offers.

import 'package:flutter/material.dart';
import '../config/colors.dart';

class BadgeChip extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  const BadgeChip({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor ?? PayGoColors.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor ?? PayGoColors.gold,
        ),
      ),
    );
  }
}
