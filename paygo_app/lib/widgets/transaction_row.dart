/// PayGo — TransactionRow Widget
/// Single transaction display row with direction indicator.

import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';

class TransactionRow extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionRow({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDebit = transaction.isDebit;
    final isFailed = transaction.status == TransactionStatus.failed;
    final isPending = transaction.status == TransactionStatus.pending;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Direction icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isFailed
                    ? PayGoColors.error.withValues(alpha: 0.1)
                    : isDebit
                        ? PayGoColors.error.withValues(alpha: 0.08)
                        : PayGoColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(),
                size: 20,
                color: isFailed
                    ? PayGoColors.error
                    : isDebit
                        ? PayGoColors.error
                        : PayGoColors.success,
              ),
            ),

            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.note ?? _getDefaultLabel(),
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        DateFormat('dd MMM, hh:mm a').format(transaction.timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary,
                          fontSize: 11,
                        ),
                      ),
                      if (isPending || isFailed) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: isFailed
                                ? PayGoColors.error.withValues(alpha: 0.1)
                                : PayGoColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isFailed ? 'Failed' : 'Pending',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: isFailed ? PayGoColors.error : PayGoColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              '${isDebit ? '-' : '+'}${transaction.formattedAmount}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isFailed
                    ? PayGoColors.error
                    : isDebit
                        ? (isDark ? PayGoColors.darkTextPrimary : PayGoColors.lightTextPrimary)
                        : PayGoColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (transaction.category) {
      case TransactionCategory.p2p:
        return transaction.isDebit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
      case TransactionCategory.recharge:
        return Icons.phone_android_rounded;
      case TransactionCategory.bill:
        return Icons.receipt_long_rounded;
      case TransactionCategory.shopping:
        return Icons.shopping_bag_rounded;
      case TransactionCategory.investment:
        return Icons.trending_up_rounded;
    }
  }

  String _getDefaultLabel() {
    switch (transaction.category) {
      case TransactionCategory.p2p:
        return transaction.isDebit ? 'Sent' : 'Received';
      case TransactionCategory.recharge:
        return 'Recharge';
      case TransactionCategory.bill:
        return 'Bill Payment';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.investment:
        return 'Investment';
    }
  }
}
