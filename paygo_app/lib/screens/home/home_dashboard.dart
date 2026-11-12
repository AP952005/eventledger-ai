import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';
import '../../services/event_treasury_api_service.dart';
import '../../widgets/event_treasury_shell.dart';

class EventTreasuryDashboard extends StatefulWidget {
  const EventTreasuryDashboard({super.key});

  @override
  State<EventTreasuryDashboard> createState() => _EventTreasuryDashboardState();
}

class _EventTreasuryDashboardState extends State<EventTreasuryDashboard> {
  bool _isLoading = true;
  Map<String, dynamic> _overview = {};

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    final data = await EventTreasuryApiService.getDashboardOverview();
    setState(() {
      _overview = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return EventTreasuryShell(
      currentRoute: AppRoutes.home,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column (Cards, Quick actions, Recent activity)
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPayAndGetPaidCards(),
                            const SizedBox(height: 24),
                            _buildRecentActivity(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      // Right Column (Send/Request Action buttons, Banks and cards)
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSendRequestActionRow(),
                            const SizedBox(height: 24),
                            _buildActionIconShortcuts(),
                            const SizedBox(height: 32),
                            _buildSendAgainSection(),
                            const SizedBox(height: 32),
                            _buildBanksAndCardsSection(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  /// Official PayPal Red Alert Banner from user's screenshot
  Widget _buildIdentityBanner() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFC7081B), // Official PayPal Red Warning
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "You're almost there",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                'PayPal Sandbox Merchant environment verified for EventTreasury collection.',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
        ],
      ),
    );
  }

  Widget _buildCardLinkNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: const [
          Icon(Icons.info_outline, color: Color(0xFF003087), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EventTreasury PayPal Invoicing Active',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF10213A)),
                ),
                Text(
                  'Keep your collection into secure PayPal sandbox rails when receiving event registrations.',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Blue Dual Action Cards ("Pay someone" & "Get paid")
  Widget _buildPayAndGetPaidCards() {
    final metrics = _overview['metrics'] ?? {};
    final collected = (metrics['amount_collected'] as num?)?.toDouble() ?? 0.0;
    final target = (metrics['total_collection_target'] as num?)?.toDouble() ?? 0.0;

    return Row(
      children: [
        // Pay someone / Create Event Card
        Expanded(
          child: Container(
            height: 250,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0040A8), // Deep Blue Card
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 36),
                const Spacer(),
                const Text(
                  'Manage events',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  'Target: \$$target USD across active hackathons and conferences.',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0040A8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => context.go(AppRoutes.createEvent),
                    child: const Text('Create Event', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Get paid / Collections Card
        Expanded(
          child: Container(
            height: 250,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1B4F), // Dark Navy Card from screenshot
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 36),
                const Spacer(),
                const Text(
                  'Get paid',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$$collected collected with official PayPal QR invoices.',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0B1B4F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => context.go(AppRoutes.eventList),
                    child: const Text('View Collections', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSetupAccountProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0070E0), width: 2),
            ),
            child: const Center(
              child: Text(
                '1/5',
                style: TextStyle(color: Color(0xFF0070E0), fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Set up your account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('To pay, get paid, and host collection events.', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = (_overview['recent_activity'] as List?) ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(
                onPressed: () => context.go(AppRoutes.spendingSummary),
                child: const Text('Show all', style: TextStyle(color: Color(0xFF0070E0), fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'See when funds come in and go out. You can find your verified PayPal activity here.',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
          const SizedBox(height: 16),
          if (activities.isEmpty)
            const Text('No transactions yet in this period.', style: TextStyle(fontSize: 12, color: Colors.grey))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.take(5).length,
              separatorBuilder: (c, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final act = activities[index];
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.payment_rounded, color: Color(0xFF0070E0), size: 22),
                  title: Text(act['action'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('${act['actor']} • ${act['timestamp']}', style: const TextStyle(fontSize: 11)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF3FC),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      act['status'] ?? 'SUCCESS',
                      style: const TextStyle(color: Color(0xFF003087), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  /// Official Pill Action Buttons ("Send" and "Request")
  Widget _buildSendRequestActionRow() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003087), // PayPal Dark Blue
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            onPressed: () => context.go(AppRoutes.eventList),
            child: const Text('Events & Portals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003087), // PayPal Dark Blue
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            onPressed: () => context.go(AppRoutes.createEvent),
            child: const Text('Create Event', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Widget _buildActionIconShortcuts() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _shortcutItem(Icons.qr_code_2_rounded, 'Public QR', () => context.go(AppRoutes.eventList)),
        _shortcutItem(Icons.auto_awesome, 'AI Reminders', () => context.go(AppRoutes.sendReminders)),
      ],
    );
  }

  Widget _shortcutItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFEBF3FC),
              child: Icon(icon, color: const Color(0xFF003087), size: 20),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSendAgainSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Quick Collections', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Icon(Icons.more_vert, size: 18, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => context.go(AppRoutes.eventList),
          borderRadius: BorderRadius.circular(30),
          child: Column(
            children: const [
              CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFF003087),
                child: Icon(Icons.search, color: Colors.white, size: 22),
              ),
              SizedBox(height: 4),
              Text('Search Events', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBanksAndCardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Banks and cards', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Icon(Icons.more_vert, size: 18, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.credit_card_rounded, color: Color(0xFF4B5563), size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Shop and send payments more securely. Link your debit or credit card now.',
                style: TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: () => context.push(AppRoutes.connectAccount),
          child: const Text(
            'Link a Card or Bank Account',
            style: TextStyle(color: Color(0xFF0070E0), fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
