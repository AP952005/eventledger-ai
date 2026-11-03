/// PayGo — Spending Summary Screen
/// Income/Expenses/Savings, category breakdown bars, period selector, budget insights.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../services/financial_service.dart';

class SpendingSummaryScreen extends StatefulWidget {
  const SpendingSummaryScreen({super.key});

  @override
  State<SpendingSummaryScreen> createState() => _SpendingSummaryScreenState();
}

class _SpendingSummaryScreenState extends State<SpendingSummaryScreen> {
  String _period = 'this_month';
  Map<String, dynamic> _summary = {};
  bool _isLoading = true;

  static const _periodLabels = {
    'this_month': 'This Month', 'last_month': 'Last Month',
    '3_months': '3 Months', '6_months': '6 Months',
  };

  static const _catColors = {
    'FOOD': Color(0xFFF97316), 'SHOPPING': Color(0xFF8B5CF6),
    'TRANSPORT': Color(0xFF3B82F6), 'BILLS': Color(0xFFEF4444),
    'INCOME': Color(0xFF22C55E), 'RENT': Color(0xFF14B8A6),
    'OTHER': Color(0xFF6B7280),
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final summary = await FinancialService.getSummary(period: _period);
    setState(() { _summary = summary; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Summary'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period selector
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _periodLabels.entries.map((e) {
                        final isSelected = _period == e.key;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () { _period = e.key; _load(); },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF059669) : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isSelected ? const Color(0xFF059669) : Colors.grey.shade400),
                              ),
                              child: Text(e.value, style: TextStyle(fontSize: 13,
                                color: isSelected ? Colors.white : null, fontWeight: isSelected ? FontWeight.w600 : null)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Summary cards
                  Row(
                    children: [
                      _SummaryCard(label: 'Income', amount: (_summary['income'] as num?)?.toDouble() ?? 0,
                        icon: Icons.trending_up_rounded, color: Colors.green, isDark: isDark),
                      const SizedBox(width: 10),
                      _SummaryCard(label: 'Expenses', amount: (_summary['expenses'] as num?)?.toDouble() ?? 0,
                        icon: Icons.trending_down_rounded, color: Colors.red, isDark: isDark),
                      const SizedBox(width: 10),
                      _SummaryCard(label: 'Savings', amount: (_summary['savings'] as num?)?.toDouble() ?? 0,
                        icon: Icons.savings_rounded, color: const Color(0xFF059669), isDark: isDark),
                    ],
                  ).animate().fadeIn(duration: 400.ms),

                  // Savings rate
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
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
                        const Icon(Icons.pie_chart_rounded, size: 32, color: Color(0xFF059669)),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Savings Rate', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            Text('${((_summary['savings_rate'] as num?)?.toDouble() ?? 0).toStringAsFixed(1)}%',
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Category Breakdown
                  const SizedBox(height: 24),
                  const Text('Category Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ..._buildCategoryBars(),

                  // Budget Insights
                  const SizedBox(height: 24),
                  const Text('Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _InsightCard(
                    icon: Icons.local_fire_department_rounded,
                    color: Colors.orange,
                    title: 'Avg. Daily Spend',
                    value: '₹${((_summary['avg_daily_spend'] as num?)?.toDouble() ?? 0).toStringAsFixed(0)}',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  if (_summary['highest_expense'] != null)
                    _InsightCard(
                      icon: Icons.arrow_upward_rounded,
                      color: Colors.red,
                      title: 'Highest Expense',
                      value: '₹${(_summary['highest_expense']['amount'] as num).toStringAsFixed(0)} at ${_summary['highest_expense']['merchant']}',
                      isDark: isDark,
                    ),
                  const SizedBox(height: 8),
                  if (_summary['most_frequent_merchant'] != null)
                    _InsightCard(
                      icon: Icons.repeat_rounded,
                      color: Colors.blue,
                      title: 'Most Frequent',
                      value: _summary['most_frequent_merchant'],
                      isDark: isDark,
                    ),
                  if (_summary['top_category'] != null) ...[
                    const SizedBox(height: 8),
                    _InsightCard(
                      icon: Icons.category_rounded,
                      color: _catColors[_summary['top_category']] ?? Colors.grey,
                      title: 'Top Category',
                      value: _summary['top_category'],
                      isDark: isDark,
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildCategoryBars() {
    final breakdown = (_summary['category_breakdown'] as Map<String, dynamic>?) ?? {};
    if (breakdown.isEmpty) return [const Text('No spending data', style: TextStyle(color: Colors.grey))];

    final total = breakdown.values.fold(0.0, (s, v) => s + (v as num).toDouble());
    final sorted = breakdown.entries.toList()..sort((a, b) => (b.value as num).compareTo(a.value as num));

    return sorted.map((e) {
      final amount = (e.value as num).toDouble();
      final pct = total > 0 ? amount / total : 0.0;
      final color = _catColors[e.key] ?? const Color(0xFF6B7280);

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
                Text('₹${amount.toStringAsFixed(0)} (${(pct * 100).toStringAsFixed(0)}%)',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: sorted.indexOf(e) * 80));
    }).toList();
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _SummaryCard({required this.label, required this.amount, required this.icon, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 8),
            Text('₹${(amount / 1000).toStringAsFixed(1)}K',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: TextStyle(fontSize: 11,
              color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary)),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final bool isDark;

  const _InsightCard({required this.icon, required this.color, required this.title, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? PayGoColors.darkCardElevated : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 11, color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
