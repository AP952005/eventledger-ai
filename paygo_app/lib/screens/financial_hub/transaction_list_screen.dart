/// PayGo — Transaction List Screen
/// Unified transaction feed with filters: account, category, date range.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../services/financial_service.dart';
import '../../models/financial_transaction.dart';
import '../../models/financial_account.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  List<FinancialTransaction> _transactions = [];
  List<FinancialAccount> _accounts = [];
  bool _isLoading = true;
  String? _selectedCategory;
  String? _selectedAccountId;

  static const _categories = ['All', 'FOOD', 'SHOPPING', 'TRANSPORT', 'BILLS', 'INCOME', 'RENT', 'OTHER'];

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
    final accounts = await FinancialService.getAccounts();
    final txns = await FinancialService.getTransactions(
      accountId: _selectedAccountId,
      category: _selectedCategory,
    );
    setState(() { _accounts = accounts; _transactions = txns; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
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
      body: Column(
        children: [
          // Account filter
          if (_accounts.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(label: 'All Accounts', isSelected: _selectedAccountId == null,
                      onTap: () { _selectedAccountId = null; _load(); }),
                    ..._accounts.map((a) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _FilterChip(label: a.bankName, isSelected: _selectedAccountId == a.id,
                        onTap: () { _selectedAccountId = a.id; _load(); }),
                    )),
                  ],
                ),
              ),
            ),

          // Category filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _categories.map((cat) {
                  final isAll = cat == 'All';
                  final isSelected = isAll ? _selectedCategory == null : _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: cat,
                      isSelected: isSelected,
                      color: isAll ? null : _catColors[cat],
                      onTap: () { _selectedCategory = isAll ? null : cat; _load(); },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Transaction count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${_transactions.length} transactions',
                style: TextStyle(fontSize: 12, color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary)),
            ),
          ),

          // Transaction list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _transactions.isEmpty
                    ? const Center(child: Text('No transactions found', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          final t = _transactions[index];
                          final color = _catColors[t.category] ?? const Color(0xFF6B7280);
                          final icon = _catIcons[t.category] ?? Icons.more_horiz_rounded;

                          return ListTile(
                            leading: Container(
                              width: 42, height: 42,
                              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                              child: Icon(icon, size: 20, color: color),
                            ),
                            title: Text(t.merchant ?? t.description,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            subtitle: Text('${t.category} • ${_formatDate(t.date)}${t.isRecurring ? ' • 🔄' : ''}',
                              style: TextStyle(fontSize: 12, color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary)),
                            trailing: Text(
                              '${t.isCredit ? '+' : '-'}₹${t.amount.toStringAsFixed(0)}',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: t.isCredit ? Colors.green : Colors.red),
                            ),
                          );
                        },
                      ),
          ),
        ],
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? const Color(0xFF059669);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? chipColor : Colors.grey.shade400, width: isSelected ? 1.5 : 0.5),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          color: isSelected ? chipColor : null)),
      ),
    );
  }
}
