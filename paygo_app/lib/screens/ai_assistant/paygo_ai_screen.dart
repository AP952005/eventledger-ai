import 'package:flutter/material.dart';
import '../../services/ai_service.dart';

class PayGoAIScreen extends StatefulWidget {
  const PayGoAIScreen({Key? key}) : super(key: key);

  @override
  State<PayGoAIScreen> createState() => _PayGoAIScreenState();
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String? actionType;
  final Map<String, dynamic>? data;

  ChatMessage({required this.text, required this.isUser, this.actionType, this.data});
}

class _PayGoAIScreenState extends State<PayGoAIScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    final response = await PayGoAIService.sendMessage(text);

    setState(() {
      _isLoading = false;
      _messages.add(ChatMessage(
        text: response.text,
        isUser: false,
        actionType: response.actionType,
        data: response.data,
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PayGo AI', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600)),
                Text('Powered by Phinite', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildQuickPrompts(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Analyzing...', style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue[600] : Colors.white,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(16),
            bottomLeft: !message.isUser ? const Radius.circular(4) : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
            if (message.actionType != null && message.data != null)
              _buildRichWidget(message.actionType!, message.data!),
          ],
        ),
      ),
    );
  }

  Widget _buildRichWidget(String actionType, Map<String, dynamic> data) {
    if (actionType == "GUARDRAIL_BLOCKED") {
      return _buildGuardrailCard(data);
    } else if (actionType == "EXPENSE_CHART") {
      return _buildExpenseChart(data);
    } else if (actionType == "INVESTMENT_CARDS") {
      return _buildInvestmentCards(data);
    }
    return const SizedBox.shrink();
  }

  Widget _buildGuardrailCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
        border: Border(top: BorderSide(color: Colors.red.shade100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text('BLOCKED: Budget Exceeded', style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Amount: ₹${data["amount"]}', style: const TextStyle(fontSize: 14)),
          Text('Safe Limit: ₹${data["limit"]}', style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildExpenseChart(Map<String, dynamic> data) {
    List<dynamic> chartData = data["chart_data"] ?? [];
    double maxAmount = chartData.fold(0.0, (m, e) => (e["amount"] as num) > m ? (e["amount"] as num).toDouble() : m);
    if (maxAmount == 0) maxAmount = 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Total: ₹${data["total_spent"]}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: chartData.map((e) {
              double height = 100 * ((e["amount"] as num) / maxAmount);
              return Column(
                children: [
                  Container(
                    width: 20,
                    height: height,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(e["day"], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentCards(Map<String, dynamic> data) {
    List<dynamic> recs = data["recommendations"] ?? [];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: recs.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r["type"], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(r["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Text(r["return"], style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildQuickPrompts() {
    final prompts = [
      "Analyze weekly expenses",
      "Recharge ₹55,000",
      "Suggest investments",
    ];

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: prompts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ActionChip(
            label: Text(prompts[index], style: const TextStyle(fontSize: 13, color: Colors.blue)),
            backgroundColor: Colors.blue[50],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.blue.shade100)),
            onPressed: () => _sendMessage(prompts[index]),
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 5,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Ask PayGo AI...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onSubmitted: _sendMessage,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: () => _sendMessage(_controller.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
