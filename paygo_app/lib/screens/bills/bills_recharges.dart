/// PayGo — Bills & Recharges Screen
/// Full bills section with search, saved billers, category grids, and promos.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../services/mock_data.dart';
import '../../widgets/section_card.dart';
import '../../widgets/icon_grid.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/badge_chip.dart';

class BillsRechargesScreen extends StatelessWidget {
  const BillsRechargesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final billers = MockData.savedBillers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bills & Recharges'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            const PayGoSearchBar(placeholder: 'Search for Electricity, Mobile...'),

            // Saved Billers
            if (billers.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text('Saved Billers', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              ),
              ...billers.map((b) => _SavedBillerTile(biller: b, isDark: isDark)),
              const SizedBox(height: 8),
            ],

            // Popular
            SectionCard(
              title: 'Popular',
              child: IconGrid(
                items: [
                  IconGridItem(icon: Icons.phone_android_rounded, label: 'Mobile Recharge'),
                  IconGridItem(icon: Icons.credit_card_rounded, label: 'Credit Card Bill'),
                  IconGridItem(icon: Icons.account_balance_rounded, label: 'Pay Loan EMI'),
                  IconGridItem(icon: Icons.directions_car_rounded, label: 'FASTag Recharge', badge: 'No Fee'),
                ],
              ),
            ),

            // Home Bills
            SectionCard(
              title: 'Home Bills',
              child: IconGrid(
                items: [
                  IconGridItem(icon: Icons.bolt_rounded, label: 'Electricity Bill', badge: 'Flat ₹30'),
                  IconGridItem(icon: Icons.water_drop_rounded, label: 'Water Bill'),
                  IconGridItem(icon: Icons.local_fire_department_rounded, label: 'Piped Gas Bill'),
                  IconGridItem(icon: Icons.propane_tank_rounded, label: 'Book LPG'),
                  IconGridItem(icon: Icons.satellite_alt_rounded, label: 'DTH Recharge', badge: 'Flat ₹15'),
                  IconGridItem(icon: Icons.tv_rounded, label: 'Cable TV'),
                  IconGridItem(icon: Icons.wifi_rounded, label: 'Wifi / Landline'),
                  IconGridItem(icon: Icons.phone_iphone_rounded, label: 'Mobile Postpaid'),
                ],
              ),
            ),

            // Promo Banner
            Container(
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
                        const Text('Pay Bill, Get Gold ✨', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Pay any bill above ₹500', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: const Text('Pay Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF8C00))),
                  ),
                ],
              ),
            ),

            // Vehicle & Daily Travel
            SectionCard(
              title: 'Vehicle & Daily Travel',
              child: IconGrid(
                items: [
                  IconGridItem(icon: Icons.directions_car_rounded, label: 'FASTag'),
                  IconGridItem(icon: Icons.receipt_long_rounded, label: 'Traffic Challans'),
                  IconGridItem(icon: Icons.nfc_rounded, label: 'NCMC Recharge'),
                  IconGridItem(icon: Icons.subway_rounded, label: 'Metro Tickets'),
                  IconGridItem(icon: Icons.directions_bus_rounded, label: 'City Bus'),
                  IconGridItem(icon: Icons.ev_station_rounded, label: 'EV Recharge'),
                  IconGridItem(icon: Icons.directions_car_rounded, label: 'Car Insurance'),
                  IconGridItem(icon: Icons.two_wheeler_rounded, label: 'Bike Insurance'),
                ],
              ),
            ),

            // Gift Cards
            SectionCard(
              title: 'Gift Cards & Vouchers',
              child: IconGrid(
                items: [
                  IconGridItem(icon: Icons.play_circle_rounded, label: 'Google Play Code'),
                  IconGridItem(icon: Icons.apple_rounded, label: 'App Store Code', badge: '4% Off'),
                  IconGridItem(icon: Icons.sports_esports_rounded, label: 'Game Top-up'),
                  IconGridItem(icon: Icons.card_giftcard_rounded, label: 'All Vouchers'),
                ],
              ),
            ),

            // Secure Future
            SectionCard(
              title: 'Secure your Future',
              child: IconGrid(
                items: [
                  IconGridItem(icon: Icons.assured_workload_rounded, label: 'LIC Premium'),
                  IconGridItem(icon: Icons.verified_user_rounded, label: 'Insurance Premium'),
                  IconGridItem(icon: Icons.savings_rounded, label: 'NPS'),
                  IconGridItem(icon: Icons.health_and_safety_rounded, label: 'Health Insurance'),
                ],
              ),
            ),

            // Bank Offer Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? PayGoColors.darkCard : PayGoColors.lightSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PayGoColors.oceanBlue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.credit_card_rounded, color: PayGoColors.oceanBlue, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Get up to ₹150 Off using Credit Cards',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                        color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.lightTextPrimary),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 14,
                    color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary),
                ],
              ),
            ),

            // Other Services
            SectionCard(
              title: 'Other Services',
              child: IconGrid(
                items: [
                  IconGridItem(icon: Icons.account_balance_rounded, label: 'Municipal'),
                  IconGridItem(icon: Icons.apartment_rounded, label: 'Apartments'),
                  IconGridItem(icon: Icons.key_rounded, label: 'Rentals'),
                  IconGridItem(icon: Icons.electric_meter_rounded, label: 'Prepaid Meter'),
                  IconGridItem(icon: Icons.groups_rounded, label: 'Clubs'),
                  IconGridItem(icon: Icons.volunteer_activism_rounded, label: 'Donations'),
                  IconGridItem(icon: Icons.temple_hindu_rounded, label: 'Devotion'),
                  IconGridItem(icon: Icons.subscriptions_rounded, label: 'Subscriptions'),
                  IconGridItem(icon: Icons.school_rounded, label: 'Education Fees'),
                  IconGridItem(icon: Icons.local_gas_station_rounded, label: 'Fleet Card'),
                  IconGridItem(icon: Icons.people_rounded, label: 'Agent Collection'),
                ],
                columns: 4,
              ),
            ),

            // Bottom items
            _BottomListItem(
              icon: Icons.local_offer_rounded,
              title: 'Cashback and Offers',
              subtitle: 'Explore all offers',
              isDark: isDark,
            ),
            _BottomListItem(
              icon: Icons.sync_rounded,
              title: 'Manage Automatic Payments',
              subtitle: 'Setup / Edit UPI Autopay',
              isDark: isDark,
            ),
            _BottomListItem(
              icon: Icons.credit_card_rounded,
              title: 'Bank offers: Save up to ₹150',
              subtitle: null,
              isDark: isDark,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SavedBillerTile extends StatelessWidget {
  final dynamic biller;
  final bool isDark;
  const _SavedBillerTile({required this.biller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? PayGoColors.darkCard : PayGoColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: PayGoColors.oceanBlue.withValues(alpha: isDark ? 0.2 : 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_getCategoryIcon(biller.category), size: 20, color: PayGoColors.oceanBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(biller.providerName,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                    color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.lightTextPrimary)),
                Text('${biller.category.toUpperCase()} - ${biller.identifier}',
                  style: TextStyle(fontSize: 11,
                    color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary)),
              ],
            ),
          ),
          if (biller.autopayEnabled)
            const BadgeChip(text: 'Autopay', backgroundColor: Color(0x1A00C853), textColor: Color(0xFF00C853)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: PayGoColors.oceanBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Recharge', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'mobile': return Icons.phone_android_rounded;
      case 'electricity': return Icons.bolt_rounded;
      case 'dth': return Icons.satellite_alt_rounded;
      case 'gas': return Icons.local_fire_department_rounded;
      case 'credit_card': return Icons.credit_card_rounded;
      default: return Icons.receipt_rounded;
    }
  }
}

class _BottomListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isDark;

  const _BottomListItem({required this.icon, required this.title, this.subtitle, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: ListTile(
        leading: Icon(icon, color: PayGoColors.oceanBlue, size: 22),
        title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
          color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.lightTextPrimary)),
        subtitle: subtitle != null ? Text(subtitle!, style: TextStyle(fontSize: 12,
          color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary)) : null,
        trailing: Icon(Icons.arrow_forward_ios, size: 14,
          color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary),
      ),
    );
  }
}
