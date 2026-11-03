/// PayGo — Onboarding Screen
/// 3-page carousel introducing app features.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../config/colors.dart';
import '../config/routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPage(
      icon: Icons.send_rounded,
      title: 'Send Money Instantly',
      subtitle: 'Transfer money to anyone using UPI.\nFast, secure, and zero fees.',
      gradient: [PayGoColors.oceanBlue, PayGoColors.lightBlue],
    ),
    _OnboardingPage(
      icon: Icons.receipt_long_rounded,
      title: 'Pay All Your Bills',
      subtitle: 'Recharge, utilities, EMIs, insurance\n— everything in one place.',
      gradient: [PayGoColors.deepNavy, PayGoColors.oceanBlue],
    ),
    _OnboardingPage(
      icon: Icons.insights_rounded,
      title: 'Track Everything',
      subtitle: 'Monitor your spending, investments,\nand financial health effortlessly.',
      gradient: [Color(0xFF0A3D62), Color(0xFF0077B6)],
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go(AppRoutes.phoneEntry);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) => _pages[index],
          ),

          // Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: TextButton(
              onPressed: () => context.go(AppRoutes.phoneEntry),
              child: Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: _pages.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: Colors.white,
                    dotColor: Colors.white.withValues(alpha: 0.3),
                    expansionFactor: 3,
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: PayGoColors.deepNavy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradient,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(icon, size: 60, color: Colors.white),
          )
              .animate()
              .scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.easeOutBack)
              .fadeIn(duration: 400.ms),

          const SizedBox(height: 40),

          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),

          const SizedBox(height: 16),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}
