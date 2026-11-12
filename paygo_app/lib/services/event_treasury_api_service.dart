import 'dart:convert';
import 'package:http/http.dart' as http;

class EventTreasuryApiService {
  // Configurable base URL: local backend or dev tunnel
  static String baseUrl = 'http://127.0.0.1:8000';

  static Future<Map<String, dynamic>> getDashboardOverview() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/dashboard/overview'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('getDashboardOverview error: $e');
    }
    return {
      "metrics": {
        "total_events": 3,
        "total_collection_target": 10700.0,
        "amount_collected": 105.0,
        "pending_payments_amount": 60.0,
        "pending_payments_count": 2,
        "successful_transactions": 3,
        "refunded_amount": 0.0,
        "currency": "USD"
      },
      "event_breakdowns": [],
      "recent_activity": []
    };
  }

  static Future<List<dynamic>> listEvents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/events'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('listEvents error: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>> createEvent(Map<String, dynamic> eventData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/events'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(eventData),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to create event: ${response.body}');
  }

  static Future<Map<String, dynamic>> getEventDetail(String eventId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/events/$eventId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load event detail: ${response.body}');
  }

  static Future<Map<String, dynamic>> closeEvent(String eventId) async {
    final response = await http.post(Uri.parse('$baseUrl/api/events/$eventId/close'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to close event: ${response.body}');
  }

  static Future<Map<String, dynamic>> registerParticipant(
    String eventId,
    String name,
    String email,
    String? phone,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/events/$eventId/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'email': email, 'phone': phone}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Registration error: ${response.body}');
  }

  static Future<Map<String, dynamic>> getParticipantCheckout(String participantId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/participants/$participantId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Checkout error: ${response.body}');
  }

  static Future<Map<String, dynamic>> verifySandboxPayment(String participantId) async {
    final response = await http.post(Uri.parse('$baseUrl/api/participants/$participantId/verify-sandbox-payment'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Payment verification failed: ${response.body}');
  }

  // ── AI Capabilities ──

  static Future<Map<String, dynamic>> aiParseEvent(String prompt) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ai/parse-event'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'prompt': prompt}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('AI parse error: ${response.body}');
  }

  static Future<String> aiFinancialQuery(String prompt) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ai/query'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'prompt': prompt}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['response'] ?? '';
    }
    return 'Financial operations assistant currently unavailable.';
  }

  static Future<List<dynamic>> aiGenerateReminders(List<String> participantIds, {String tone = 'friendly'}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ai/generate-reminder'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'participant_ids': participantIds, 'tone': tone}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['reminders'] ?? [];
    }
    return [];
  }

  static Future<Map<String, dynamic>> checkPaymentEligibility({
    required String currency,
    required double amount,
    String payerCountry = 'IN',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/payments/eligibility'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'currency': currency,
        'amount': amount,
        'payer_country': payerCountry,
      }),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return {
      'eligible_providers': [],
      'recommended_provider': 'CASHFREE',
      'reason': 'Default eligibility routing',
    };
  }

  static Future<Map<String, dynamic>> createPaymentOrder({
    required String participantId,
    String? preferredProvider,
    String payerCountry = 'IN',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/payments/orders/create'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'participant_id': participantId,
        'preferred_provider': preferredProvider,
        'payer_country': payerCountry,
      }),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to create payment order: ${response.body}');
  }

  static Future<Map<String, dynamic>> getPaymentOrderStatus(String orderId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/payments/orders/$orderId/status'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to retrieve order status: ${response.body}');
  }

  static Future<Map<String, dynamic>> verifySandboxPaymentOrder(String orderId) async {
    final response = await http.post(Uri.parse('$baseUrl/api/payments/orders/$orderId/verify-sandbox'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to verify sandbox payment: ${response.body}');
  }

  static Future<Map<String, dynamic>> getMultiCurrencyFinancialSummary() async {
    final response = await http.get(Uri.parse('$baseUrl/api/financial/summary'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return {'currencies': [], 'total_transactions': 0};
  }

  static Future<Map<String, dynamic>> aiGetEventReport(String eventId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/ai/events/$eventId/report'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Report error: ${response.body}');
  }
}

