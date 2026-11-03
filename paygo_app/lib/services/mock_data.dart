/// PayGo — In-memory mock data for offline-first development
/// Mirrors the Python backend seed data so the app works without a server.

import '../models/user.dart';
import '../models/transaction.dart';
import '../models/saved_biller.dart';
import '../models/notification.dart';
import '../models/contact.dart';
import '../models/event.dart';
import '../models/ledger_entry.dart';
import '../models/settlement_proof.dart';
import '../models/reminder_template.dart';

class MockData {
  MockData._();

  // ──────────────────────────────────────────────
  // Current User
  // ──────────────────────────────────────────────

  static User currentUser = const User(
    id: 'u-001',
    name: 'Abishek',
    phone: '+919363684402',
    upiId: '9363684402@ptyes',
    isVerified: true,
    linkedBanks: [
      BankAccount(id: 'b-001', bankName: 'Paytm Payments Bank', accountLast4: '4402', isPrimary: true),
      BankAccount(id: 'b-002', bankName: 'HDFC Bank', accountLast4: '8832', isPrimary: false),
    ],
    postpaidLimit: 60000.0,
    walletBalance: 2450.75,
    eventVpa: null,
  );

  // ──────────────────────────────────────────────
  // Contacts
  // ──────────────────────────────────────────────

  static final List<Contact> contacts = [
    const Contact(id: 'u-002', name: 'Priya Sharma', phone: '+919123456789', upiId: 'priya.s@paygo'),
    const Contact(id: 'u-003', name: 'Rahul Gupta', phone: '+919988776655', upiId: 'rahul.g@paygo'),
    const Contact(id: 'c-004', name: 'Ananya Desai', phone: '+919871234567', upiId: 'ananya.d@paygo'),
    const Contact(id: 'c-005', name: 'Vikram Singh', phone: '+919856781234', upiId: 'vikram.s@paygo'),
    const Contact(id: 'c-006', name: 'Meera Patel', phone: '+919845671230', upiId: 'meera.p@paygo'),
    const Contact(id: 'c-007', name: 'Karan Malhotra', phone: '+919834567891', upiId: 'karan.m@paygo'),
    const Contact(id: 'c-008', name: 'Sneha Reddy', phone: '+919823456780', upiId: 'sneha.r@paygo'),
    const Contact(id: 'c-009', name: 'Dev Joshi', phone: '+919812345670', upiId: 'dev.j@paygo'),
    const Contact(id: 'c-010', name: 'Nisha Verma', phone: '+919801234560', upiId: 'nisha.v@paygo'),
    const Contact(id: 'c-011', name: 'Amit Kumar', phone: '+919790123450', upiId: 'amit.k@paygo'),
  ];

  static List<Contact> get recentContacts => contacts.sublist(0, 5);

  // ──────────────────────────────────────────────
  // Transactions
  // ──────────────────────────────────────────────

  static final List<Transaction> transactions = [
    Transaction(
      id: 'txn-001', fromUserId: 'u-001', toUserId: 'u-002',
      amount: 7000.0, direction: TransactionDirection.sent,
      category: TransactionCategory.p2p, status: TransactionStatus.success,
      note: 'Rent share', timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Transaction(
      id: 'txn-002', fromUserId: 'u-002', toUserId: 'u-001',
      amount: 1500.0, direction: TransactionDirection.received,
      category: TransactionCategory.p2p, status: TransactionStatus.success,
      note: 'Dinner split', timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Transaction(
      id: 'txn-003', fromUserId: 'u-001', merchantOrBillerId: 'biller-jio',
      amount: 299.0, direction: TransactionDirection.sent,
      category: TransactionCategory.recharge, status: TransactionStatus.success,
      note: 'Jio Recharge', timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Transaction(
      id: 'txn-004', fromUserId: 'u-001', merchantOrBillerId: 'biller-electricity',
      amount: 2350.0, direction: TransactionDirection.sent,
      category: TransactionCategory.bill, status: TransactionStatus.success,
      note: 'Electricity Bill - Sep', timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Transaction(
      id: 'txn-005', fromUserId: 'u-003', toUserId: 'u-001',
      amount: 500.0, direction: TransactionDirection.received,
      category: TransactionCategory.p2p, status: TransactionStatus.success,
      note: 'Tea money', timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Transaction(
      id: 'txn-006', fromUserId: 'u-001', toUserId: 'u-003',
      amount: 12000.0, direction: TransactionDirection.sent,
      category: TransactionCategory.p2p, status: TransactionStatus.success,
      note: 'Freelance payment', timestamp: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Transaction(
      id: 'txn-007', fromUserId: 'u-001', merchantOrBillerId: 'biller-dth',
      amount: 450.0, direction: TransactionDirection.sent,
      category: TransactionCategory.recharge, status: TransactionStatus.failed,
      note: 'DTH Recharge', timestamp: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Transaction(
      id: 'txn-008', fromUserId: 'u-001', merchantOrBillerId: 'merchant-amazon',
      amount: 3499.0, direction: TransactionDirection.sent,
      category: TransactionCategory.shopping, status: TransactionStatus.success,
      note: 'Amazon Purchase', timestamp: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Transaction(
      id: 'txn-009', fromUserId: 'u-001', merchantOrBillerId: 'invest-gold',
      amount: 1000.0, direction: TransactionDirection.sent,
      category: TransactionCategory.investment, status: TransactionStatus.success,
      note: 'Gold Investment', timestamp: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Transaction(
      id: 'txn-010', fromUserId: 'u-002', toUserId: 'u-001',
      amount: 2500.0, direction: TransactionDirection.received,
      category: TransactionCategory.p2p, status: TransactionStatus.pending,
      note: 'Birthday gift', timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Transaction(
      id: 'txn-011', fromUserId: 'u-001', merchantOrBillerId: 'biller-gas',
      amount: 850.0, direction: TransactionDirection.sent,
      category: TransactionCategory.bill, status: TransactionStatus.success,
      note: 'Piped Gas Bill', timestamp: DateTime.now().subtract(const Duration(days: 6)),
    ),
    Transaction(
      id: 'txn-012', fromUserId: 'u-001', toUserId: 'u-002',
      amount: 350.0, direction: TransactionDirection.sent,
      category: TransactionCategory.p2p, status: TransactionStatus.success,
      note: 'Coffee ☕', timestamp: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  // ──────────────────────────────────────────────
  // Saved Billers
  // ──────────────────────────────────────────────

  static final List<SavedBiller> savedBillers = [
    SavedBiller(id: 'sb-001', userId: 'u-001', category: 'mobile', providerName: 'Jio', identifier: '9876543210', addedOn: DateTime.now().subtract(const Duration(days: 90)), autopayEnabled: true),
    SavedBiller(id: 'sb-002', userId: 'u-001', category: 'electricity', providerName: 'Tata Power', identifier: 'TP-44210098', addedOn: DateTime.now().subtract(const Duration(days: 60)), autopayEnabled: false),
    SavedBiller(id: 'sb-003', userId: 'u-001', category: 'dth', providerName: 'Tata Play', identifier: 'DTH-88321', addedOn: DateTime.now().subtract(const Duration(days: 45)), autopayEnabled: true),
    SavedBiller(id: 'sb-004', userId: 'u-001', category: 'gas', providerName: 'Mahanagar Gas', identifier: 'MGL-55102', addedOn: DateTime.now().subtract(const Duration(days: 30)), autopayEnabled: false),
    SavedBiller(id: 'sb-005', userId: 'u-001', category: 'credit_card', providerName: 'HDFC Bank', identifier: 'XXXX-8832', addedOn: DateTime.now().subtract(const Duration(days: 20)), autopayEnabled: false),
  ];

  // ──────────────────────────────────────────────
  // Notifications
  // ──────────────────────────────────────────────

  static final List<AppNotification> notifications = [
    AppNotification(id: 'n-001', type: NotificationType.txn, title: 'Payment Successful', body: '₹7,000 sent to Priya Sharma', read: false, createdAt: DateTime.now().subtract(const Duration(hours: 2))),
    AppNotification(id: 'n-002', type: NotificationType.offer, title: '🎉 Flat ₹30 Cashback!', body: 'Recharge your DTH and get flat ₹30 cashback. Offer valid till tonight!', read: false, createdAt: DateTime.now().subtract(const Duration(hours: 4))),
    AppNotification(id: 'n-003', type: NotificationType.txn, title: 'Money Received', body: '₹1,500 received from Priya Sharma', read: true, createdAt: DateTime.now().subtract(const Duration(hours: 5))),
    AppNotification(id: 'n-004', type: NotificationType.system, title: 'Security Alert', body: 'Activate Security Shield to protect your account from fraud.', read: false, createdAt: DateTime.now().subtract(const Duration(hours: 8))),
    AppNotification(id: 'n-005', type: NotificationType.offer, title: 'Gold Price Drop 📉', body: 'Gold prices are at a 30-day low. Great time to invest!', read: true, createdAt: DateTime.now().subtract(const Duration(days: 1))),
    AppNotification(id: 'n-006', type: NotificationType.txn, title: 'Recharge Successful', body: '₹299 Jio recharge done for 9876543210', read: true, createdAt: DateTime.now().subtract(const Duration(days: 1))),
    AppNotification(id: 'n-007', type: NotificationType.offer, title: 'Refer & Win ₹60', body: "You're just 1 referral away from assured ₹60 cashback!", read: false, createdAt: DateTime.now().subtract(const Duration(days: 2))),
    AppNotification(id: 'n-008', type: NotificationType.system, title: 'KYC Reminder', body: 'Complete your KYC to enjoy uninterrupted services.', read: true, createdAt: DateTime.now().subtract(const Duration(days: 3))),
  ];

  static int get unreadNotificationCount => notifications.where((n) => !n.read).length;

  // ──────────────────────────────────────────────
  // Biller Categories
  // ──────────────────────────────────────────────

  static final List<BillerCategory> billerCategories = const [
    BillerCategory(key: 'mobile', label: 'Mobile Recharge', icon: 'phone_android'),
    BillerCategory(key: 'credit_card', label: 'Credit Card Bill', icon: 'credit_card'),
    BillerCategory(key: 'loan', label: 'Pay Loan EMI', icon: 'account_balance'),
    BillerCategory(key: 'fastag', label: 'FASTag Recharge', icon: 'directions_car', badge: 'No Fee'),
    BillerCategory(key: 'electricity', label: 'Electricity Bill', icon: 'bolt', badge: 'Flat ₹30'),
    BillerCategory(key: 'water', label: 'Water Bill', icon: 'water_drop'),
    BillerCategory(key: 'gas', label: 'Piped Gas Bill', icon: 'local_fire_department'),
    BillerCategory(key: 'lpg', label: 'Book LPG Cylinder', icon: 'propane_tank'),
    BillerCategory(key: 'dth', label: 'DTH Recharge', icon: 'satellite_alt', badge: 'Flat ₹15'),
    BillerCategory(key: 'cable', label: 'Cable TV', icon: 'tv'),
    BillerCategory(key: 'wifi', label: 'Wifi / Landline', icon: 'wifi'),
    BillerCategory(key: 'postpaid', label: 'Mobile Postpaid', icon: 'phone_iphone'),
  ];

  // ──────────────────────────────────────────────
  // Home Feed
  // ──────────────────────────────────────────────

  static final List<Map<String, dynamic>> homePromos = [
    {'title': 'Pay Bill, Get Gold', 'subtitle': 'Pay any bill above ₹500 and get free digital gold', 'cta': 'Pay Now', 'color': 0xFFFFB800},
    {'title': 'Send ₹10 → Get ₹30 Cashback', 'subtitle': 'Send money to any new contact', 'cta': null, 'color': 0xFF0077B6},
    {'title': 'Win Scratch Cards!', 'subtitle': 'Every UPI payment wins you a scratch card', 'cta': 'Know More', 'color': 0xFF00C853},
  ];

  static final List<Map<String, dynamic>> homeOffers = [
    {'title': '15% off on Flights', 'category': 'travel'},
    {'title': '40% off on Hotels', 'category': 'travel'},
    {'title': '₹51/day SIP', 'category': 'investment'},
    {'title': 'Free Credit Score Check', 'category': 'financial'},
  ];

  // ──────────────────────────────────────────────
  // Financial Products
  // ──────────────────────────────────────────────

  static final Map<String, List<Map<String, String>>> financialProducts = {
    'loans': [
      {'key': 'postpaid', 'label': 'PayGo Postpaid', 'icon': 'credit_score'},
      {'key': 'personal_loan', 'label': 'Get Loan', 'icon': 'currency_rupee'},
      {'key': 'mf_loan', 'label': 'Loan on Mutual Fund', 'icon': 'trending_up'},
      {'key': 'gold_loan', 'label': 'Gold Loan', 'icon': 'workspace_premium'},
    ],
    'insurance': [
      {'key': 'bike', 'label': 'Bike Insurance', 'icon': 'two_wheeler'},
      {'key': 'car', 'label': 'Car Insurance', 'icon': 'directions_car'},
      {'key': 'health', 'label': 'Health Insurance', 'icon': 'health_and_safety'},
      {'key': 'premium', 'label': 'Insurance Premium', 'icon': 'verified_user'},
    ],
    'investments': [
      {'key': 'mf', 'label': 'Mutual Fund', 'icon': 'show_chart'},
      {'key': 'stocks', 'label': 'Stocks', 'icon': 'candlestick_chart'},
      {'key': 'etf', 'label': 'ETFs', 'icon': 'auto_graph'},
      {'key': 'mtf', 'label': 'MTF @ 7.99%', 'icon': 'trending_up'},
    ],
    'cards': [
      {'key': 'get_cc', 'label': 'Get Credit Card', 'icon': 'add_card'},
      {'key': 'pay_cc', 'label': 'Pay Credit Card Bill', 'icon': 'payment'},
      {'key': 'rupay', 'label': 'Link RuPay to UPI', 'icon': 'link'},
    ],
  };

  // ──────────────────────────────────────────────
  // Message Threads (derived from transactions)
  // ──────────────────────────────────────────────

  static List<Map<String, dynamic>> get messageThreads {
    final Map<String, Map<String, dynamic>> threadMap = {};

    for (final txn in transactions) {
      final contactId = txn.direction == TransactionDirection.sent
          ? txn.toUserId
          : txn.fromUserId;
      if (contactId == null) continue;

      if (!threadMap.containsKey(contactId) ||
          txn.timestamp.isAfter(DateTime.parse(threadMap[contactId]!['lastDate']))) {
        final contact = contacts.firstWhere(
          (c) => c.id == contactId,
          orElse: () => Contact(id: contactId, name: 'Unknown', phone: ''),
        );
        threadMap[contactId] = {
          'contactId': contactId,
          'name': contact.name,
          'initials': contact.initials,
          'lastAmount': txn.amount,
          'lastDirection': txn.direction.name,
          'lastDate': txn.timestamp.toIso8601String(),
        };
      }
    }

    final threads = threadMap.values.toList();
    threads.sort((a, b) => b['lastDate'].compareTo(a['lastDate']));
    return threads;
  }

  // ──────────────────────────────────────────────
  // Event Collect — Mock Data
  // ──────────────────────────────────────────────

  static final _now = DateTime.now();

  static final List<CollectEvent> events = [
    CollectEvent(
      id: 'evt-001',
      organizerId: 'u-001',
      title: 'CS Dept Farewell 2026',
      amountMode: EventAmountMode.fixed,
      amount: 500.0,
      targetAmount: 10000.0,
      sameAmountFromEveryone: true,
      expiryAt: _now.add(const Duration(days: 14)),
      status: EventStatus.active,
      settlementVpa: '9363684402@ptyes',
      settlementName: 'Abishek',
      settlementAccountId: 'b-001',
      createdAt: _now.subtract(const Duration(days: 3)),
    ),
    CollectEvent(
      id: 'evt-002',
      organizerId: 'u-001',
      title: 'Goa Trip Fund',
      amountMode: EventAmountMode.suggested,
      amount: 2000.0,
      targetAmount: 16000.0,
      sameAmountFromEveryone: false,
      expiryAt: _now.subtract(const Duration(days: 1)),
      status: EventStatus.closed,
      settlementVpa: '9363684402@ptyes',
      settlementName: 'Abishek',
      settlementAccountId: 'b-001',
      createdAt: _now.subtract(const Duration(days: 30)),
      closedAt: _now.subtract(const Duration(days: 1)),
    ),
  ];

  static final List<LedgerEntry> ledgerEntries = [
    // evt-001: Active, 3 payments (1 unmatched)
    LedgerEntry(
      id: 'le-001', eventId: 'evt-001',
      participantId: 'u-002', participantName: 'Priya Sharma',
      payerVpaOrPhone: 'priya.s@paygo', amount: 500.0,
      txnRef: 'evt-001-txn-a01',
      matchedAt: _now.subtract(const Duration(days: 2)),
    ),
    LedgerEntry(
      id: 'le-002', eventId: 'evt-001',
      participantId: 'u-003', participantName: 'Rahul Gupta',
      payerVpaOrPhone: 'rahul.g@paygo', amount: 500.0,
      txnRef: 'evt-001-txn-a02',
      matchedAt: _now.subtract(const Duration(days: 1)),
    ),
    LedgerEntry(
      id: 'le-003', eventId: 'evt-001',
      // UNMATCHED — no fuzzy match, no auto-tag. Manual assignment required.
      payerVpaOrPhone: 'unknown.person@otherbank', amount: 500.0,
      txnRef: 'evt-001-txn-a03',
      matchedAt: _now.subtract(const Duration(hours: 6)),
    ),
    // evt-002: Closed, 3 payments (all matched)
    LedgerEntry(
      id: 'le-004', eventId: 'evt-002',
      participantId: 'u-002', participantName: 'Priya Sharma',
      payerVpaOrPhone: 'priya.s@paygo', amount: 2000.0,
      txnRef: 'evt-002-txn-b01',
      matchedAt: _now.subtract(const Duration(days: 20)),
    ),
    LedgerEntry(
      id: 'le-005', eventId: 'evt-002',
      participantId: 'u-003', participantName: 'Rahul Gupta',
      payerVpaOrPhone: 'rahul.g@paygo', amount: 2500.0,
      txnRef: 'evt-002-txn-b02',
      matchedAt: _now.subtract(const Duration(days: 15)),
    ),
    LedgerEntry(
      id: 'le-006', eventId: 'evt-002',
      participantId: 'c-004', participantName: 'Ananya Desai',
      payerVpaOrPhone: 'ananya.d@paygo', amount: 2000.0,
      txnRef: 'evt-002-txn-b03',
      matchedAt: _now.subtract(const Duration(days: 10)),
      taggedBy: 'u-001', taggedAt: _now.subtract(const Duration(days: 10)),
    ),
  ];

  static final List<SettlementProof> settlementProofs = [
    SettlementProof(
      eventId: 'evt-002',
      canonicalSnapshotHash: 'a3f2b8c1d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1',
      signature: '304502210098b7c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3',
      keyId: 'paygo-event-signing-key-v1',
      signedAt: _now.subtract(const Duration(days: 1)),
      canonicalSnapshot: '{"event_id":"evt-002","title":"Goa Trip Fund","entries":[...]}',
    ),
  ];

  static final Set<String> takenAliases = {'abishek2026', 'demo', 'test', 'admin', 'paygo'};

  static List<LedgerEntry> ledgerForEvent(String eventId) =>
    ledgerEntries.where((e) => e.eventId == eventId).toList();

  static double collectedForEvent(String eventId) =>
    ledgerForEvent(eventId).fold(0.0, (sum, e) => sum + e.amount);

  static int unmatchedCountForEvent(String eventId) =>
    ledgerForEvent(eventId).where((e) => e.isUnmatched).length;
}
