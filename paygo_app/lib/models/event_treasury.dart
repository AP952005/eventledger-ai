class EventTreasuryModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String currency;
  final double amount;
  final double targetAmount;
  final int expectedParticipants;
  final String expiryAt;
  final String status;
  final String createdAt;
  final double collectedAmount;
  final int registeredCount;
  final int paidCount;

  EventTreasuryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.currency,
    required this.amount,
    required this.targetAmount,
    required this.expectedParticipants,
    required this.expiryAt,
    required this.status,
    required this.createdAt,
    this.collectedAmount = 0.0,
    this.registeredCount = 0,
    this.paidCount = 0,
  });

  factory EventTreasuryModel.fromJson(Map<String, dynamic> json) {
    return EventTreasuryModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
      currency: json['currency'] ?? 'USD',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      targetAmount: (json['target_amount'] as num?)?.toDouble() ?? 0.0,
      expectedParticipants: (json['expected_participants'] as num?)?.toInt() ?? 50,
      expiryAt: json['expiry_at'] ?? '',
      status: json['status'] ?? 'ACTIVE',
      createdAt: json['created_at'] ?? '',
      collectedAmount: (json['collected_amount'] as num?)?.toDouble() ?? 0.0,
      registeredCount: (json['registered_count'] as num?)?.toInt() ?? 0,
      paidCount: (json['paid_count'] as num?)?.toInt() ?? 0,
    );
  }

  bool get isActive => status == 'ACTIVE';
  bool get isClosed => status == 'CLOSED';
  bool get isExpired => status == 'EXPIRED';
}

class ParticipantModel {
  final String id;
  final String eventId;
  final String name;
  final String email;
  final String? phone;
  final String registrationId;
  final String registeredAt;
  final String status;
  final double amount;
  final String currency;
  final String? paypalInvoiceId;
  final String? paypalPaymentUrl;
  final String? paypalQrBase64;
  final String? paidAt;
  final String? transactionReference;

  ParticipantModel({
    required this.id,
    required this.eventId,
    required this.name,
    required this.email,
    this.phone,
    required this.registrationId,
    required this.registeredAt,
    required this.status,
    required this.amount,
    required this.currency,
    this.paypalInvoiceId,
    this.paypalPaymentUrl,
    this.paypalQrBase64,
    this.paidAt,
    this.transactionReference,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id'] ?? '',
      eventId: json['event_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      registrationId: json['registration_id'] ?? '',
      registeredAt: json['registered_at'] ?? '',
      status: json['status'] ?? 'AWAITING_PAYMENT',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      paypalInvoiceId: json['paypal_invoice_id'],
      paypalPaymentUrl: json['paypal_payment_url'],
      paypalQrBase64: json['paypal_qr_base64'],
      paidAt: json['paid_at'],
      transactionReference: json['transaction_reference'],
    );
  }

  bool get isPaid => status == 'PAID';
}

