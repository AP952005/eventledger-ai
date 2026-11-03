/// PayGo — To Bank Account Screen
/// Bank transfer form with account number, IFSC, and saved beneficiaries.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';

class ToBankAccountScreen extends StatefulWidget {
  const ToBankAccountScreen({super.key});

  @override
  State<ToBankAccountScreen> createState() => _ToBankAccountScreenState();
}

class _ToBankAccountScreenState extends State<ToBankAccountScreen> {
  final _accountController = TextEditingController();
  final _confirmController = TextEditingController();
  final _ifscController = TextEditingController();

  @override
  void dispose() {
    _accountController.dispose();
    _confirmController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  void _verify() {
    if (_accountController.text.isEmpty || _ifscController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    if (_accountController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Account numbers don\'t match'), backgroundColor: PayGoColors.error),
      );
      return;
    }
    context.push('${AppRoutes.confirmPayment}?name=Bank%20Transfer&upiId=${_accountController.text}@${_ifscController.text}');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('To Bank Account'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PayGoColors.oceanBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PayGoColors.oceanBlue.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: PayGoColors.oceanBlue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Enter the bank account details of the person you want to transfer money to.',
                      style: TextStyle(fontSize: 12, color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel('Account Number', isDark),
            const SizedBox(height: 8),
            TextField(
              controller: _accountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Enter account number'),
            ),
            const SizedBox(height: 16),

            _buildLabel('Confirm Account Number', isDark),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Re-enter account number'),
            ),
            const SizedBox(height: 16),

            _buildLabel('IFSC Code', isDark),
            const SizedBox(height: 8),
            TextField(
              controller: _ifscController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(hintText: 'e.g. SBIN0001234'),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _verify,
                child: const Text('Verify & Proceed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),

            const SizedBox(height: 32),

            // Saved Beneficiaries
            Text('Saved Beneficiaries', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
              color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.lightTextPrimary)),
            const SizedBox(height: 12),

            _BeneficiaryTile(name: 'Priya Sharma', bank: 'ICICI Bank', accountLast4: '1190', isDark: isDark,
              onTap: () => context.push('${AppRoutes.confirmPayment}?name=Priya%20Sharma&upiId=priya.s@paygo')),
            _BeneficiaryTile(name: 'Rahul Gupta', bank: 'Axis Bank', accountLast4: '6643', isDark: isDark,
              onTap: () => context.push('${AppRoutes.confirmPayment}?name=Rahul%20Gupta&upiId=rahul.g@paygo')),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
      color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary));
  }
}

class _BeneficiaryTile extends StatelessWidget {
  final String name;
  final String bank;
  final String accountLast4;
  final bool isDark;
  final VoidCallback onTap;

  const _BeneficiaryTile({required this.name, required this.bank, required this.accountLast4, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? PayGoColors.darkCard : PayGoColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider, width: 0.5),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: PayGoColors.oceanBlue.withValues(alpha: 0.15),
              child: Text(name[0], style: const TextStyle(fontWeight: FontWeight.w700, color: PayGoColors.oceanBlue)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                    color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.lightTextPrimary)),
                  Text('$bank •••• $accountLast4', style: TextStyle(fontSize: 12,
                    color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary),
          ],
        ),
      ),
    );
  }
}
