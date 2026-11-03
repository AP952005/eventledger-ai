/// PayGo — User data model
class BankAccount {
  final String id;
  final String bankName;
  final String accountLast4;
  final bool isPrimary;

  const BankAccount({
    required this.id,
    required this.bankName,
    required this.accountLast4,
    required this.isPrimary,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'] as String,
      bankName: json['bank_name'] as String,
      accountLast4: json['account_last4'] as String,
      isPrimary: json['is_primary'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'bank_name': bankName,
    'account_last4': accountLast4,
    'is_primary': isPrimary,
  };
}

class User {
  final String id;
  final String name;
  final String phone;
  final String upiId;
  final bool isVerified;
  final String? avatarUrl;
  final List<BankAccount> linkedBanks;
  final double? postpaidLimit;
  final double walletBalance;
  /// Event Collect alias VPA (e.g. "farewell2026@paygo").
  /// Null until the one-time alias setup flow is completed.
  /// Personal QR continues using [upiId] (phone-based) — this field is Event Collect only.
  final String? eventVpa;

  const User({
    required this.id,
    required this.name,
    required this.phone,
    required this.upiId,
    required this.isVerified,
    this.avatarUrl,
    this.linkedBanks = const [],
    this.postpaidLimit,
    this.walletBalance = 0.0,
    this.eventVpa,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      upiId: json['upi_id'] as String,
      isVerified: json['is_verified'] as bool,
      avatarUrl: json['avatar_url'] as String?,
      linkedBanks: (json['linked_banks'] as List<dynamic>?)
          ?.map((b) => BankAccount.fromJson(b as Map<String, dynamic>))
          .toList() ?? [],
      postpaidLimit: (json['postpaid_limit'] as num?)?.toDouble(),
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      eventVpa: json['event_vpa'] as String?,
    );
  }

  /// Get user's initials for avatar display
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// Registered KYC name — used for event QR payeeName.
  /// Cannot be event title; this is a UPI network rule, not a payGo choice.
  String get registeredName => name;

  BankAccount? get primaryBank {
    try {
      return linkedBanks.firstWhere((b) => b.isPrimary);
    } catch (_) {
      return linkedBanks.isNotEmpty ? linkedBanks.first : null;
    }
  }

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? upiId,
    bool? isVerified,
    String? avatarUrl,
    List<BankAccount>? linkedBanks,
    double? postpaidLimit,
    double? walletBalance,
    String? eventVpa,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      upiId: upiId ?? this.upiId,
      isVerified: isVerified ?? this.isVerified,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      linkedBanks: linkedBanks ?? this.linkedBanks,
      postpaidLimit: postpaidLimit ?? this.postpaidLimit,
      walletBalance: walletBalance ?? this.walletBalance,
      eventVpa: eventVpa ?? this.eventVpa,
    );
  }
}

