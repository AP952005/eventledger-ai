/// PayGo — Chat Thread Screen
/// Transaction timeline as chat bubbles with quick pay bar.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';
import '../../services/mock_data.dart';
import '../../models/transaction.dart';

class ChatThreadScreen extends StatelessWidget {
  final String contactId;
  final String contactName;

  const ChatThreadScreen({
    super.key,
    required this.contactId,
    required this.contactName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactions = MockData.transactions.where((t) =>
      t.fromUserId == contactId || t.toUserId == contactId
    ).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: PayGoColors.oceanBlue,
              child: Text(contactName.isNotEmpty ? contactName[0] : '?',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            const SizedBox(width: 10),
            Text(contactName),
          ],
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          Expanded(
            child: transactions.isEmpty
                ? Center(child: Text('No transactions yet',
                    style: TextStyle(color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final txn = transactions[index];
                      return _TxnBubble(transaction: txn, isDark: isDark);
                    },
                  ),
          ),

          // Quick Pay Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? PayGoColors.darkSurface : PayGoColors.lightSurface,
              border: Border(top: BorderSide(color: isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final contact = MockData.contacts.firstWhere((c) => c.id == contactId,
                          orElse: () => MockData.contacts.first);
                        context.push('${AppRoutes.confirmPayment}?name=${Uri.encodeComponent(contactName)}&upiId=${contact.upiId}');
                      },
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text('Pay'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PayGoColors.oceanBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: PayGoColors.oceanBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.request_page_rounded, color: PayGoColors.oceanBlue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TxnBubble extends StatelessWidget {
  final Transaction transaction;
  final bool isDark;

  const _TxnBubble({required this.transaction, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isSent = transaction.isDebit;
    final isFailed = transaction.status == TransactionStatus.failed;

    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isFailed
              ? PayGoColors.error.withValues(alpha: 0.1)
              : isSent
                  ? (isDark ? PayGoColors.oceanBlue.withValues(alpha: 0.2) : PayGoColors.oceanBlue.withValues(alpha: 0.08))
                  : (isDark ? PayGoColors.darkCard : PayGoColors.lightSurface),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isSent ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isSent ? const Radius.circular(4) : const Radius.circular(16),
          ),
          border: Border.all(
            color: isFailed ? PayGoColors.error.withValues(alpha: 0.3) : Colors.transparent,
            width: isFailed ? 1 : 0,
          ),
        ),
        child: Column(
          crossAxisAlignment: isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSent ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  size: 16,
                  color: isFailed ? PayGoColors.error : isSent ? PayGoColors.oceanBlue : PayGoColors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  transaction.formattedAmount,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isFailed ? PayGoColors.error
                        : isDark ? PayGoColors.darkTextPrimary : PayGoColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            if (transaction.note != null) ...[
              const SizedBox(height: 4),
              Text(transaction.note!,
                style: TextStyle(fontSize: 13, color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary)),
            ],
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('dd MMM, hh:mm a').format(transaction.timestamp),
                  style: TextStyle(fontSize: 10, color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary),
                ),
                if (isFailed) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(color: PayGoColors.error.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                    child: const Text('Failed', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: PayGoColors.error)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
