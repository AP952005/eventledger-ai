/// PayGo — Financial Service
/// Mock-first HTTP client for all /api/financial/* endpoints.

import 'dart:math';
import '../models/financial_account.dart';
import '../models/consent.dart';
import '../models/financial_transaction.dart';

class FinancialService {
  static const bool _useMock = true;

  // ── In-memory mock stores ──
  static final List<FinancialAccount> _mockAccounts = [];
  static final List<FinancialTransaction> _mockTransactions = [];
  static final List<Consent> _mockConsents = [];
  static String? _lastConsentId;
  static int _consentCounter = 0;

  // ── Mock bank definitions ──
  static const List<Map<String, dynamic>> availableBanks = [
    {'name': 'APS Bank', 'fipId': 'APSBANK', 'balance': 124500.0, 'last4': '4402'},
    {'name': 'State Bank of India', 'fipId': 'SBIN', 'balance': 87230.50, 'last4': '6721'},
    {'name': 'HDFC Bank', 'fipId': 'HDFC', 'balance': 45600.75, 'last4': '3318'},
    {'name': 'ICICI Bank', 'fipId': 'ICICI', 'balance': 33200.0, 'last4': '9045'},
    {'name': 'Axis Bank', 'fipId': 'AXIS', 'balance': 28750.25, 'last4': '7712'},
    {'name': 'Kotak Mahindra Bank', 'fipId': 'KOTAK', 'balance': 56100.0, 'last4': '2209'},
  ];

  // ── Consent Flow ──

  static Future<Map<String, dynamic>> createConsent({
    required String purpose,
    required String fromDate,
    required String toDate,
    String frequency = 'ONE_TIME',
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      _consentCounter++;
      final consentId = 'CONSENT-MOCK${_consentCounter.toString().padLeft(4, '0')}';
      _lastConsentId = consentId;
      final consent = Consent(
        consentId: consentId,
        status: 'PENDING',
        purpose: purpose,
        fromDate: fromDate,
        toDate: toDate,
        frequency: frequency,
        createdAt: DateTime.now().toIso8601String(),
        dataTypes: ['Account information', 'Transactions', 'Transaction dates', 'Transaction amounts'],
      );
      _mockConsents.add(consent);
      return {'consent_id': consentId, 'redirect_url': '/mock-aa/approve/$consentId', 'status': 'PENDING'};
    }
    throw UnimplementedError('Real API not implemented');
  }

  static Future<Map<String, dynamic>> approveConsent({
    required String consentId,
    required String bankName,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      // Update consent status
      final idx = _mockConsents.indexWhere((c) => c.consentId == consentId);
      if (idx >= 0) {
        _mockConsents[idx] = Consent(
          consentId: consentId,
          status: 'APPROVED',
          purpose: _mockConsents[idx].purpose,
          fromDate: _mockConsents[idx].fromDate,
          toDate: _mockConsents[idx].toDate,
          frequency: _mockConsents[idx].frequency,
          createdAt: _mockConsents[idx].createdAt,
          dataTypes: _mockConsents[idx].dataTypes,
          bankName: bankName,
        );
      }
      return {'status': 'APPROVED'};
    }
    throw UnimplementedError('Real API not implemented');
  }

  static Future<String> getConsentStatus(String consentId) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      final consent = _mockConsents.where((c) => c.consentId == consentId).firstOrNull;
      return consent?.status ?? 'EXPIRED';
    }
    throw UnimplementedError('Real API not implemented');
  }

  static Future<List<Consent>> listConsents() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return List.from(_mockConsents);
    }
    throw UnimplementedError('Real API not implemented');
  }

  static Future<void> revokeConsent(String consentId) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      final idx = _mockConsents.indexWhere((c) => c.consentId == consentId);
      if (idx >= 0) {
        _mockConsents[idx] = Consent(
          consentId: consentId,
          status: 'REVOKED',
          purpose: _mockConsents[idx].purpose,
          fromDate: _mockConsents[idx].fromDate,
          toDate: _mockConsents[idx].toDate,
          frequency: _mockConsents[idx].frequency,
          createdAt: _mockConsents[idx].createdAt,
          dataTypes: _mockConsents[idx].dataTypes,
          bankName: _mockConsents[idx].bankName,
        );
      }
    }
  }

  // ── Account Sync ──

  static Future<Map<String, dynamic>> syncAccounts(String consentId) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 2));
      final consent = _mockConsents.where((c) => c.consentId == consentId).firstOrNull;
      if (consent == null || consent.status != 'APPROVED') {
        throw Exception('Consent not approved');
      }

      final bankName = consent.bankName ?? 'APS Bank';
      final bankInfo = availableBanks.firstWhere(
        (b) => b['name'] == bankName,
        orElse: () => availableBanks.first,
      );

      // Create account
      final accountId = 'fa-${DateTime.now().millisecondsSinceEpoch}';
      final account = FinancialAccount(
        id: accountId,
        fipId: bankInfo['fipId'],
        accountType: 'SAVINGS',
        maskedAccountNumber: 'XXXXXX${bankInfo['last4']}',
        bankName: bankName,
        balance: (bankInfo['balance'] as num).toDouble(),
        holderName: 'Abishek',
        linkedAt: DateTime.now().toIso8601String(),
        lastSynced: DateTime.now().toIso8601String(),
      );
      _mockAccounts.add(account);

      // Generate transactions
      final txns = _generateMockTransactions(accountId);
      _mockTransactions.addAll(txns);

      return {
        'accounts_linked': 1,
        'transactions_synced': txns.length,
      };
    }
    throw UnimplementedError('Real API not implemented');
  }

  // ── Accounts ──

  static Future<List<FinancialAccount>> getAccounts() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockAccounts.where((a) => a.status == 'ACTIVE').toList();
    }
    throw UnimplementedError('Real API not implemented');
  }

  static Future<void> unlinkAccount(String accountId) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      _mockAccounts.removeWhere((a) => a.id == accountId);
      _mockTransactions.removeWhere((t) => t.accountId == accountId);
    }
  }

  // ── Transactions ──

  static Future<List<FinancialTransaction>> getTransactions({
    String? accountId,
    String? category,
    String? fromDate,
    String? toDate,
    String? type,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      var results = List<FinancialTransaction>.from(_mockTransactions);

      if (accountId != null) {
        results = results.where((t) => t.accountId == accountId).toList();
      }
      if (category != null) {
        results = results.where((t) => t.category == category).toList();
      }
      if (type != null) {
        results = results.where((t) => t.type == type).toList();
      }

      results.sort((a, b) => b.date.compareTo(a.date));
      return results;
    }
    throw UnimplementedError('Real API not implemented');
  }

  // ── Analytics ──

  static Future<Map<String, dynamic>> getSummary({String period = 'this_month'}) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      final now = DateTime.now();
      DateTime start;
      if (period == 'last_month') {
        start = DateTime(now.year, now.month - 1, 1);
      } else if (period == '3_months') {
        start = now.subtract(const Duration(days: 90));
      } else if (period == '6_months') {
        start = now.subtract(const Duration(days: 180));
      } else {
        start = DateTime(now.year, now.month, 1);
      }

      final txns = _mockTransactions.where((t) {
        final d = DateTime.tryParse(t.date);
        return d != null && d.isAfter(start);
      }).toList();

      final income = txns.where((t) => t.isCredit).fold(0.0, (s, t) => s + t.amount);
      final expenses = txns.where((t) => t.isDebit).fold(0.0, (s, t) => s + t.amount);

      final catBreakdown = <String, double>{};
      for (final t in txns.where((t) => t.isDebit)) {
        catBreakdown[t.category] = (catBreakdown[t.category] ?? 0) + t.amount;
      }

      String? topCategory;
      if (catBreakdown.isNotEmpty) {
        topCategory = catBreakdown.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      }

      final days = now.difference(start).inDays.clamp(1, 365);
      final debitTxns = txns.where((t) => t.isDebit).toList();
      FinancialTransaction? highest;
      if (debitTxns.isNotEmpty) {
        highest = debitTxns.reduce((a, b) => a.amount > b.amount ? a : b);
      }

      final merchantCounts = <String, int>{};
      for (final t in debitTxns) {
        merchantCounts[t.merchant ?? 'Unknown'] = (merchantCounts[t.merchant ?? 'Unknown'] ?? 0) + 1;
      }
      String? mostFrequent;
      if (merchantCounts.isNotEmpty) {
        mostFrequent = merchantCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      }

      return {
        'period': period,
        'income': income,
        'expenses': expenses,
        'savings': income - expenses,
        'savings_rate': income > 0 ? ((income - expenses) / income * 100) : 0.0,
        'top_category': topCategory,
        'transaction_count': txns.length,
        'avg_daily_spend': expenses / days,
        'highest_expense': highest != null
            ? {'amount': highest.amount, 'merchant': highest.merchant, 'date': highest.date}
            : null,
        'most_frequent_merchant': mostFrequent,
        'category_breakdown': catBreakdown,
      };
    }
    throw UnimplementedError('Real API not implemented');
  }

  static Future<List<Map<String, dynamic>>> getTrends() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      final now = DateTime.now();
      final months = <Map<String, dynamic>>[];

      for (int i = 5; i >= 0; i--) {
        final monthStart = DateTime(now.year, now.month - i, 1);
        final monthEnd = DateTime(now.year, now.month - i + 1, 0);
        final label = '${_monthName(monthStart.month)} ${monthStart.year}';

        final txns = _mockTransactions.where((t) {
          final d = DateTime.tryParse(t.date);
          return d != null && d.isAfter(monthStart.subtract(const Duration(days: 1))) && d.isBefore(monthEnd.add(const Duration(days: 1)));
        }).toList();

        final income = txns.where((t) => t.isCredit).fold(0.0, (s, t) => s + t.amount);
        final expenses = txns.where((t) => t.isDebit).fold(0.0, (s, t) => s + t.amount);

        final cats = <String, double>{};
        for (final t in txns.where((t) => t.isDebit)) {
          cats[t.category] = (cats[t.category] ?? 0) + t.amount;
        }

        months.add({
          'month': label,
          'income': income,
          'expenses': expenses,
          'savings': income - expenses,
          'categories': cats,
        });
      }
      return months;
    }
    throw UnimplementedError('Real API not implemented');
  }

  static Future<List<Map<String, dynamic>>> getRecurringTransactions() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      final recurring = _mockTransactions.where((t) => t.isRecurring).toList();

      final byMerchant = <String, List<FinancialTransaction>>{};
      for (final t in recurring) {
        final key = t.merchant ?? 'Unknown';
        byMerchant.putIfAbsent(key, () => []).add(t);
      }

      return byMerchant.entries.map((e) {
        final txns = e.value;
        final avg = txns.fold(0.0, (s, t) => s + t.amount) / txns.length;
        return {
          'merchant': e.key,
          'category': txns.first.category,
          'avg_amount': avg,
          'frequency': 'Monthly',
          'occurrence_count': txns.length,
          'last_date': txns.first.date,
          'type': txns.first.type,
        };
      }).toList()
        ..sort((a, b) => (b['avg_amount'] as double).compareTo(a['avg_amount'] as double));
    }
    throw UnimplementedError('Real API not implemented');
  }

  // ── Helpers ──

  static double get totalBalance =>
      _mockAccounts.where((a) => a.status == 'ACTIVE').fold(0.0, (s, a) => s + a.balance);

  static bool get hasLinkedAccounts =>
      _mockAccounts.any((a) => a.status == 'ACTIVE');

  static String _monthName(int m) {
    const names = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[m.clamp(1, 12)];
  }

  static List<FinancialTransaction> _generateMockTransactions(String accountId) {
    final rng = Random();
    final txns = <FinancialTransaction>[];
    final now = DateTime.now();

    final merchants = {
      'FOOD': [('Swiggy', 150.0, 800.0), ('Zomato', 120.0, 650.0), ('Dominos', 200.0, 900.0), ('Starbucks', 250.0, 600.0)],
      'SHOPPING': [('Amazon', 200.0, 8000.0), ('Flipkart', 300.0, 6000.0), ('Myntra', 400.0, 5000.0)],
      'TRANSPORT': [('Uber', 80.0, 600.0), ('Ola', 70.0, 500.0), ('Metro Recharge', 200.0, 500.0)],
      'BILLS': [('Electricity Board', 800.0, 3500.0), ('Jio Recharge', 199.0, 999.0), ('Airtel Recharge', 239.0, 899.0)],
      'INCOME': [('Salary - Employer', 50000.0, 50000.0)],
      'RENT': [('Landlord Transfer', 12000.0, 12000.0)],
      'OTHER': [('Netflix', 199.0, 649.0), ('Spotify', 119.0, 179.0), ('Gym Membership', 1500.0, 3000.0)],
    };

    final weights = ['FOOD', 'FOOD', 'FOOD', 'SHOPPING', 'SHOPPING', 'TRANSPORT', 'TRANSPORT',
      'BILLS', 'BILLS', 'INCOME', 'RENT', 'OTHER', 'OTHER', 'OTHER', 'FOOD', 'SHOPPING', 'TRANSPORT', 'BILLS'];

    for (int i = 0; i < 70 + rng.nextInt(30); i++) {
      final cat = weights[rng.nextInt(weights.length)];
      final merchantList = merchants[cat]!;
      final m = merchantList[rng.nextInt(merchantList.length)];
      final daysAgo = rng.nextInt(90);
      final date = now.subtract(Duration(days: daysAgo, hours: rng.nextInt(12), minutes: rng.nextInt(60)));
      final amount = m.$2 + rng.nextDouble() * (m.$3 - m.$2);
      final isRecurring = cat == 'INCOME' || cat == 'RENT' || (cat == 'OTHER' && ['Netflix', 'Spotify', 'Gym Membership'].contains(m.$1));

      txns.add(FinancialTransaction(
        id: 'ft-${accountId.hashCode.abs()}-$i',
        accountId: accountId,
        transactionId: 'TXN-$i-${date.millisecondsSinceEpoch}',
        date: date.toIso8601String(),
        amount: double.parse(amount.toStringAsFixed(2)),
        type: cat == 'INCOME' ? 'CREDIT' : 'DEBIT',
        description: 'UPI-${m.$1.toUpperCase().replaceAll(' ', '')}-${date.day}${date.month}',
        merchant: m.$1,
        category: cat,
        isRecurring: isRecurring,
      ));
    }

    txns.sort((a, b) => b.date.compareTo(a.date));
    return txns;
  }
}
