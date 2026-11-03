import 'dart:convert';
import 'package:http/http.dart' as http;

class AIResponse {
  final String text;
  final String? actionType;
  final Map<String, dynamic>? data;

  AIResponse({required this.text, this.actionType, this.data});
}

class PayGoAIService {
  // We now route through our backend to securely inject the API Key
  static const String backendProxyUrl = 'http://localhost:8000/ai/chat';

  static Future<AIResponse> sendMessage(String prompt) async {
    // If no backend URL is configured, return error
    if (backendProxyUrl.isEmpty) {
      return AIResponse(text: 'Error: Backend proxy URL is not configured.');
    }

    try {
      final response = await http.post(
        Uri.parse(backendProxyUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'prompt': prompt, 'user_id': 'u-001'}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AIResponse(
          text: data['response'] ?? data['message'] ?? data['output'] ?? 'No response',
          actionType: data['action'] ?? data['action_type'],
          data: data['payload'] ?? data['data'],
        );
      } else {
        print('HTTP status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return _getMockResponse(prompt);
      }
    } catch (e) {
      print('Connection error: $e');
      // If we can't reach the backend (e.g., running on a real device where localhost doesn't resolve), fall back to local mocks!
      return _getMockResponse(prompt);
    }
  }

  // --- Fallback Mock Responses for UI Testing ---
  static Future<AIResponse> _getMockResponse(String prompt) async {
    final lowerPrompt = prompt.toLowerCase();
    
    // Simulate slight delay
    await Future.delayed(const Duration(milliseconds: 600));

    if (lowerPrompt.contains('55000') || lowerPrompt.contains('55,000') || lowerPrompt.contains('recharge')) {
      return AIResponse(
        text: "I've checked your safe-to-spend limit. A recharge of ₹55,000 exceeds your monthly budget guardrails.",
        actionType: "GUARDRAIL_BLOCKED",
        data: {
          "amount": 55000,
          "merchant": "Jio Prepaid",
          "limit": 40000,
          "status": "BLOCKED"
        }
      );
    } else if (lowerPrompt.contains('expense') || lowerPrompt.contains('weekly')) {
      return AIResponse(
        text: "Here is your weekly expense summary. I've also detected 2 recurring subscriptions.",
        actionType: "EXPENSE_CHART",
        data: {
          "total_spent": 12500,
          "recurring": ["Netflix", "Spotify"],
          "chart_data": [
            {"day": "Mon", "amount": 1200},
            {"day": "Tue", "amount": 500},
            {"day": "Wed", "amount": 3400},
            {"day": "Thu", "amount": 800},
            {"day": "Fri", "amount": 2100},
            {"day": "Sat", "amount": 4500},
            {"day": "Sun", "amount": 0},
          ]
        }
      );
    } else if (lowerPrompt.contains('invest')) {
      return AIResponse(
        text: "Based on your high savings rate this month (35%), I recommend these Paytm investment options to maximize your returns:",
        actionType: "INVESTMENT_CARDS",
        data: {
          "recommendations": [
            {"type": "Mutual Fund", "name": "Axis Bluechip", "risk": "Moderate", "return": "12.5% p.a"},
            {"type": "Fixed Deposit", "name": "Shriram Finance", "risk": "Low", "return": "8.5% p.a"},
          ]
        }
      );
    } else if (lowerPrompt.contains('balance') || lowerPrompt.contains('wallet')) {
      return AIResponse(
        text: "Your current Paytm Wallet balance is ₹4,500. You also have ₹1,20,000 in your linked HDFC Bank account."
      );
    } else if (lowerPrompt.contains('recent') || lowerPrompt.contains('last transaction')) {
      return AIResponse(
        text: "Your most recent transaction was a payment of ₹150 to Swiggy on Sept 11, 2026."
      );
    } else {
      return AIResponse(text: "I'm your PayGo AI assistant. You can ask me to analyze your expenses, suggest investments, or execute payments securely.");
    }
  }
}
