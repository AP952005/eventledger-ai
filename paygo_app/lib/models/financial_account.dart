/// PayGo — Financial Account Model
/// Represents a bank account linked via Account Aggregator.

class FinancialAccount {
  final String id;
  final String fipId;
  final String accountType;
  final String maskedAccountNumber;
  final String bankName;
  final double balance;
  final String holderName;
  final String linkedAt;
  final String lastSynced;
  final String status;

  const FinancialAccount({
    required this.id,
    required this.fipId,
    required this.accountType,
    required this.maskedAccountNumber,
    required this.bankName,
    this.balance = 0.0,
    this.holderName = 'Abishek',
    required this.linkedAt,
    required this.lastSynced,
    this.status = 'ACTIVE',
  });

  factory FinancialAccount.fromJson(Map<String, dynamic> json) {
    return FinancialAccount(
      id: json['id'] ?? '',
      fipId: json['fip_id'] ?? json['fipId'] ?? '',
      accountType: json['account_type'] ?? json['accountType'] ?? 'SAVINGS',
      maskedAccountNumber: json['masked_account_number'] ?? json['maskedAccountNumber'] ?? '',
      bankName: json['bank_name'] ?? json['bankName'] ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      holderName: json['holder_name'] ?? json['holderName'] ?? 'Abishek',
      linkedAt: json['linked_at'] ?? json['linkedAt'] ?? '',
      lastSynced: json['last_synced'] ?? json['lastSynced'] ?? '',
      status: json['status'] ?? 'ACTIVE',
    );
  }
}
