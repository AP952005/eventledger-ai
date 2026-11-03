/// PayGo — TopBar Widget
/// App bar with avatar, logo, search, and notification bell.

import 'package:flutter/material.dart';
import '../config/colors.dart';

class PayGoTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String userInitials;
  final int notificationCount;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;

  const PayGoTopBar({
    super.key,
    required this.userName,
    required this.userInitials,
    this.notificationCount = 0,
    this.onAvatarTap,
    this.onSearchTap,
    this.onNotificationTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Avatar
            GestureDetector(
              onTap: onAvatarTap,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: PayGoColors.accentGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    userInitials,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Logo / Brand
            Expanded(
              child: Row(
                children: [
                  Text(
                    'Pay',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark ? PayGoColors.white : PayGoColors.deepNavy,
                    ),
                  ),
                  Text(
                    'Go',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: PayGoColors.oceanBlue,
                    ),
                  ),
                ],
              ),
            ),

            // Search
            _TopBarIcon(
              icon: Icons.search_rounded,
              onTap: onSearchTap,
              isDark: isDark,
            ),

            const SizedBox(width: 8),

            // Notifications
            Stack(
              clipBehavior: Clip.none,
              children: [
                _TopBarIcon(
                  icon: Icons.notifications_outlined,
                  onTap: onNotificationTap,
                  isDark: isDark,
                ),
                if (notificationCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: PayGoColors.error,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: isDark ? PayGoColors.darkBg : PayGoColors.lightBg,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          notificationCount > 9 ? '9+' : '$notificationCount',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;

  const _TopBarIcon({
    required this.icon,
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? PayGoColors.darkSurface : PayGoColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 22,
          color: isDark ? PayGoColors.darkTextPrimary : PayGoColors.lightTextPrimary,
        ),
      ),
    );
  }
}
