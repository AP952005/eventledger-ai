/// PayGo — PromoCarousel Widget
/// Auto-rotating banner carousel with page indicators.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../config/colors.dart';

class PromoItem {
  final String title;
  final String subtitle;
  final String? cta;
  final Color color;

  const PromoItem({
    required this.title,
    required this.subtitle,
    this.cta,
    required this.color,
  });
}

class PromoCarousel extends StatefulWidget {
  final List<PromoItem> items;
  final bool autoRotate;

  const PromoCarousel({
    super.key,
    required this.items,
    this.autoRotate = true,
  });

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  late final PageController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);
    if (widget.autoRotate && widget.items.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (_controller.hasClients) {
          final next = ((_controller.page?.round() ?? 0) + 1) % widget.items.length;
          _controller.animateToPage(
            next,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 170, // Increased from 140 to fix bottom overflow
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        item.color,
                        item.color.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        maxLines: 2,
                      ),
                      if (item.cta != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.cta!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: item.color,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.items.length > 1) ...[
          const SizedBox(height: 12),
          SmoothPageIndicator(
            controller: _controller,
            count: widget.items.length,
            effect: ExpandingDotsEffect(
              dotHeight: 6,
              dotWidth: 6,
              activeDotColor: PayGoColors.oceanBlue,
              dotColor: PayGoColors.oceanBlue.withValues(alpha: 0.2),
              expansionFactor: 3,
            ),
          ),
        ],
      ],
    );
  }
}
