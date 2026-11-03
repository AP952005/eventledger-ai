/// PayGo — Recurring Transactions Screen
/// Auto-detected subscriptions, EMIs, rent, salary.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../services/financial_service.dart';

class RecurringTransactionsScreen extends StatefulWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  State<RecurringTransactionsScreen> createState() => _RecurringTransactionsScreenState();
}

class _RecurringTransactionsScreenState extends State<RecurringTransactionsScreen> {
  List<Map<String, dynamic>> _recurring = [];
  bool _isLoading = true;

  static const _catColors = {
    'FOOD': Color(0xFFF97316), 'SHOPPING': Color(0xFF8B5CF6),
    'TRANSPORT': Color(0xFF3B82F6), 'BILLS': Color(0xFFEF4444),
    'INCOME': Color(0xFF22C55E), 'RENT': Color(0xFF14B8A6),
    'OTHER': Color(0xFF6B7280),
  };

  static const _catIcons = {
    'FOOD': Icons.restaurant_rounded, 'SHOPPING': Icons.shopping_bag_rounded,
    'TRANSPORT': Icons.directions_car_rounded, 'BILLS': Icons.receipt_long_rounded,
    'INCOME': Icons.trending_up_rounded, 'RENT': Icons.home_rounded,
    'OTHER': Icons.more_horiz_rounded,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final data = await FinancialService.getRecurringTransactions();
    setState(() { _recurring = data; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Transactions'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recurring.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.repeat_rounded, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No recurring transactions detected', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      SizedBox(height: 8),
                      Text('Link an account to detect subscriptions & recurring payments',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _recurring.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Header info
                      final totalMonthly = _recurring.fold(0.0, (s, r) {
                        return s + ((r['type'] == 'CREDIT' ? 0 : (r['avg_amount'] as num).toDouble()));
                      });
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            const Color(0xFF059669).withValues(alpha: 0.08),
                            const Color(0xFF14B8A6).withValues(alpha: 0.04),
                          ]),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.repeat_rounded, size: 28, color: Color(0xFF059669)),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Est. Monthly Recurring', style: TextStyle(fontSize: 13)),
                                Text('₹${totalMonthly.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                              ],
                            ),
                            const Spacer(),
                            Text('${_recurring.length} items', style: TextStyle(fontSize: 12,
                              color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary)),
                          ],
                        ),
                      );
                    }

                    final r = _recurring[index - 1];
                    final cat = r['category'] as String? ?? 'OTHER';
                    final color = _catColors[cat] ?? const Color(0xFF6B7280);
                    final icon = _catIcons[cat] ?? Icons.more_horiz_rounded;
                    final isIncome = r['type'] == 'CREDIT';

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? PayGoColors.darkCardElevated : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                            child: Icon(icon, size: 20, color: color),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r['merchant'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                                Row(
                                  children: [
                                    Text('${r['frequency']}', style: TextStyle(fontSize: 12,
                                      color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary)),
                                    const SizedBox(width: 6),
                                    const Text('•', style: TextStyle(color: Colors.grey)),
                                    const SizedBox(width: 6),
                                    Text('${r['occurrence_count']}x detected', style: TextStyle(fontSize: 12,
                                      color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isIncome ? '+' : '-'}₹${(r['avg_amount'] as num).toStringAsFixed(0)}',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isIncome ? Colors.green : Colors.red),
                              ),
                              Text('avg/mo', style: TextStyle(fontSize: 10,
                                color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
