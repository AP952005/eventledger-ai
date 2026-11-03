/// PayGo — Transaction data model

enum TransactionDirection { sent, received }
enum TransactionCategory { p2p, recharge, bill, shopping, investment }
enum TransactionStatus { success, pending, failed }

class Transaction {
  final String id;
  final String fromUserId;
  final String? toUserId;
  final String? merchantOrBillerId;
  final double amount;
  final TransactionDirection direction;
  final TransactionCategory category;
  final TransactionStatus status;
  final String? note;
  final DateTime timestamp;

  const Transaction({
    required this.id,
    required this.fromUserId,
    this.toUserId,
    this.merchantOrBillerId,
    required this.amount,
    required this.direction,
    required this.category,
    required this.status,
    this.note,
    required this.timestamp,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      fromUserId: json['from_user_id'] as String,
      toUserId: json['to_user_id'] as String?,
      merchantOrBillerId: json['merchant_or_biller_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      direction: TransactionDirection.values.firstWhere(
        (d) => d.name == json['direction'],
      ),
      category: TransactionCategory.values.firstWhere(
        (c) => c.name == json['category'],
      ),
      status: TransactionStatus.values.firstWhere(
        (s) => s.name == json['status'],
      ),
      note: json['note'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Human-readable formatted amount with currency symbol
  String get formattedAmount {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    }
    if (amount == amount.truncateToDouble()) {
      return '₹${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }

  /// Whether this is a debit transaction
  bool get isDebit => direction == TransactionDirection.sent;
}
