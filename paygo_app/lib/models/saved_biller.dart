/// PayGo — Saved Biller data model

class SavedBiller {
  final String id;
  final String userId;
  final String category;
  final String providerName;
  final String identifier;
  final DateTime addedOn;
  final bool autopayEnabled;

  const SavedBiller({
    required this.id,
    required this.userId,
    required this.category,
    required this.providerName,
    required this.identifier,
    required this.addedOn,
    required this.autopayEnabled,
  });

  factory SavedBiller.fromJson(Map<String, dynamic> json) {
    return SavedBiller(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      category: json['category'] as String,
      providerName: json['provider_name'] as String,
      identifier: json['identifier'] as String,
      addedOn: DateTime.parse(json['added_on'] as String),
      autopayEnabled: json['autopay_enabled'] as bool,
    );
  }
}

/// Biller category for bill payment section
class BillerCategory {
  final String key;
  final String label;
  final String icon;
  final String? badge;

  const BillerCategory({
    required this.key,
    required this.label,
    required this.icon,
    this.badge,
  });

  factory BillerCategory.fromJson(Map<String, dynamic> json) {
    return BillerCategory(
      key: json['key'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String,
      badge: json['badge'] as String?,
    );
  }
}
