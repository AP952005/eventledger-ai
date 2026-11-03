/// PayGo — Financial Hub Screen
/// Main dashboard: net worth, income/expenses/savings, quick actions, recent transactions.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';
import '../../services/financial_service.dart';
import '../../models/financial_transaction.dart';

class FinancialHubScreen extends StatefulWidget {
  const FinancialHubScreen({super.key});

  @override
  State<FinancialHubScreen> createState() => _FinancialHubScreenState();
}

class _FinancialHubScreenState extends State<FinancialHubScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _summary = {};
  List<FinancialTransaction> _recentTxns = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      if (FinancialService.hasLinkedAccounts) {
        final summary = await FinancialService.getSummary(period: 'this_month');
        final txns = await FinancialService.getTransactions();
        setState(() {
          _summary = summary;
          _recentTxns = txns.take(10).toList();
        });
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasAccounts = FinancialService.hasLinkedAccounts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Hub'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        actions: [
          if (hasAccounts)
            IconButton(
              icon: const Icon(Icons.settings_rounded),
              onPressed: () => context.push(AppRoutes.consentManagement),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasAccounts
              ? _buildDashboard(isDark)
              : _buildEmptyState(isDark),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF0D9488)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.account_balance_rounded, size: 48, color: Colors.white),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            const Text('Merge Your Accounts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(
              'Link your bank accounts to see unified spending insights, track expenses, and manage your finances — all in one place.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.connectAccount),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Connect Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(bool isDark) {
    final income = (_summary['income'] as num?)?.toDouble() ?? 0;
    final expenses = (_summary['expenses'] as num?)?.toDouble() ?? 0;
    final savings = (_summary['savings'] as num?)?.toDouble() ?? 0;
    final savingsRate = (_summary['savings_rate'] as num?)?.toDouble() ?? 0;
    final topCategory = _summary['top_category'] as String?;
    final totalBalance = FinancialService.totalBalance;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Net Worth Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFF059669), Color(0xFF0D9488), Color(0xFF14B8A6)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: const Color(0xFF059669).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Balance', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('₹${_formatAmount(totalBalance)}',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _SummaryChip(label: 'Income', amount: income, icon: Icons.trending_up_rounded, color: Colors.greenAccent),
                      const SizedBox(width: 12),
                      _SummaryChip(label: 'Expenses', amount: expenses, icon: Icons.trending_down_rounded, color: Colors.redAccent),
                      const SizedBox(width: 12),
                      _SummaryChip(label: 'Saved', amount: savings, icon: Icons.savings_rounded, color: Colors.amberAccent),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

            // Savings Rate Badge
            if (savingsRate > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: savingsRate >= 30 ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: savingsRate >= 30 ? Colors.green.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(savingsRate >= 30 ? Icons.emoji_events_rounded : Icons.info_outline_rounded,
                        color: savingsRate >= 30 ? Colors.green : Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        savingsRate >= 30
                            ? 'Great! You saved ${savingsRate.toStringAsFixed(0)}% this month 🎉'
                            : 'You saved ${savingsRate.toStringAsFixed(0)}% — try to save more!',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                          color: savingsRate >= 30 ? Colors.green : Colors.orange),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _QuickAction(icon: Icons.account_balance_rounded, label: 'Accounts',
                    onTap: () => context.push(AppRoutes.accountList)),
                  const SizedBox(width: 12),
                  _QuickAction(icon: Icons.receipt_long_rounded, label: 'Transactions',
                    onTap: () => context.push(AppRoutes.financialTransactions)),
                  const SizedBox(width: 12),
                  _QuickAction(icon: Icons.pie_chart_rounded, label: 'Spending',
                    onTap: () => context.push(AppRoutes.spendingSummary)),
                  const SizedBox(width: 12),
                  _QuickAction(icon: Icons.repeat_rounded, label: 'Recurring',
                    onTap: () => context.push(AppRoutes.recurringTransactions)),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

            // Top Category
            if (topCategory != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text('Top spending: $topCategory',
                  style: TextStyle(fontSize: 13, color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary)),
              ),

            // Recent Transactions
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  TextButton(onPressed: () => context.push(AppRoutes.financialTransactions), child: const Text('View All')),
                ],
              ),
            ),

            ..._recentTxns.map((t) => _TransactionRow(txn: t, isDark: isDark)),

            // Add another account
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.connectAccount),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Connect Another Account'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(2)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _SummaryChip({required this.label, required this.amount, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text('₹${(amount / 1000).toStringAsFixed(1)}K',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? PayGoColors.darkCardElevated : PayGoColors.lightSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider, width: 0.5),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: const Color(0xFF059669)),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final FinancialTransaction txn;
  final bool isDark;

  const _TransactionRow({required this.txn, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final catColors = {
      'FOOD': const Color(0xFFF97316), 'SHOPPING': const Color(0xFF8B5CF6),
      'TRANSPORT': const Color(0xFF3B82F6), 'BILLS': const Color(0xFFEF4444),
      'INCOME': const Color(0xFF22C55E), 'RENT': const Color(0xFF14B8A6),
      'OTHER': const Color(0xFF6B7280),
    };
    final catIcons = {
      'FOOD': Icons.restaurant_rounded, 'SHOPPING': Icons.shopping_bag_rounded,
      'TRANSPORT': Icons.directions_car_rounded, 'BILLS': Icons.receipt_long_rounded,
      'INCOME': Icons.trending_up_rounded, 'RENT': Icons.home_rounded,
      'OTHER': Icons.more_horiz_rounded,
    };
    final color = catColors[txn.category] ?? const Color(0xFF6B7280);
    final icon = catIcons[txn.category] ?? Icons.more_horiz_rounded;

    return ListTile(
      leading: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, size: 20, color: color),
      ),
      title: Text(txn.merchant ?? txn.description, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text('${txn.category} • ${_formatDate(txn.date)}',
        style: TextStyle(fontSize: 12, color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary)),
      trailing: Text(
        '${txn.isCredit ? '+' : '-'}₹${txn.amount.toStringAsFixed(0)}',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: txn.isCredit ? Colors.green : Colors.red),
      ),
    );
  }

  String _formatDate(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month]}';
  }
}
