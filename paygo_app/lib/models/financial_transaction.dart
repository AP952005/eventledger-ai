/// PayGo — Financial Transaction Model
/// Normalized transaction from Account Aggregator data.

class FinancialTransaction {
  final String id;
  final String accountId;
  final String transactionId;
  final String date;
  final double amount;
  final String type; // DEBIT | CREDIT
  final String description;
  final String? merchant;
  final String category;
  final bool isRecurring;

  const FinancialTransaction({
    required this.id,
    required this.accountId,
    required this.transactionId,
    required this.date,
    required this.amount,
    required this.type,
    required this.description,
    this.merchant,
    required this.category,
    this.isRecurring = false,
  });

  factory FinancialTransaction.fromJson(Map<String, dynamic> json) {
    return FinancialTransaction(
      id: json['id'] ?? '',
      accountId: json['account_id'] ?? json['accountId'] ?? '',
      transactionId: json['transaction_id'] ?? json['transactionId'] ?? '',
      date: json['date'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] ?? 'DEBIT',
      description: json['description'] ?? '',
      merchant: json['merchant'],
      category: json['category'] ?? 'OTHER',
      isRecurring: json['is_recurring'] ?? json['isRecurring'] ?? false,
    );
  }

  bool get isCredit => type == 'CREDIT';
  bool get isDebit => type == 'DEBIT';
}
