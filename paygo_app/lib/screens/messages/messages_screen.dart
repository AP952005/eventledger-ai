/// PayGo — Messages Screen
/// Chat-style transaction history per contact.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';
import '../../services/mock_data.dart';
import '../../widgets/search_bar_widget.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final threads = MockData.messageThreads;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.toMobileContact),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New'),
          ),
        ],
      ),
      body: Column(
        children: [
          const PayGoSearchBar(placeholder: 'Search messages'),

          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: PayGoColors.oceanBlue.withValues(alpha: isDark ? 0.3 : 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: PayGoColors.oceanBlue),
                  ),
                  child: const Text('All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: PayGoColors.oceanBlue)),
                ),
              ],
            ),
          ),

          // Thread List
          Expanded(
            child: threads.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 64,
                          color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary),
                        const SizedBox(height: 16),
                        Text('No messages yet', style: TextStyle(fontSize: 16,
                          color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: threads.length,
                    separatorBuilder: (_, __) => Divider(height: 1, indent: 76,
                      color: isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider),
                    itemBuilder: (context, index) {
                      final t = threads[index];
                      final isSent = t['lastDirection'] == 'sent';
                      final date = DateTime.parse(t['lastDate']);

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: _avatarColor(index),
                          child: Text(
                            t['initials'] ?? '?',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                        title: Text(t['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: isSent
                                    ? PayGoColors.error.withValues(alpha: 0.1)
                                    : PayGoColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                isSent ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                                size: 12,
                                color: isSent ? PayGoColors.error : PayGoColors.success,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '₹${_formatAmount(t['lastAmount'])} ${isSent ? 'sent' : 'received'}',
                              style: TextStyle(fontSize: 13,
                                color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary),
                            ),
                          ],
                        ),
                        trailing: Text(
                          _formatDate(date),
                          style: TextStyle(fontSize: 11,
                            color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary),
                        ),
                        onTap: () => context.push(
                          '${AppRoutes.chatThread}?contactId=${t['contactId']}&name=${Uri.encodeComponent(t['name'])}',
                        ),
                      );
                    },
                  ),
          ),

          // Bottom action bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? PayGoColors.darkSurface : PayGoColors.lightSurface,
              border: Border(top: BorderSide(color: isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(icon: Icons.qr_code_scanner_rounded, label: 'Scan QR',
                  onTap: () => context.push(AppRoutes.scanQR)),
                _ActionButton(icon: Icons.group_rounded, label: 'Split Bill', onTap: () {}),
                _ActionButton(icon: Icons.card_giftcard_rounded, label: 'Refer & Win', onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return DateFormat('hh:mm a').format(date);
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return DateFormat('EEE').format(date);
    return DateFormat('dd MMM').format(date);
  }

  Color _avatarColor(int index) {
    const colors = [Color(0xFF6C63FF), PayGoColors.oceanBlue, Color(0xFF00BFA6), PayGoColors.deepNavy, Color(0xFFFF6B6B)];
    return colors[index % colors.length];
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: PayGoColors.oceanBlue),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: PayGoColors.oceanBlue)),
        ],
      ),
    );
  }
}
