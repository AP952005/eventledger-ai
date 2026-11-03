// PayGo — Event Collect: LedgerEntry model
// Each row represents an incoming UPI settlement matched to an event.
//
// OUT OF SCOPE (by design):
// - No fuzzy matching or name-similarity inference for unmatched payments
// - No auto-tagging under any circumstance — exact match or manual tag only
// - No editing after event CLOSED — rows are immutable at the data layer

import 'package:intl/intl.dart';

class LedgerEntry {
  final String id;
  final String eventId;
  final String? participantId; // null until tagged (manually or by exact match)
  final String? participantName;
  final String payerVpaOrPhone;
  final double amount;
  final String txnRef;
  final DateTime matchedAt;
  final String? taggedBy;    // organizerUserId if manually matched — auditable
  final DateTime? taggedAt;  // timestamp of manual tag — auditable

  const LedgerEntry({
    required this.id,
    required this.eventId,
    this.participantId,
    this.participantName,
    required this.payerVpaOrPhone,
    required this.amount,
    required this.txnRef,
    required this.matchedAt,
    this.taggedBy,
    this.taggedAt,
  });

  /// True if this payment has not been matched to any participant
  bool get isUnmatched => participantId == null;

  String get formattedAmount => '₹${NumberFormat('#,##0.00').format(amount)}';

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    return LedgerEntry(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      participantId: json['participant_id'] as String?,
      participantName: json['participant_name'] as String?,
      payerVpaOrPhone: json['payer_vpa_or_phone'] as String,
      amount: (json['amount'] as num).toDouble(),
      txnRef: json['txn_ref'] as String,
      matchedAt: DateTime.parse(json['matched_at'] as String),
      taggedBy: json['tagged_by'] as String?,
      taggedAt: json['tagged_at'] != null ? DateTime.parse(json['tagged_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'event_id': eventId,
    'participant_id': participantId,
    'participant_name': participantName,
    'payer_vpa_or_phone': payerVpaOrPhone,
    'amount': amount,
    'txn_ref': txnRef,
    'matched_at': matchedAt.toIso8601String(),
    'tagged_by': taggedBy,
    'tagged_at': taggedAt?.toIso8601String(),
  };

  /// Create a copy with tag information applied (for manual matching)
  LedgerEntry copyWithTag({
    required String participantId,
    required String participantName,
    required String taggedBy,
  }) {
    return LedgerEntry(
      id: id,
      eventId: eventId,
      participantId: participantId,
      participantName: participantName,
      payerVpaOrPhone: payerVpaOrPhone,
      amount: amount,
      txnRef: txnRef,
      matchedAt: matchedAt,
      taggedBy: taggedBy,
      taggedAt: DateTime.now(),
    );
  }
}
