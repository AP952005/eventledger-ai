import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/routes.dart';
import '../../services/event_treasury_api_service.dart';
import '../../widgets/event_treasury_shell.dart';

class EventTreasuryAIAssistantScreen extends StatefulWidget {
  const EventTreasuryAIAssistantScreen({super.key});

  @override
  State<EventTreasuryAIAssistantScreen> createState() => _EventTreasuryAIAssistantScreenState();
}

class _EventTreasuryAIAssistantScreenState extends State<EventTreasuryAIAssistantScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'assistant',
      'text': 'Hello! I am your EventTreasury AI Financial Operations Assistant. You can ask me about collection progress, unpaid participant invoices, or request financial audit reports for your events.'
    }
  ];
  bool _isLoading = false;

  Future<void> _sendMessage(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': query});
      _isLoading = true;
    });
    _messageController.clear();

    try {
      final reply = await EventTreasuryApiService.aiFinancialQuery(query);
      setState(() {
        _messages.add({'role': 'assistant', 'text': reply});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'text': 'Error querying telemetry: $e'});
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return EventTreasuryShell(
      currentRoute: AppRoutes.aiAssistant,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.smart_toy_outlined, color: EventTreasuryColors.paypalBlue, size: 28),
                SizedBox(width: 12),
                Text(
                  'AI Financial Operations Assistant',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Grounded querying against verified live event ledger, PayPal invoices, and participant records',
              style: TextStyle(color: EventTreasuryColors.lightTextSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _buildSamplePromptChips(),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _messages.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isUser = msg['role'] == 'user';

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 650),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isUser ? EventTreasuryColors.paypalBlue : EventTreasuryColors.lightBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg['text'] ?? '',
                          style: TextStyle(
                            color: isUser ? Colors.white : EventTreasuryColors.lightTextPrimary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask about collections, outstanding invoices, or participants...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onSubmitted: (val) => _sendMessage(val),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: _isLoading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send, size: 18),
                    label: const Text('Send'),
                    onPressed: _isLoading ? null : () => _sendMessage(_messageController.text),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSamplePromptChips() {
    final prompts = [
      'Who has not paid?',
      'How much total collected across all events?',
      'Which events have pending payments?',
      'Summarize collection progress vs target'
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: prompts.map((p) {
        return ActionChip(
          backgroundColor: Colors.white,
          side: const BorderSide(color: EventTreasuryColors.borderBlue),
          label: Text(p, style: const TextStyle(fontSize: 12, color: EventTreasuryColors.paypalNavy)),
          onPressed: () => _sendMessage(p),
        );
      }).toList(),
    );
  }
}
