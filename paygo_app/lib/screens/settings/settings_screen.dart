/// PayGo — Settings Screen
/// App settings with dark mode toggle and navigation items.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/list_item_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Appearance / Dark Mode
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? PayGoColors.darkCard : PayGoColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider, width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: PayGoColors.oceanBlue.withValues(alpha: isDark ? 0.2 : 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: PayGoColors.oceanBlue, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dark Mode', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                          color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.lightTextPrimary)),
                        Text(isDark ? 'Currently enabled' : 'Currently disabled',
                          style: TextStyle(fontSize: 12,
                            color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary)),
                      ],
                    ),
                  ),
                  Switch(
                    value: isDark,
                    onChanged: (_) => themeNotifier.toggleTheme(),
                    activeTrackColor: PayGoColors.oceanBlue,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Account', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary)),
            ),

            ListItemCard(icon: Icons.person_outline_rounded, title: 'Profile',
              subtitle: 'Name, Phone, Email', onTap: () {}),
            ListItemCard(icon: Icons.lock_outline_rounded, title: 'Security',
              subtitle: 'UPI PIN, Biometrics', onTap: () {}),
            ListItemCard(icon: Icons.notifications_outlined, title: 'Notifications',
              subtitle: 'Push & in-app alerts', onTap: () {}),
            ListItemCard(icon: Icons.language_rounded, title: 'Language',
              subtitle: 'English', onTap: () {}),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Payments', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary)),
            ),

            ListItemCard(icon: Icons.account_balance_rounded, title: 'Linked Bank Accounts',
              subtitle: 'Manage your banks', onTap: () {}),
            ListItemCard(icon: Icons.sync_rounded, title: 'Automatic Payments',
              subtitle: 'UPI Autopay mandates', onTap: () {}),
            ListItemCard(icon: Icons.receipt_long_rounded, title: 'Transaction Limits',
              subtitle: 'Daily & per-transaction limits', onTap: () {}),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Support', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary)),
            ),

            ListItemCard(icon: Icons.help_outline_rounded, title: 'Help & Support',
              subtitle: 'FAQs, Contact Us', onTap: () {}),
            ListItemCard(icon: Icons.info_outline_rounded, title: 'About PayGo',
              subtitle: 'Version 1.0.0', onTap: () {}),
            ListItemCard(icon: Icons.description_outlined, title: 'Terms & Privacy',
              subtitle: 'Legal information', onTap: () {}),

            const SizedBox(height: 16),

            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.logout_rounded, color: PayGoColors.error),
                  label: const Text('Log Out', style: TextStyle(color: PayGoColors.error, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: PayGoColors.error.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
