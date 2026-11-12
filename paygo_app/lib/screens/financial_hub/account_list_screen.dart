/// PayGo — Account List Screen
/// Shows linked accounts with balances, unlink action, and add another button.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';
import '../../services/financial_service.dart';
import '../../models/financial_account.dart';

class AccountListScreen extends StatefulWidget {
  const AccountListScreen({super.key});

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  List<FinancialAccount> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final accounts = await FinancialService.getAccounts();
    setState(() { _accounts = accounts; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Linked Accounts'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _accounts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.account_balance_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No accounts linked yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => context.push(AppRoutes.connectAccount),
                        icon: const Icon(Icons.add),
                        label: const Text('Connect Account'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Existing Paytm Payments Bank (non-unlinkable)
                    _AccountCard(
                      bankName: 'Paytm Payments Bank',
                      accountType: 'UPI Account',
                      maskedNumber: 'XXXXXX4402',
                      balance: 2450.75,
                      holderName: 'Abishek',
                      lastSynced: 'Linked at registration',
                      isPermanent: true,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    // AA-linked accounts
                    ..._accounts.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AccountCard(
                        bankName: a.bankName,
                        accountType: a.accountType,
                        maskedNumber: a.maskedAccountNumber,
                        balance: a.balance,
                        holderName: a.holderName,
                        lastSynced: _formatDate(a.lastSynced),
                        isPermanent: false,
                        isDark: isDark,
                        onUnlink: () => _confirmUnlink(a),
                      ),
                    )),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => context.push(AppRoutes.connectAccount),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Another Account'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
    );
  }

  void _confirmUnlink(FinancialAccount account) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Unlink Account?'),
        content: Text('This will remove ${account.bankName} (${account.maskedAccountNumber}) and all its transaction data.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(c);
              await FinancialService.unlinkAccount(account.id);
              _load();
            },
            child: const Text('Unlink', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }
}

class _AccountCard extends StatelessWidget {
  final String bankName;
  final String accountType;
  final String maskedNumber;
  final double balance;
  final String holderName;
  final String lastSynced;
  final bool isPermanent;
  final bool isDark;
  final VoidCallback? onUnlink;

  const _AccountCard({
    required this.bankName, required this.accountType, required this.maskedNumber,
    required this.balance, required this.holderName, required this.lastSynced,
    required this.isPermanent, required this.isDark, this.onUnlink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? PayGoColors.darkCardElevated : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider, width: 0.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    Text(bankName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    Text('$accountType • $maskedNumber', style: TextStyle(fontSize: 12,
                      color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary)),
                  ],
                ),
              ),
              if (isPermanent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: PayGoColors.oceanBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Primary', style: TextStyle(fontSize: 10, color: PayGoColors.oceanBlue, fontWeight: FontWeight.w700)),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('AA Linked', style: TextStyle(fontSize: 10, color: Color(0xFF059669), fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Balance', style: TextStyle(fontSize: 11, color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary)),
                  Text('₹${balance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Holder: $holderName', style: TextStyle(fontSize: 11, color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary)),
                  Text(lastSynced, style: TextStyle(fontSize: 11, color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary)),
                ],
              ),
            ],
          ),
          if (!isPermanent && onUnlink != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onUnlink,
                icon: const Icon(Icons.link_off_rounded, size: 16, color: Colors.red),
                label: const Text('Unlink', style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
