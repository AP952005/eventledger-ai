/// PayGo — API Service Layer
/// Uses mock data locally, with optional backend connectivity.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'mock_data.dart';
import '../models/user.dart';
import '../models/transaction.dart';
import '../models/saved_biller.dart';
import '../models/notification.dart';
import '../models/contact.dart';
import '../models/event.dart';
import '../models/ledger_entry.dart';
import '../models/settlement_proof.dart';
import '../models/reminder_template.dart';

class ApiService {
  // Change this to your backend URL when running the Python server
  static const String _baseUrl = 'http://10.0.2.2:8000'; // Android emulator localhost
  static const bool _useMock = true; // Set to false to use real API

  // ──────────────────────────────────────────────
  // Auth
  // ──────────────────────────────────────────────

  static Future<String> requestOTP(String phone) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return 'otp-mock-session';
    }
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/otp/request'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );
    return jsonDecode(res.body)['otp_session_id'];
  }

  static Future<Map<String, dynamic>> verifyOTP(String sessionId, String code) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      if (code == '123456') {
        return {'auth_token': 'mock-token', 'is_new_user': false};
      }
      throw Exception('Invalid OTP');
    }
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/otp/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'otp_session_id': sessionId, 'code': code}),
    );
    if (res.statusCode != 200) throw Exception('Invalid OTP');
    return jsonDecode(res.body);
  }

  // ──────────────────────────────────────────────
  // User
  // ──────────────────────────────────────────────

  static Future<User> getUserProfile() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockData.currentUser;
    }
    final res = await http.get(Uri.parse('$_baseUrl/user/profile'));
    return User.fromJson(jsonDecode(res.body));
  }

  // ──────────────────────────────────────────────
  // Transactions
  // ──────────────────────────────────────────────

  static Future<List<Transaction>> getTransactions({String? filter}) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (filter != null && filter != 'all') {
        return MockData.transactions.where((t) =>
          t.direction.name == filter || t.status.name == filter
        ).toList();
      }
      return MockData.transactions;
    }
    final uri = Uri.parse('$_baseUrl/transactions').replace(
      queryParameters: filter != null ? {'filter': filter} : null,
    );
    final res = await http.get(uri);
    final data = jsonDecode(res.body);
    return (data['items'] as List).map((j) => Transaction.fromJson(j)).toList();
  }

  static Future<List<Transaction>> getTransactionsByContact(String contactId) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockData.transactions.where((t) =>
        t.fromUserId == contactId || t.toUserId == contactId
      ).toList();
    }
    final res = await http.get(
      Uri.parse('$_baseUrl/transactions/by-contact?contact_id=$contactId'),
    );
    return (jsonDecode(res.body) as List).map((j) => Transaction.fromJson(j)).toList();
  }

  // ──────────────────────────────────────────────
  // Billers
  // ──────────────────────────────────────────────

  static Future<List<SavedBiller>> getSavedBillers() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockData.savedBillers;
    }
    final res = await http.get(Uri.parse('$_baseUrl/billers/saved'));
    return (jsonDecode(res.body) as List).map((j) => SavedBiller.fromJson(j)).toList();
  }

  static Future<List<BillerCategory>> getBillerCategories() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      return MockData.billerCategories;
    }
    final res = await http.get(Uri.parse('$_baseUrl/billers/categories'));
    return (jsonDecode(res.body) as List).map((j) => BillerCategory.fromJson(j)).toList();
  }

  // ──────────────────────────────────────────────
  // Contacts
  // ──────────────────────────────────────────────

  static Future<List<Contact>> getRecentContacts() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      return MockData.recentContacts;
    }
    final res = await http.get(Uri.parse('$_baseUrl/contacts/recent'));
    return (jsonDecode(res.body) as List).map((j) => Contact.fromJson(j)).toList();
  }

  static Future<List<Contact>> searchContacts(String query) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      final q = query.toLowerCase();
      return MockData.contacts.where((c) =>
        c.name.toLowerCase().contains(q) || c.phone.contains(q)
      ).toList();
    }
    final res = await http.get(Uri.parse('$_baseUrl/contacts/search?query=$query'));
    return (jsonDecode(res.body) as List).map((j) => Contact.fromJson(j)).toList();
  }

  // ──────────────────────────────────────────────
  // Notifications
  // ──────────────────────────────────────────────

  static Future<List<AppNotification>> getNotifications() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockData.notifications;
    }
    final res = await http.get(Uri.parse('$_baseUrl/notifications'));
    return (jsonDecode(res.body) as List).map((j) => AppNotification.fromJson(j)).toList();
  }

  // ──────────────────────────────────────────────
  // Payments
  // ──────────────────────────────────────────────

  static Future<Map<String, dynamic>> initiatePayment({
    String? payeeUpiId,
    String? billerId,
    required double amount,
    required String category,
    String? note,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return {'txn_id': 'txn-mock-${DateTime.now().millisecondsSinceEpoch}', 'status': 'pending'};
    }
    final res = await http.post(
      Uri.parse('$_baseUrl/payments/initiate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'payee_upi_id': payeeUpiId,
        'biller_id': billerId,
        'amount': amount,
        'category': category,
        'note': note,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> confirmPayment(String txnId, String pin) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 2));
      if (pin == '1234') {
        return {'txn_id': txnId, 'status': 'success'};
      }
      return {'txn_id': txnId, 'status': 'failed', 'reason': 'Incorrect UPI PIN'};
    }
    final res = await http.post(
      Uri.parse('$_baseUrl/payments/confirm-pin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'txn_id': txnId, 'pin': pin}),
    );
    return jsonDecode(res.body);
  }

  // ──────────────────────────────────────────────
  // QR
  // ──────────────────────────────────────────────

  static Future<String> getMyQRDeepLink() async {
    if (_useMock) {
      final user = MockData.currentUser;
      return 'upi://pay?pa=${user.upiId}&pn=${user.name}&cu=INR';
    }
    final res = await http.get(Uri.parse('$_baseUrl/qr/my-code'));
    return jsonDecode(res.body)['upi_deep_link'];
  }

  // ══════════════════════════════════════════════
  // EVENT COLLECT
  // ══════════════════════════════════════════════
  //
  // OUT OF SCOPE (by design):
  // - No NLP/LLM anywhere in this feature
  // - No fuzzy matching for unmatched payments
  // - No auto-generated reminders
  // - No custodial wallet
  // - No auto-close before expiry
  // - No post-close ledger edits

  static Future<bool> checkAliasAvailability(String handle) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return !MockData.takenAliases.contains(handle.toLowerCase());
    }
    final res = await http.get(Uri.parse('$_baseUrl/upi/alias/check?handle=$handle'));
    return jsonDecode(res.body)['available'] as bool;
  }

  static Future<Map<String, dynamic>> registerAlias(String handle) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      MockData.takenAliases.add(handle.toLowerCase());
      final vpa = '${handle.toLowerCase()}@paygo';
      MockData.currentUser = MockData.currentUser.copyWith(eventVpa: vpa);
      return {'vpa': vpa, 'linked_account_id': 'b-001'};
    }
    final res = await http.post(
      Uri.parse('$_baseUrl/upi/alias/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'handle': handle}),
    );
    return jsonDecode(res.body);
  }

  static Future<List<CollectEvent>> getMyEvents() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockData.events;
    }
    final res = await http.get(Uri.parse('$_baseUrl/events'));
    return (jsonDecode(res.body) as List).map((j) => CollectEvent.fromJson(j)).toList();
  }

  static Future<CollectEvent> createEvent({
    required String title,
    required EventAmountMode amountMode,
    double? amount,
    double? targetAmount,
    bool sameAmountFromEveryone = false,
    required DateTime expiryAt,
    String? settlementAccountId,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      final user = MockData.currentUser;
      final event = CollectEvent(
        id: 'evt-mock-${DateTime.now().millisecondsSinceEpoch}',
        organizerId: user.id,
        title: title,
        amountMode: amountMode,
        amount: amount,
        targetAmount: targetAmount,
        sameAmountFromEveryone: sameAmountFromEveryone,
        expiryAt: expiryAt,
        status: EventStatus.active,
        settlementVpa: user.upiId,
        settlementName: user.registeredName,
        settlementAccountId: settlementAccountId ?? user.primaryBank!.id,
        createdAt: DateTime.now(),
      );
      MockData.events.add(event);
      return event;
    }
    final res = await http.post(
      Uri.parse('$_baseUrl/events'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'amount_mode': amountMode.name.toUpperCase(),
        'amount': amount,
        'target_amount': targetAmount,
        'same_amount_from_everyone': sameAmountFromEveryone,
        'expiry_at': expiryAt.toIso8601String(),
        'settlement_account_id': settlementAccountId,
      }),
    );
    return CollectEvent.fromJson(jsonDecode(res.body));
  }

  static Future<Map<String, dynamic>> getEventDetail(String eventId) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      final event = MockData.events.firstWhere((e) => e.id == eventId);
      final ledger = MockData.ledgerForEvent(eventId);
      return {'event': event, 'ledger': ledger};
    }
    final res = await http.get(Uri.parse('$_baseUrl/events/$eventId'));
    final data = jsonDecode(res.body);
    return {
      'event': CollectEvent.fromJson(data['event']),
      'ledger': (data['ledger'] as List).map((j) => LedgerEntry.fromJson(j)).toList(),
    };
  }

  static Future<bool> closeEvent(String eventId) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      final idx = MockData.events.indexWhere((e) => e.id == eventId);
      if (idx >= 0) {
        // Replace with closed version
        final old = MockData.events[idx];
        MockData.events[idx] = CollectEvent(
          id: old.id, organizerId: old.organizerId, title: old.title,
          amountMode: old.amountMode, amount: old.amount, targetAmount: old.targetAmount,
          sameAmountFromEveryone: old.sameAmountFromEveryone,
          expiryAt: old.expiryAt, status: EventStatus.closed,
          settlementVpa: old.settlementVpa, settlementName: old.settlementName,
          settlementAccountId: old.settlementAccountId, createdAt: old.createdAt,
          closedAt: DateTime.now(),
        );
      }
      return true;
    }
    await http.post(Uri.parse('$_baseUrl/events/$eventId/close'));
    return true;
  }

  static Future<bool> tagLedgerEntry(String eventId, String entryId, String participantId, String participantName) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      final idx = MockData.ledgerEntries.indexWhere((e) => e.id == entryId);
      if (idx >= 0) {
        MockData.ledgerEntries[idx] = MockData.ledgerEntries[idx].copyWithTag(
          participantId: participantId,
          participantName: participantName,
          taggedBy: 'u-001',
        );
      }
      return true;
    }
    await http.post(
      Uri.parse('$_baseUrl/events/$eventId/ledger/$entryId/tag'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'participant_id': participantId, 'participant_name': participantName}),
    );
    return true;
  }

  static Future<bool> sendReminders(String eventId, String templateId, List<String> participantIds) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }
    await http.post(
      Uri.parse('$_baseUrl/events/$eventId/reminders/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'template_id': templateId, 'participant_ids': participantIds}),
    );
    return true;
  }

  static Future<List<ReminderTemplate>> getReminderTemplates() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      return ReminderTemplate.templates;
    }
    final res = await http.get(Uri.parse('$_baseUrl/reminders/templates'));
    return (jsonDecode(res.body) as List).map((j) => ReminderTemplate.fromJson(j)).toList();
  }

  static Future<SettlementProof?> getSettlementProof(String eventId) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      try {
        return MockData.settlementProofs.firstWhere((p) => p.eventId == eventId);
      } catch (_) {
        return null;
      }
    }
    final res = await http.get(Uri.parse('$_baseUrl/verify/$eventId'));
    final data = jsonDecode(res.body);
    if (data['proof'] != null) return SettlementProof.fromJson(data['proof']);
    return null;
  }

  static Future<Map<String, dynamic>> verifyEvent(String eventId) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      final event = MockData.events.firstWhere((e) => e.id == eventId);
      final ledger = MockData.ledgerForEvent(eventId);
      final proof = MockData.settlementProofs.where((p) => p.eventId == eventId).firstOrNull;
      return {'event': event, 'ledger': ledger, 'proof': proof};
    }
    final res = await http.get(Uri.parse('$_baseUrl/verify/$eventId'));
    return jsonDecode(res.body);
  }
}
