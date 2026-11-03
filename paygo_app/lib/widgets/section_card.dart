/// PayGo — SectionCard Widget
/// A titled container card with optional "View All" action.
/// Used as the primary layout wrapper on Home, Bills, Financial screens.

import 'package:flutter/material.dart';
import '../config/colors.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onViewAll;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.onViewAll,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? PayGoColors.darkCard : PayGoColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All',
                          style: TextStyle(
                            color: PayGoColors.oceanBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: PayGoColors.oceanBlue,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: padding ?? const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: child,
          ),
        ],
      ),
    );
  }
}
