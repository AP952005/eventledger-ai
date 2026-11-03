/// PayGo — ShimmerLoading Widget
/// Shimmer placeholder for loading states.

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/colors.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 80,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? PayGoColors.darkSurface : Colors.grey.shade200,
      highlightColor: isDark ? PayGoColors.darkCard : Colors.grey.shade50,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// A full card shimmer placeholder
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? PayGoColors.darkSurface : Colors.grey.shade200,
      highlightColor: isDark ? PayGoColors.darkCard : Colors.grey.shade50,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
