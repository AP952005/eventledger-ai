/// PayGo — AA Consent Model

class Consent {
  final String consentId;
  final String status;
  final String purpose;
  final String fromDate;
  final String toDate;
  final String frequency;
  final String createdAt;
  final List<String> dataTypes;
  final String? bankName;

  const Consent({
    required this.consentId,
    required this.status,
    this.purpose = 'Personal financial management',
    this.fromDate = '',
    this.toDate = '',
    this.frequency = 'ONE_TIME',
    this.createdAt = '',
    this.dataTypes = const [],
    this.bankName,
  });

  factory Consent.fromJson(Map<String, dynamic> json) {
    return Consent(
      consentId: json['consent_id'] ?? json['consentId'] ?? '',
      status: json['status'] ?? 'PENDING',
      purpose: json['purpose'] ?? 'Personal financial management',
      fromDate: json['from_date'] ?? json['fromDate'] ?? '',
      toDate: json['to_date'] ?? json['toDate'] ?? '',
      frequency: json['frequency'] ?? 'ONE_TIME',
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
      dataTypes: (json['data_types'] as List?)?.cast<String>() ?? [],
      bankName: json['bank_name'] ?? json['bankName'],
    );
  }
}
