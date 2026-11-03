/// PayGo — My QR / Receive Money Screen
/// QR code display, profile, bank selector, settings list.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';
import '../../services/mock_data.dart';
import '../../widgets/list_item_card.dart';

class MyQRScreen extends StatelessWidget {
  const MyQRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBank = user.primaryBank;
    final qrData = 'upi://pay?pa=${user.upiId}&pn=${user.name}&cu=INR';

    return Scaffold(
      appBar: AppBar(
        title: const Text('PayGo Accepted Here'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Profile Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: PayGoColors.oceanBlue,
                    child: Text(user.initials, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(user.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                              color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.lightTextPrimary)),
                            if (user.isVerified) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.verified_rounded, size: 18, color: PayGoColors.oceanBlue),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(user.upiId, style: TextStyle(fontSize: 13,
                          color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: user.upiId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('UPI ID copied!')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: PayGoColors.oceanBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.copy_rounded, size: 18, color: PayGoColors.oceanBlue),
                    ),
                  ),
                ],
              ),
            ),

            // UPI interop banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PayGoColors.oceanBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PayGoColors.oceanBlue.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.language_rounded, size: 20, color: PayGoColors.oceanBlue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Receive money from all UPI apps',
                      style: TextStyle(fontSize: 13, color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.lightTextPrimary)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: PayGoColors.oceanBlue, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Allow', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ],
              ),
            ),

            // QR Code
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 4)),
                ],
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 220,
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: PayGoColors.deepNavy),
                dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: PayGoColors.deepNavy),
              ),
            ),

            // Bank selector
            if (primaryBank != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? PayGoColors.darkCard : PayGoColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider, width: 0.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_rounded, size: 20, color: PayGoColors.oceanBlue),
                    const SizedBox(width: 10),
                    Text('${primaryBank.bankName} •••• ${primaryBank.accountLast4}',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                        color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.lightTextPrimary)),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Share / Add to Home
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share QR — demo mode'))),
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Share'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add to Home — demo mode'))),
                      icon: const Icon(Icons.add_to_home_screen_rounded, size: 18),
                      label: const Text('Add to Home'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Divider(indent: 16, endIndent: 16),

            // Settings List
            ListItemCard(icon: Icons.child_care_rounded, title: 'Pocket Money', subtitle: 'Give dependents UPI access', badge: 'New',
              onTap: () {}),
            ListItemCard(icon: Icons.contrast_rounded, title: 'Appearance', subtitle: 'Dark mode (beta)',
              onTap: () => context.push(AppRoutes.settings)),
            ListItemCard(icon: Icons.settings_rounded, title: 'UPI & Payment Settings', subtitle: 'UPI PIN, Bank Accounts & more',
              onTap: () {}),
            ListItemCard(icon: Icons.sync_rounded, title: 'Automatic Payments', subtitle: 'Manage UPI Autopay mandates',
              onTap: () {}),
            ListItemCard(icon: Icons.receipt_long_rounded, title: 'Orders & Bookings', subtitle: 'Payments, Recharge, Travel',
              onTap: () {}),
            ListItemCard(icon: Icons.person_outline_rounded, title: 'Profile', subtitle: 'Privacy, Notification & Language',
              onTap: () {}),
            ListItemCard(icon: Icons.help_outline_rounded, title: 'Help & Support', subtitle: 'Customer Support, FAQs',
              onTap: () {}),
            ListItemCard(icon: Icons.card_giftcard_rounded, title: 'Refer & Win', subtitle: 'Assured ₹60',
              onTap: () {}),

            const SizedBox(height: 16),

            // Security Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: PayGoColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_rounded, size: 28, color: Colors.white),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Security Shield', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('Protect your account', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Activate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: PayGoColors.deepNavy)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Brand Footer
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Pay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                      color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.deepNavy)),
                    const Text('Go', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: PayGoColors.oceanBlue)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Crafted & Owned in India 🇮🇳', style: TextStyle(fontSize: 12,
                  color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary)),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
