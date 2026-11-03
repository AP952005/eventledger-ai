/// PayGo — IconGrid Widget
/// N-column grid of tappable icon + label items.
/// Used in Home (UPI Transfer, Travel, Gold, Financial), Bills, Financial Services.

import 'package:flutter/material.dart';
import '../config/colors.dart';

class IconGridItem {
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback? onTap;

  const IconGridItem({
    required this.icon,
    required this.label,
    this.badge,
    this.onTap,
  });
}

class IconGrid extends StatelessWidget {
  final List<IconGridItem> items;
  final int columns;
  final double iconSize;

  const IconGrid({
    super.key,
    required this.items,
    this.columns = 4,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 0.85,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _IconGridTile(
          item: item,
          iconSize: iconSize,
          isDark: isDark,
          theme: theme,
        );
      },
    );
  }
}

class _IconGridTile extends StatelessWidget {
  final IconGridItem item;
  final double iconSize;
  final bool isDark;
  final ThemeData theme;

  const _IconGridTile({
    required this.item,
    required this.iconSize,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isDark
                      ? PayGoColors.oceanBlue.withValues(alpha: 0.15)
                      : PayGoColors.oceanBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  item.icon,
                  size: iconSize,
                  color: PayGoColors.oceanBlue,
                ),
              ),
              if (item.badge != null)
                Positioned(
                  top: -6,
                  right: -10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: PayGoColors.gold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.badge!,
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
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
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
