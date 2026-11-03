/// PayGo — HorizontalScrollGrid Widget
/// Horizontally scrolling card row with optional badges.
/// Used in Home (Recharge shortcuts, Free Tools) and Bills screens.

import 'package:flutter/material.dart';
import '../config/colors.dart';

class HorizontalScrollItem {
  final IconData icon;
  final String label;
  final String? badge;
  final Widget? customWidget;
  final VoidCallback? onTap;

  const HorizontalScrollItem({
    required this.icon,
    required this.label,
    this.badge,
    this.customWidget,
    this.onTap,
  });
}

class HorizontalScrollGrid extends StatelessWidget {
  final List<HorizontalScrollItem> items;
  final double itemWidth;
  final double itemHeight;

  const HorizontalScrollGrid({
    super.key,
    required this.items,
    this.itemWidth = 100,
    this.itemHeight = 135,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: itemHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: item.onTap,
            child: SizedBox(
              width: itemWidth,
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isDark
                              ? PayGoColors.darkCardElevated
                              : PayGoColors.lightSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider,
                            width: 0.5,
                          ),
                        ),
                        child: item.customWidget ?? Icon(
                          item.icon,
                          size: 26,
                          color: PayGoColors.oceanBlue,
                        ),
                      ),
                      if (item.badge != null)
                        Positioned(
                          top: -4,
                          right: -8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: PayGoColors.success,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.badge!,
                              style: const TextStyle(
                                fontSize: 7,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
