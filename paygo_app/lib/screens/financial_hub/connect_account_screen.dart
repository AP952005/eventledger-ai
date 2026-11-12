/// PayGo — Connect Account Screen
/// Shows connectable account types with Bank Account active and others "Coming soon".

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';

class ConnectAccountScreen extends StatelessWidget {
  const ConnectAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Account'),
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Connect your accounts', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Securely link your financial accounts to get unified insights.',
              style: TextStyle(fontSize: 14, color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary)),
            const SizedBox(height: 8),
            // Privacy Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_rounded, size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(child: Text('Your bank credentials are never stored or requested.',
                    style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500))),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bank Account — Active
            _AccountTypeCard(
              icon: Icons.account_balance_rounded,
              title: 'Bank Account',
              subtitle: 'See your complete transaction history',
              isAvailable: true,
              onTap: () => context.push(AppRoutes.consentScreen),
            ),
            const SizedBox(height: 16),

            // Investments — Coming soon
            _AccountTypeCard(
              icon: Icons.trending_up_rounded,
              title: 'Investments',
              subtitle: 'Mutual funds, stocks, FDs',
              isAvailable: false,
            ),
            const SizedBox(height: 16),

            // Credit Cards — Coming soon
            _AccountTypeCard(
              icon: Icons.credit_card_rounded,
              title: 'Credit Cards',
              subtitle: 'Track credit card spends',
              isAvailable: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isAvailable;
  final VoidCallback? onTap;

  const _AccountTypeCard({
    required this.icon, required this.title, required this.subtitle,
    required this.isAvailable, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? PayGoColors.darkCardElevated : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAvailable ? const Color(0xFF059669).withValues(alpha: 0.3) : (isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider),
            width: isAvailable ? 1.5 : 0.5,
          ),
          boxShadow: isAvailable ? [BoxShadow(color: const Color(0xFF059669).withValues(alpha: 0.08), blurRadius: 12)] : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: isAvailable ? const Color(0xFF059669).withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 24, color: isAvailable ? const Color(0xFF059669) : Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                    color: isAvailable ? null : Colors.grey)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 13,
                    color: isAvailable ? (isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary) : Colors.grey)),
                ],
              ),
            ),
            if (isAvailable)
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF059669))
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Text('Coming soon', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      ),
    );
  }
}
