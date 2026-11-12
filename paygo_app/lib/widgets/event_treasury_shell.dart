import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';
import 'floating_ai_assistant.dart';

class EventTreasuryShell extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const EventTreasuryShell({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          Column(
            children: [
              _buildPayPalNavbar(context),
              Expanded(
                child: child,
              ),
              _buildPayPalFooter(context),
            ],
          ),
          // Floating AI Assistant across all pages
          const FloatingAIAssistantWidget(),
        ],
      ),
    );
  }

  /// Official PayPal Deep Navy Navbar
  Widget _buildPayPalNavbar(BuildContext context) {
    return Container(
      height: 64,
      color: const Color(0xFF001C64), // Official PayPal Deep Navy Navbar
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // PayPal Official Style Monogram & Brand
          GestureDetector(
            onTap: () => context.go(AppRoutes.home),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0070E0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Text(
                      'P',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'PayGo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          // Navigation Tabs matching PayPal Desktop Experience
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _navPill(context, 'Home', AppRoutes.home),
                  _navPill(context, 'Events & Collect', AppRoutes.eventList),
                  _navPill(context, 'Create Event', AppRoutes.createEvent),
                  _navPill(context, 'Financial Hub', AppRoutes.financialHub),
                  _navPill(context, 'Activity & Reports', AppRoutes.spendingSummary),
                  _navPill(context, 'Notifications', AppRoutes.notifications),
                  _navPill(context, 'Settings', AppRoutes.settings),
                ],
              ),
            ),
          ),
          // User Info & Sandbox Indicator in the Top Right Corner
          _buildUserTopRight(context),
        ],
      ),
    );
  }

  Widget _navPill(BuildContext context, String title, String route) {
    final isSelected = currentRoute == route;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.go(route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF142C74) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFFD4E2F4),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTopRight(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Notification Icon with badge
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
          tooltip: 'Notifications',
          onPressed: () => context.go(AppRoutes.notifications),
        ),
        // Settings Gear Icon
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
          tooltip: 'Settings',
          onPressed: () => context.go(AppRoutes.settings),
        ),
        const SizedBox(width: 4),
        // Profile Info & Avatar matching screenshot
        GestureDetector(
          onTap: () => context.go(AppRoutes.settings),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF142C74),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2E4E9E)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xFF0070E0),
                  child: Text(
                    'AP',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Abishek Palani',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Personal • Verified',
                      style: TextStyle(color: Color(0xFF8BB5FA), fontSize: 9),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () => context.go(AppRoutes.home),
          child: const Text(
            'LOG OUT',
            style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildPayPalFooter(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          const Text(
            'PayGo AI — Powered by PayPal',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF001C64)),
          ),
          const SizedBox(width: 20),
          TextButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Home', style: TextStyle(fontSize: 12, color: Color(0xFF0070E0))),
          ),
          TextButton(
            onPressed: () => context.go(AppRoutes.eventList),
            child: const Text('Events', style: TextStyle(fontSize: 12, color: Color(0xFF0070E0))),
          ),
          TextButton(
            onPressed: () => context.go(AppRoutes.spendingSummary),
            child: const Text('Activity', style: TextStyle(fontSize: 12, color: Color(0xFF0070E0))),
          ),
          TextButton(
            onPressed: () => context.go(AppRoutes.settings),
            child: const Text('Help & Security', style: TextStyle(fontSize: 12, color: Color(0xFF0070E0))),
          ),
          const Spacer(),
          const Text(
            '©1999-2026 PayPal Inc. All rights reserved. • Sandbox Active',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
