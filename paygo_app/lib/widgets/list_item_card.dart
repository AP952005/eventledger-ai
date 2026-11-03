/// PayGo — ListItemCard Widget
/// Settings-style list item with icon, title, subtitle, and optional badge.

import 'package:flutter/material.dart';
import '../config/colors.dart';

class ListItemCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? badge;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ListItemCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.badge,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDark
                    ? PayGoColors.oceanBlue.withValues(alpha: 0.15)
                    : PayGoColors.oceanBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: PayGoColors.oceanBlue,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium,
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: PayGoColors.oceanBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? PayGoColors.darkTextSecondary
                            : PayGoColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ?? Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
