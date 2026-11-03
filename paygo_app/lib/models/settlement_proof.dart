// PayGo — Event Collect: SettlementProof model
// Cryptographic proof generated when an event is closed.
// SHA-256 digest of canonical ledger snapshot, signed with ECDSA.

class SettlementProof {
  final String eventId;
  final String canonicalSnapshotHash; // SHA-256
  final String signature;             // ECDSA signature (hex)
  final String keyId;                 // KMS key identifier
  final DateTime signedAt;
  final String? canonicalSnapshot;    // JSON snapshot (for verify screen)

  const SettlementProof({
    required this.eventId,
    required this.canonicalSnapshotHash,
    required this.signature,
    required this.keyId,
    required this.signedAt,
    this.canonicalSnapshot,
  });

  factory SettlementProof.fromJson(Map<String, dynamic> json) {
    return SettlementProof(
      eventId: json['event_id'] as String,
      canonicalSnapshotHash: json['canonical_snapshot_hash'] as String,
      signature: json['signature'] as String,
      keyId: json['key_id'] as String,
      signedAt: DateTime.parse(json['signed_at'] as String),
      canonicalSnapshot: json['canonical_snapshot'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'event_id': eventId,
    'canonical_snapshot_hash': canonicalSnapshotHash,
    'signature': signature,
    'key_id': keyId,
    'signed_at': signedAt.toIso8601String(),
    'canonical_snapshot': canonicalSnapshot,
  };
}
