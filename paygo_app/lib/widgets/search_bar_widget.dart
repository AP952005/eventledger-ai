/// PayGo — SearchBar Widget
/// Animated search bar with filtering capability.

import 'package:flutter/material.dart';
import '../config/colors.dart';

class PayGoSearchBar extends StatelessWidget {
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextEditingController? controller;

  const PayGoSearchBar({
    super.key,
    this.placeholder = 'Search...',
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: readOnly ? onTap : null,
      child: Container(
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? PayGoColors.darkSurface : PayGoColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(
              Icons.search_rounded,
              size: 20,
              color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: readOnly
                  ? Text(
                      placeholder,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary,
                      ),
                    )
                  : TextField(
                      controller: controller,
                      onChanged: onChanged,
                      decoration: InputDecoration(
                        hintText: placeholder,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.lightTextPrimary,
                      ),
                    ),
            ),
            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}
