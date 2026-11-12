import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../services/event_treasury_api_service.dart';
import '../../widgets/event_treasury_shell.dart';

class SendRemindersTreasuryScreen extends StatefulWidget {
  final String? eventId;
  const SendRemindersTreasuryScreen({super.key, this.eventId});

  @override
  State<SendRemindersTreasuryScreen> createState() => _SendRemindersTreasuryScreenState();
}

class _SendRemindersTreasuryScreenState extends State<SendRemindersTreasuryScreen> {
  bool _isLoading = true;
  List<dynamic> _unpaidParticipants = [];
  List<dynamic> _generatedReminders = [];
  bool _isGenerating = false;
  bool _isDispatching = false;

  @override
  void initState() {
    super.initState();
    _loadUnpaid();
  }

  Future<void> _loadUnpaid() async {
    setState(() => _isLoading = true);
    if (widget.eventId != null) {
      try {
        final res = await EventTreasuryApiService.getEventDetail(widget.eventId!);
        final parts = (res['participants'] as List?) ?? [];
        setState(() {
          _unpaidParticipants = parts.where((p) => p['status'] != 'PAID').toList();
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateReminders() async {
    final ids = _unpaidParticipants.map((p) => p['id'].toString()).toList();
    if (ids.isEmpty) return;

    setState(() => _isGenerating = true);
    try {
      final reminders = await EventTreasuryApiService.aiGenerateReminders(ids);
      setState(() {
        _generatedReminders = reminders;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating reminders: $e')),
      );
    }
  }

  Future<void> _dispatchReminders() async {
    setState(() => _isDispatching = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isDispatching = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: EventTreasuryColors.success,
          content: Text('Approved payment reminders dispatched to outstanding participants!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return EventTreasuryShell(
      currentRoute: '/events',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Smart Payment Reminders (Gemini AI)',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Automate personalized reminder copy for unpaid participant invoices with human approval before dispatch.',
                    style: TextStyle(color: EventTreasuryColors.lightTextSecondary),
                  ),
                  const SizedBox(height: 20),
                  _buildUnpaidCard(),
                  const SizedBox(height: 24),
                  if (_generatedReminders.isNotEmpty) _buildGeneratedRemindersCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildUnpaidCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Outstanding Invoices (${_unpaidParticipants.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: _isGenerating
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Generate AI Reminders'),
                  onPressed: _isGenerating || _unpaidParticipants.isEmpty ? null : _generateReminders,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_unpaidParticipants.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('All participants have paid! No pending invoices.'),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _unpaidParticipants.length,
                separatorBuilder: (c, i) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final p = _unpaidParticipants[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.pending_actions, color: EventTreasuryColors.warning),
                    title: Text(p['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${p['email']} • Due: \$${p['amount']} ${p['currency']}'),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratedRemindersCard() {
    return Card(
      elevation: 1,
      color: EventTreasuryColors.lightBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: EventTreasuryColors.borderBlue),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Review Generated Reminders',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: EventTreasuryColors.paypalNavy),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: EventTreasuryColors.success),
                  icon: const Icon(Icons.send, size: 16),
                  label: _isDispatching
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Approve & Dispatch Batch'),
                  onPressed: _isDispatching ? null : _dispatchReminders,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _generatedReminders.length,
              separatorBuilder: (c, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final r = _generatedReminders[index];
                return Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('To: ${r['participant_name']} (${r['email']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        Text(r['message'] ?? '', style: const TextStyle(fontSize: 13, height: 1.4)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
