import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';
import '../../services/event_treasury_api_service.dart';
import '../../widgets/event_treasury_shell.dart';

class CreateEventTreasuryScreen extends StatefulWidget {
  const CreateEventTreasuryScreen({super.key});

  @override
  State<CreateEventTreasuryScreen> createState() => _CreateEventTreasuryScreenState();
}

class _CreateEventTreasuryScreenState extends State<CreateEventTreasuryScreen> {
  final _aiPromptController = TextEditingController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _amountController = TextEditingController(text: '25.00');
  final _targetController = TextEditingController(text: '2500.00');
  final _participantsController = TextEditingController(text: '100');
  final _daysController = TextEditingController(text: '14');

  String _currency = 'USD';
  String _category = 'Conference';
  bool _isAILoading = false;
  bool _isSubmitting = false;

  Future<void> _handleAIExtraction() async {
    final prompt = _aiPromptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() => _isAILoading = true);
    try {
      final res = await EventTreasuryApiService.aiParseEvent(prompt);
      final ev = res['extracted_event'] ?? {};
      setState(() {
        if (ev['title'] != null) _titleController.text = ev['title'];
        if (ev['description'] != null) _descController.text = ev['description'];
        if (ev['amount'] != null) _amountController.text = ev['amount'].toString();
        if (ev['target_amount'] != null) _targetController.text = ev['target_amount'].toString();
        if (ev['expected_participants'] != null) _participantsController.text = ev['expected_participants'].toString();
        if (ev['currency'] != null) _currency = ev['currency'];
        if (ev['category'] != null) _category = ev['category'];
        _isAILoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: EventTreasuryColors.success,
            content: Text('AI successfully parsed your event parameters! Review and create below.'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isAILoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI extraction failed: $e')),
      );
    }
  }

  Future<void> _handleCreateEvent() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event title is required.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final payload = {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'category': _category,
        'currency': _currency,
        'amount': double.tryParse(_amountController.text) ?? 0.0,
        'target_amount': double.tryParse(_targetController.text) ?? 0.0,
        'expected_participants': int.tryParse(_participantsController.text) ?? 50,
        'expiry_days': int.tryParse(_daysController.text) ?? 14,
      };
      final newEvent = await EventTreasuryApiService.createEvent(payload);
      setState(() => _isSubmitting = false);
      if (mounted) {
        context.go('/events/detail?id=${newEvent['id']}');
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create event: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return EventTreasuryShell(
      currentRoute: AppRoutes.createEvent,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Event Collection',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Generate a Level 1 Event Registration portal and automated PayPal Invoicing engine',
                  style: TextStyle(color: EventTreasuryColors.lightTextSecondary),
                ),
                const SizedBox(height: 24),
                _buildAIAssistedBox(),
                const SizedBox(height: 28),
                _buildManualForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIAssistedBox() {
    return Card(
      color: EventTreasuryColors.lightBlue,
      elevation: 0,
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
              children: const [
                Icon(Icons.auto_awesome, color: EventTreasuryColors.paypalBlue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Natural Language Event Creation (Gemini AI)',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _aiPromptController,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'e.g. "Create a university hackathon for 120 coders. Registration is \$25 per participant, target is \$3,000, and deadline is in 10 days."',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: EventTreasuryColors.borderBlue)),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.bolt, size: 18),
                label: _isAILoading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Extract with Gemini'),
                onPressed: _isAILoading ? null : _handleAIExtraction,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualForm() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Event Details & Financial Parameters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Event Title *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Registration Fee *', prefixText: '\$ ', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Collection Target', prefixText: '\$ ', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _participantsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Expected Participants', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _daysController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Days until Expiry', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleCreateEvent,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Event & Activate PayPal Portal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
