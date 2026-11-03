/// PayGo — Balance & History Screen
/// Bank balance card, transaction list grouped by date, and filter bar.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/colors.dart';
import '../../services/mock_data.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/transaction_row.dart';
import '../../widgets/chip_row.dart';

class BalanceHistoryScreen extends StatefulWidget {
  const BalanceHistoryScreen({super.key});

  @override
  State<BalanceHistoryScreen> createState() => _BalanceHistoryScreenState();
}

class _BalanceHistoryScreenState extends State<BalanceHistoryScreen> {
  int _selectedFilter = 0;
  final _filters = ['All', 'Sent', 'Received', 'Failed'];

  List get _filteredTransactions {
    final txns = MockData.transactions;
    switch (_selectedFilter) {
      case 1: return txns.where((t) => t.direction.name == 'sent').toList();
      case 2: return txns.where((t) => t.direction.name == 'received').toList();
      case 3: return txns.where((t) => t.status.name == 'failed').toList();
      default: return txns;
    }
  }

  Map<String, List> _groupByDate(List txns) {
    final Map<String, List> grouped = {};
    for (final t in txns) {
      final key = DateFormat('dd MMM yyyy').format(t.timestamp);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(t);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBank = user.primaryBank;
    final grouped = _groupByDate(_filteredTransactions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Balance & History'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            if (primaryBank != null)
              BalanceCard(
                bankName: primaryBank.bankName,
                accountLast4: primaryBank.accountLast4,
                balance: user.walletBalance,
                onRefresh: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Balance refreshed')),
                  );
                },
              ),

            // Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ChipRow(
                items: _filters,
                selectedIndex: _selectedFilter,
                onSelected: (i) => setState(() => _selectedFilter = i),
              ),
            ),

            // Grouped Transactions
            ...grouped.entries.map((entry) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary,
                    ),
                  ),
                ),
                ...entry.value.map((txn) => TransactionRow(transaction: txn)),
                Divider(indent: 16, endIndent: 16,
                  color: isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider),
              ],
            )),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
