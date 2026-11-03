/// PayGo — Home Dashboard Screen
/// Full scrollable feed with all section cards from the spec.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';
import '../../services/mock_data.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/fab_scan_qr.dart';
import '../../widgets/promo_carousel.dart';
import '../../widgets/section_card.dart';
import '../../widgets/icon_grid.dart';
import '../../widgets/horizontal_scroll_grid.dart';
import '../../widgets/chip_row.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Column(
        children: [
          // Top Bar
          PayGoTopBar(
            userName: user.name,
            userInitials: user.initials,
            notificationCount: MockData.unreadNotificationCount,
            onAvatarTap: () => context.push(AppRoutes.myQR),
            onSearchTap: () => context.push(AppRoutes.search),
            onNotificationTap: () => context.push(AppRoutes.notifications),
          ),

          // Scrollable Feed
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // Promo Carousel
                  PromoCarousel(
                    items: MockData.homePromos.map((p) => PromoItem(
                      title: p['title'] as String,
                      subtitle: p['subtitle'] as String,
                      cta: p['cta'] as String?,
                      color: Color(p['color'] as int),
                    )).toList(),
                  ).animate().fadeIn(duration: 500.ms),

                  const SizedBox(height: 16),

                  // UPI Money Transfer
                  SectionCard(
                    title: 'UPI Money Transfer',
                    child: IconGrid(
                      items: [
                        IconGridItem(
                          icon: Icons.qr_code_scanner_rounded,
                          label: 'Scan & Pay',
                          onTap: () => context.push(AppRoutes.scanAndPay),
                        ),
                        IconGridItem(
                          icon: Icons.contacts_rounded,
                          label: 'To Contact',
                          onTap: () => context.push(AppRoutes.toMobileContact),
                        ),
                        IconGridItem(
                          icon: Icons.account_balance_rounded,
                          label: 'To Bank & Self',
                          onTap: () => context.push(AppRoutes.toBankAccount),
                        ),
                        IconGridItem(
                          icon: Icons.history_rounded,
                          label: 'Balance & History',
                          onTap: () => context.push(AppRoutes.balanceHistory),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.05),

                  // Recharge & Bills
                  SectionCard(
                    title: 'Recharge & Bills',
                    onViewAll: () => context.push(AppRoutes.billsAndRecharges),
                    child: HorizontalScrollGrid(
                      items: [
                        HorizontalScrollItem(icon: Icons.phone_android_rounded, label: 'Mobile\nRecharge'),
                        HorizontalScrollItem(icon: Icons.credit_card_rounded, label: 'Credit Card\nBill'),
                        HorizontalScrollItem(icon: Icons.bolt_rounded, label: 'Electricity\nBill', badge: 'Flat ₹30'),
                        HorizontalScrollItem(icon: Icons.directions_car_rounded, label: 'FASTag\nRecharge', badge: 'No Fee'),
                        HorizontalScrollItem(icon: Icons.satellite_alt_rounded, label: 'DTH\nRecharge', badge: 'Flat ₹15'),
                        HorizontalScrollItem(icon: Icons.account_balance_rounded, label: 'Pay Loan\nEMI'),
                        HorizontalScrollItem(icon: Icons.water_drop_rounded, label: 'Water\nBill'),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.05),

                  // Exclusive Offer Banner
                  _OfferBanner(isDark: isDark).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                  // Two Column Row — Postpaid, Refer, What's New
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuickCard(
                            icon: Icons.credit_score_rounded,
                            title: 'PayGo Postpaid',
                            subtitle: 'Up to ₹60,000 limit',
                            gradient: PayGoColors.primaryGradient,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _QuickCard(
                            icon: Icons.card_giftcard_rounded,
                            title: 'Refer & Win',
                            subtitle: 'Assured ₹60',
                            gradient: PayGoColors.goldGradient,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

                  // Tips Chip Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ChipRow(
                      items: const ['UPI Safety Tips', 'Cashback & Offers', 'UPI Lite Activation'],
                    ),
                  ),

                  // Travel & Tickets
                  SectionCard(
                    title: 'Travel & Tickets',
                    child: Column(
                      children: [
                        IconGrid(
                          items: [
                            IconGridItem(icon: Icons.flight_rounded, label: 'Flights'),
                            IconGridItem(icon: Icons.train_rounded, label: 'Trains'),
                            IconGridItem(icon: Icons.directions_bus_rounded, label: 'Bus'),
                            IconGridItem(icon: Icons.subway_rounded, label: 'Metro'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ChipRow(
                          items: const ['15% off* on Flights', '40% off* on Hotels'],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

                  // Gold & Silver
                  SectionCard(
                    title: 'Gold & Silver',
                    child: IconGrid(
                      items: [
                        IconGridItem(icon: Icons.workspace_premium_rounded, label: 'Save in Gold'),
                        IconGridItem(icon: Icons.diamond_rounded, label: 'Save in Silver'),
                        IconGridItem(icon: Icons.auto_awesome_rounded, label: 'Jewellery'),
                        IconGridItem(icon: Icons.sync_rounded, label: 'Gold Round-Up'),
                      ],
                    ),
                  ),

                  // Financial Services
                  SectionCard(
                    title: 'Financial Services',
                    onViewAll: () => context.push(AppRoutes.financialServices),
                    child: IconGrid(
                      items: [
                        IconGridItem(icon: Icons.currency_rupee_rounded, label: 'Loan'),
                        IconGridItem(icon: Icons.show_chart_rounded, label: '₹51/day SIP'),
                        IconGridItem(icon: Icons.directions_car_rounded, label: 'Car Insurance'),
                        IconGridItem(icon: Icons.two_wheeler_rounded, label: 'Bike Insurance'),
                        IconGridItem(icon: Icons.credit_score_rounded, label: 'PayGo Postpaid'),
                        IconGridItem(icon: Icons.auto_graph_rounded, label: 'Invest ETFs'),
                        IconGridItem(icon: Icons.add_card_rounded, label: 'Credit Card'),
                        IconGridItem(icon: Icons.health_and_safety_rounded, label: 'Health Ins.'),
                      ],
                    ),
                  ),

                  // ✨ Event Pay — Premium Feature Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GestureDetector(
                      onTap: () => context.push(AppRoutes.eventList),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF0077B6),
                              Color(0xFF00B4D8),
                              Color(0xFF48CAE4),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0077B6).withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Glowing icon container
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.groups_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ).animate(
                              onPlay: (controller) => controller.repeat(reverse: true),
                            ).scaleXY(
                              begin: 1.0,
                              end: 1.08,
                              duration: 2000.ms,
                              curve: Curves.easeInOut,
                            ),
                            const SizedBox(width: 16),
                            // Text content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Event Pay',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.25),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          'NEW',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ).animate(
                                        onPlay: (controller) => controller.repeat(reverse: true),
                                      ).fadeIn(duration: 600.ms).then().shimmer(
                                        duration: 1800.ms,
                                        color: Colors.white.withValues(alpha: 0.6),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Collect money for trips, farewells & events with a single QR',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 13,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 450.ms).slideX(begin: 0.05, end: 0, duration: 400.ms),

                  // 🏦 Financial Hub — Merge Accounts Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GestureDetector(
                      onTap: () => context.push(AppRoutes.financialHub),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF059669),
                              Color(0xFF0D9488),
                              Color(0xFF14B8A6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF059669).withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                              ),
                              child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 28),
                            ).animate(
                              onPlay: (controller) => controller.repeat(reverse: true),
                            ).scaleXY(begin: 1.0, end: 1.08, duration: 2200.ms, curve: Curves.easeInOut),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('Financial Hub',
                                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.25),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                                      ).animate(
                                        onPlay: (controller) => controller.repeat(reverse: true),
                                      ).fadeIn(duration: 600.ms).then().shimmer(duration: 1800.ms, color: Colors.white.withValues(alpha: 0.6)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Merge bank accounts & track spending with AA-powered insights',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, height: 1.3)),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.8), size: 18),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 550.ms).slideX(begin: 0.05, end: 0, duration: 400.ms),

                  // 🤖 PayGo AI Assistant Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GestureDetector(
                      onTap: () => context.push(AppRoutes.aiAssistant),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF6C3CE1),
                              Color(0xFF8B5CF6),
                              Color(0xFFA78BFA),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C3CE1).withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.smart_toy_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ).animate(
                              onPlay: (controller) => controller.repeat(reverse: true),
                            ).scaleXY(
                              begin: 1.0,
                              end: 1.08,
                              duration: 2000.ms,
                              curve: Curves.easeInOut,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'PayGo AI',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.25),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          'BETA',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ).animate(
                                        onPlay: (controller) => controller.repeat(reverse: true),
                                      ).fadeIn(duration: 600.ms).then().shimmer(
                                        duration: 1800.ms,
                                        color: Colors.white.withValues(alpha: 0.6),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Your personal financial assistant — expenses, investments & smart payments',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.8), size: 18),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 600.ms).slideX(begin: 0.05, end: 0, duration: 400.ms),

                  // Free Tools
                  SectionCard(
                    title: 'Free Tools',
                    child: HorizontalScrollGrid(
                      itemWidth: 130,
                      itemHeight: 120,
                      items: [
                        HorizontalScrollItem(icon: Icons.speed_rounded, label: 'Check Credit\nScore'),
                        HorizontalScrollItem(icon: Icons.notifications_active_rounded, label: 'Gold Price\nAlerts'),
                        HorizontalScrollItem(icon: Icons.pie_chart_rounded, label: 'Track Your\nSpends'),
                        HorizontalScrollItem(icon: Icons.confirmation_number_rounded, label: 'IRCTC PNR\nStatus'),
                        HorizontalScrollItem(
                          icon: Icons.smart_toy_rounded, 
                          label: 'Ask PayGo\nAI',
                          onTap: () => context.push(AppRoutes.aiAssistant),
                        ),
                        HorizontalScrollItem(icon: Icons.flight_takeoff_rounded, label: 'Track Flight\nStatus'),
                        HorizontalScrollItem(icon: Icons.train_rounded, label: 'Live Train\nStatus'),
                        HorizontalScrollItem(icon: Icons.receipt_long_rounded, label: 'Traffic\nChallans'),
                        HorizontalScrollItem(icon: Icons.group_rounded, label: 'Split Bills\nEasily'),
                      ],
                    ),
                  ),

                  // Do More
                  SectionCard(
                    title: 'Do More with PayGo',
                    child: IconGrid(
                      items: [
                        IconGridItem(icon: Icons.local_offer_rounded, label: 'Cashback & Offers'),
                        IconGridItem(icon: Icons.card_giftcard_rounded, label: 'Gift Vouchers'),
                        IconGridItem(icon: Icons.star_rounded, label: 'Claim Deals'),
                        IconGridItem(icon: Icons.grid_view_rounded, label: 'See All Services'),
                      ],
                    ),
                  ),

                  // Referral Nudge
                  _ReferralNudge(isDark: isDark),

                  const SizedBox(height: 100), // FAB clearance
                ],
              ),
            ),
          ),
        ],
      ), // end Column
          // Floating PayGo AI Button
          Positioned(
            bottom: 24,
            right: 16,
            child: GestureDetector(
              onTap: () => context.push(AppRoutes.aiAssistant),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6C3CE1), Color(0xFF8B5CF6)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C3CE1).withValues(alpha: 0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 28),
              ).animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              ).scaleXY(begin: 1.0, end: 1.06, duration: 2000.ms, curve: Curves.easeInOut),
            ),
          ),
        ],
      ), // end Stack
      // Bottom Navigation
      bottomNavigationBar: _BottomNavBar(
        onTap: (index) {
          switch (index) {
            case 0: break; // Already on home
            case 1: context.push(AppRoutes.billsAndRecharges);
            case 2: break; // QR handled by FAB
            case 3: context.push(AppRoutes.messages);
            case 4: context.push(AppRoutes.myQR);
          }
        },
      ),

      // FAB
      floatingActionButton: FabScanQR(
        onPressed: () => context.push(AppRoutes.scanQR),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// ── Private Components ──

class _OfferBanner extends StatelessWidget {
  final bool isDark;
  const _OfferBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: PayGoColors.goldGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Exclusive Offer for You! 🎉',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Claim your cashback now',
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Claim',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8C00)),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;

  const _QuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: Colors.white),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}

class _ReferralNudge extends StatelessWidget {
  final bool isDark;
  const _ReferralNudge({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? PayGoColors.darkCard : PayGoColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: PayGoColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('❤️', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You ❤ PayGo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'You\'re 1 referral away from Assured ₹60',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16,
            color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final ValueChanged<int> onTap;
  const _BottomNavBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Bills'),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_rounded), label: 'Scan'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded), label: 'Messages'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
      ],
    );
  }
}
