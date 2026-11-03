/// PayGo — ChipRow Widget
/// Row of styled filter/info chips.

import 'package:flutter/material.dart';
import '../config/colors.dart';

class ChipRow extends StatelessWidget {
  final List<String> items;
  final int? selectedIndex;
  final ValueChanged<int>? onSelected;
  final bool scrollable;

  const ChipRow({
    super.key,
    required this.items,
    this.selectedIndex,
    this.onSelected,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final chips = List.generate(items.length, (index) {
      final isSelected = selectedIndex == index;
      return GestureDetector(
        onTap: () => onSelected?.call(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? PayGoColors.oceanBlue.withValues(alpha: isDark ? 0.3 : 0.12)
                : isDark
                    ? PayGoColors.darkSurface
                    : PayGoColors.lightSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? PayGoColors.oceanBlue
                  : isDark
                      ? PayGoColors.darkDivider
                      : PayGoColors.lightDivider,
              width: isSelected ? 1.5 : 0.5,
            ),
          ),
          child: Text(
            items[index],
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? PayGoColors.oceanBlue
                  : isDark
                      ? PayGoColors.darkTextSecondary
                      : PayGoColors.lightTextSecondary,
            ),
          ),
        ),
      );
    });

    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chips.map((c) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: c,
          )).toList(),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }
}
