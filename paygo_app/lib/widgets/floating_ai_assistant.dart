import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../services/event_treasury_api_service.dart';

class FloatingAIAssistantWidget extends StatefulWidget {
  const FloatingAIAssistantWidget({super.key});

  @override
  State<FloatingAIAssistantWidget> createState() => _FloatingAIAssistantWidgetState();
}

class _FloatingAIAssistantWidgetState extends State<FloatingAIAssistantWidget> {
  bool _isOpen = false;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'assistant',
      'text': 'Hi! I am your PayGo AI Copilot. Ask me about collection totals, who has not paid, or generate reminders.'
    }
  ];
  bool _isLoading = false;

  Future<void> _sendMessage(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'text': query});
      _isLoading = true;
    });
    _controller.clear();

    try {
      final reply = await EventTreasuryApiService.aiFinancialQuery(query);
      setState(() {
        _messages.add({'role': 'assistant', 'text': reply});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'text': 'Unable to query AI telemetry: $e'});
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_isOpen)
              Container(
                width: 380,
                height: 500,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: EventTreasuryColors.borderBlue),
                ),
                child: Column(
                  children: [
                    // Header with PayPal styling
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: const BoxDecoration(
                        color: EventTreasuryColors.paypalNavy,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: EventTreasuryColors.paypalBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PayGo AI Copilot',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  'Grounded PayPal Financial Intelligence',
                                  style: TextStyle(color: EventTreasuryColors.paleBlue, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                            onPressed: () => setState(() => _isOpen = false),
                          ),
                        ],
                      ),
                    ),
                    // Messages
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: _messages.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isUser = msg['role'] == 'user';
                          return Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 300),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isUser ? EventTreasuryColors.paypalBlue : EventTreasuryColors.lightBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                msg['text'] ?? '',
                                style: TextStyle(
                                  color: isUser ? Colors.white : EventTreasuryColors.lightTextPrimary,
                                  fontSize: 12.5,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Quick Prompts
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _chipPrompt('Who has not paid?'),
                          _chipPrompt('Total collections vs target'),
                          _chipPrompt('Pending payments amount'),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Input Bar
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Ask your financial assistant...',
                                hintStyle: const TextStyle(fontSize: 12),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(color: EventTreasuryColors.borderBlue),
                                ),
                              ),
                              onSubmitted: (v) => _sendMessage(v),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: EventTreasuryColors.paypalBlue,
                            child: _isLoading
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : IconButton(
                                    icon: const Icon(Icons.arrow_upward_rounded, size: 16, color: Colors.white),
                                    onPressed: () => _sendMessage(_controller.text),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            // Floating Button
            GestureDetector(
              onTap: () => setState(() => _isOpen = !_isOpen),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [EventTreasuryColors.paypalNavy, EventTreasuryColors.paypalBlue],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: EventTreasuryColors.paypalNavy.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isOpen ? Icons.keyboard_arrow_down_rounded : Icons.smart_toy_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isOpen ? 'Close Copilot' : 'AI Assistant',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipPrompt(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(text, style: const TextStyle(fontSize: 11, color: EventTreasuryColors.paypalNavy)),
        backgroundColor: EventTreasuryColors.lightBlue,
        side: const BorderSide(color: EventTreasuryColors.borderBlue),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        onPressed: () => _sendMessage(text),
      ),
    );
  }
}

