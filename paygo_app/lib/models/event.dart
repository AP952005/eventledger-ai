// PayGo — Event Collect: CollectEvent model
// Represents a scoped collection event with its own QR, ledger, and settlement flow.
//
// OUT OF SCOPE (by design, not oversight):
// - No NLP/LLM parsing of event titles or notes
// - No custodial wallet balance — funds move contributor→organizer over UPI rails
// - No auto-close before stated expiry regardless of target-amount progress
// - No editing of ledger data after CLOSED status

enum EventAmountMode { fixed, suggested, flexible }

enum EventStatus { active, expired, closed }

class CollectEvent {
  final String id;
  final String organizerId;
  final String title;
  final EventAmountMode amountMode;
  final double? amount;
  final double? targetAmount;
  final bool sameAmountFromEveryone;
  final DateTime expiryAt;
  final EventStatus status;
  final String settlementVpa;
  final String settlementName;
  final String settlementAccountId;
  final DateTime createdAt;
  final DateTime? closedAt;

  const CollectEvent({
    required this.id,
    required this.organizerId,
    required this.title,
    required this.amountMode,
    this.amount,
    this.targetAmount,
    this.sameAmountFromEveryone = false,
    required this.expiryAt,
    required this.status,
    required this.settlementVpa,
    required this.settlementName,
    required this.settlementAccountId,
    required this.createdAt,
    this.closedAt,
  });

  bool get isActive => status == EventStatus.active;
  bool get isClosed => status == EventStatus.closed;
  bool get isExpired => status == EventStatus.expired;

  /// Progress as fraction 0.0–1.0 (returns 0 if no target set)
  double progressFraction(double collectedAmount) {
    if (targetAmount == null || targetAmount == 0) return 0.0;
    return (collectedAmount / targetAmount!).clamp(0.0, 1.0);
  }

  /// UPI deep link for event QR
  /// payeeVpa = event alias (never phone-based VPA)
  /// payeeName = registered KYC name (cannot be event title — UPI network rule)
  /// tr = eventId for webhook matching
  String get upiDeepLink {
    final params = <String, String>{
      'pa': settlementVpa,
      'pn': settlementName,
      'tn': title,
      'tr': id,
      'cu': 'INR',
    };
    // For FIXED mode, lock the amount
    if (amountMode == EventAmountMode.fixed && amount != null) {
      params['am'] = amount!.toStringAsFixed(2);
    }
    // For SUGGESTED mode, include amount but payer can edit
    if (amountMode == EventAmountMode.suggested && amount != null) {
      params['am'] = amount!.toStringAsFixed(2);
    }
    // FLEXIBLE mode: no amount in QR
    final query = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    return 'upi://pay?$query';
  }

  factory CollectEvent.fromJson(Map<String, dynamic> json) {
    return CollectEvent(
      id: json['id'] as String,
      organizerId: json['organizer_id'] as String,
      title: json['title'] as String,
      amountMode: EventAmountMode.values.firstWhere(
        (m) => m.name.toUpperCase() == (json['amount_mode'] as String).toUpperCase(),
      ),
      amount: (json['amount'] as num?)?.toDouble(),
      targetAmount: (json['target_amount'] as num?)?.toDouble(),
      sameAmountFromEveryone: json['same_amount_from_everyone'] as bool? ?? false,
      expiryAt: DateTime.parse(json['expiry_at'] as String),
      status: EventStatus.values.firstWhere(
        (s) => s.name.toUpperCase() == (json['status'] as String).toUpperCase(),
      ),
      settlementVpa: json['settlement_vpa'] as String,
      settlementName: json['settlement_name'] as String,
      settlementAccountId: json['settlement_account_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      closedAt: json['closed_at'] != null ? DateTime.parse(json['closed_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'organizer_id': organizerId,
    'title': title,
    'amount_mode': amountMode.name.toUpperCase(),
    'amount': amount,
    'target_amount': targetAmount,
    'same_amount_from_everyone': sameAmountFromEveryone,
    'expiry_at': expiryAt.toIso8601String(),
    'status': status.name.toUpperCase(),
    'settlement_vpa': settlementVpa,
    'settlement_name': settlementName,
    'settlement_account_id': settlementAccountId,
    'created_at': createdAt.toIso8601String(),
    'closed_at': closedAt?.toIso8601String(),
  };
}
