/// PayGo — Mock Bank Approval Screen
/// Simulates the bank redirect for AA consent approval.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';
import '../../services/financial_service.dart';

class MockBankApprovalScreen extends StatefulWidget {
  const MockBankApprovalScreen({super.key});

  @override
  State<MockBankApprovalScreen> createState() => _MockBankApprovalScreenState();
}

class _MockBankApprovalScreenState extends State<MockBankApprovalScreen> {
  bool _isApproving = false;
  String? _approvingBank;

  Future<void> _approve(String bankName) async {
    setState(() { _isApproving = true; _approvingBank = bankName; });
    try {
      // Get last consent ID
      final consents = await FinancialService.listConsents();
      final pending = consents.where((c) => c.status == 'PENDING').lastOrNull;
      if (pending == null) throw Exception('No pending consent');

      // Approve
      await FinancialService.approveConsent(consentId: pending.consentId, bankName: bankName);

      // Sync accounts + transactions
      await FinancialService.syncAccounts(pending.consentId);

      if (mounted) {
        // Show success and navigate back to hub
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$bankName linked successfully!'), backgroundColor: Colors.green),
        );
        context.go(AppRoutes.financialHub);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    setState(() { _isApproving = false; _approvingBank = null; });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final banks = FinancialService.availableBanks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Approve with Bank'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose a bank to link', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('This simulates the bank redirect in the Account Aggregator flow.',
              style: TextStyle(fontSize: 13, color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary)),
            const SizedBox(height: 24),

            Expanded(
              child: ListView.separated(
                itemCount: banks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final bank = banks[index];
                  final name = bank['name'] as String;
                  final isThis = _approvingBank == name;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? PayGoColors.darkCardElevated : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: index == 0 ? const Color(0xFF059669).withValues(alpha: 0.4) : (isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider),
                        width: index == 0 ? 1.5 : 0.5,
                      ),
                      boxShadow: index == 0 ? [BoxShadow(color: const Color(0xFF059669).withValues(alpha: 0.06), blurRadius: 10)] : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF059669).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.account_balance_rounded, size: 22, color: Color(0xFF059669)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                  if (index == 0) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF059669).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text('Recommended', style: TextStyle(fontSize: 9, color: Color(0xFF059669), fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text('Savings Account', style: TextStyle(fontSize: 12,
                                color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary)),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 90,
                          child: ElevatedButton(
                            onPressed: _isApproving ? null : () => _approve(name),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: isThis && _isApproving
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Approve', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 100 * index));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
