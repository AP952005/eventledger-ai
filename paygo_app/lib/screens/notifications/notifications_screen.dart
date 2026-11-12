/// PayGo — Notifications Screen
/// Notification list with type-based icons and read/unread states.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/colors.dart';
import '../../services/mock_data.dart';
import '../../models/notification.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifications = MockData.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
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
        actions: [
          TextButton(onPressed: () {}, child: const Text('Mark all read')),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_rounded, size: 64,
                    color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary),
                  const SizedBox(height: 16),
                  Text('No notifications', style: TextStyle(fontSize: 16,
                    color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary)),
                ],
              ),
            )
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => Divider(height: 1, indent: 72,
                color: isDark ? PayGoColors.darkDivider : PayGoColors.lightDivider),
              itemBuilder: (context, index) {
                final n = notifications[index];
                return _NotificationTile(notification: n, isDark: isDark);
              },
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final bool isDark;

  const _NotificationTile({required this.notification, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final iconData = _getIcon();
    final iconColor = _getColor();

    return Container(
      color: notification.read
          ? Colors.transparent
          : (isDark ? PayGoColors.oceanBlue.withValues(alpha: 0.06) : PayGoColors.oceanBlue.withValues(alpha: 0.03)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(iconData, size: 22, color: iconColor),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: notification.read ? FontWeight.w500 : FontWeight.w700,
            color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.lightTextPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.body, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12,
                color: isDark ? PayGoColors.darkTextSecondary : PayGoColors.lightTextSecondary)),
            const SizedBox(height: 4),
            Text(
              _formatTime(notification.createdAt),
              style: TextStyle(fontSize: 10,
                color: isDark ? PayGoColors.darkTextTertiary : PayGoColors.lightTextTertiary),
            ),
          ],
        ),
        trailing: notification.read
            ? null
            : Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: PayGoColors.oceanBlue),
              ),
      ),
    );
  }

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.txn: return Icons.swap_horiz_rounded;
      case NotificationType.offer: return Icons.local_offer_rounded;
      case NotificationType.system: return Icons.shield_rounded;
    }
  }

  Color _getColor() {
    switch (notification.type) {
      case NotificationType.txn: return PayGoColors.oceanBlue;
      case NotificationType.offer: return PayGoColors.gold;
      case NotificationType.system: return PayGoColors.error;
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM').format(dt);
  }
}
