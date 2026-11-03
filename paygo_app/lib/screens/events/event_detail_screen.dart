import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../models/event.dart';
import '../../models/ledger_entry.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isLoading = true;
  CollectEvent? _event;
  List<LedgerEntry> _ledger = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getEventDetail(widget.eventId);
      setState(() {
        _event = data['event'] as CollectEvent;
        _ledger = data['ledger'] as List<LedgerEntry>;
        _ledger.sort((a, b) => b.matchedAt.compareTo(a.matchedAt));
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _closeEvent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Close Event?'),
        content: const Text('Closing the event will permanently disable its QR code and lock the ledger. A cryptographically signed Settlement Proof will be generated. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => context.pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Close Event'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await ApiService.closeEvent(widget.eventId);
      await _loadData();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_event == null) {
      return const Scaffold(body: Center(child: Text('Event not found')));
    }

    final isActive = _event!.status == EventStatus.active;
    final totalCollected = _ledger.fold(0.0, (sum, e) => sum + e.amount);
    final unmatchedCount = _ledger.where((e) => e.isUnmatched).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(_event!.title),
        actions: [
          if (isActive)
            IconButton(
              icon: const Icon(Icons.lock_outline),
              tooltip: 'Close Event',
              onPressed: _closeEvent,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status and Summary Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green.shade100 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isActive ? 'ACTIVE' : 'CLOSED',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.green.shade700 : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Total Collected', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      '₹${totalCollected.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    if (_event!.targetAmount != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'of ₹${_event!.targetAmount!.toStringAsFixed(0)} target',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // QR Code (if active)
            if (isActive)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.blue.shade200),
                ),
                color: Colors.blue.withValues(alpha: 0.05),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text('Scan to Pay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: QrImageView(
                          data: _event!.upiDeepLink,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Payee: ${_event!.settlementName}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text('VPA: ${_event!.settlementVpa}', style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'monospace')),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            label: const Text('Copy Link'),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _event!.upiDeepLink));
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('UPI deep link copied!')));
                            },
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.share_rounded, size: 18),
                            label: const Text('Share'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PayGoColors.oceanBlue,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Share.share(
                                '💰 Pay for "${_event!.title}"\n\n'
                                'Payee: ${_event!.settlementName}\n'
                                'VPA: ${_event!.settlementVpa}\n\n'
                                'UPI Link: ${_event!.upiDeepLink}',
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Actions Grid
            if (isActive)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.notifications_active,
                        title: 'Send\nReminders',
                        onTap: () => context.push('${AppRoutes.sendReminders}?eventId=${_event!.id}'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.assignment_late,
                        title: 'Unmatched\nPayments',
                        badge: unmatchedCount > 0 ? unmatchedCount.toString() : null,
                        onTap: () => context.push('${AppRoutes.unmatchedPayments}?eventId=${_event!.id}').then((_) => _loadData()),
                      ),
                    ),
                  ],
                ),
              ),

            if (!isActive)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.verified),
                    label: const Text('View Settlement Proof'),
                    onPressed: () => context.push('${AppRoutes.settlementProof}?eventId=${_event!.id}'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green.shade50,
                      foregroundColor: Colors.green.shade700,
                      elevation: 0,
                    ),
                  ),
                ),
              ),

            // Ledger
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Ledger', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            if (_ledger.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: Text('No payments received yet', style: TextStyle(color: Colors.grey))),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _ledger.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final entry = _ledger[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: entry.isUnmatched ? Colors.orange.shade100 : Colors.blue.shade100,
                      child: Icon(
                        entry.isUnmatched ? Icons.help_outline : Icons.person,
                        color: entry.isUnmatched ? Colors.orange : Colors.blue,
                      ),
                    ),
                    title: Text(
                      entry.isUnmatched ? 'Unmatched Payment' : entry.participantName!,
                      style: TextStyle(
                        fontWeight: entry.isUnmatched ? FontWeight.bold : FontWeight.normal,
                        color: entry.isUnmatched ? Colors.orange.shade700 : null,
                      ),
                    ),
                    subtitle: Text(
                      '${entry.payerVpaOrPhone}\n${DateFormat('MMM d, h:mm a').format(entry.matchedAt)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Text(
                      '+₹${entry.amount.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                    ),
                    isThreeLine: true,
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? badge;

  const _ActionCard({required this.icon, required this.title, required this.onTap, this.badge});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 32, color: PayGoColors.oceanBlue),
                if (badge != null)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
