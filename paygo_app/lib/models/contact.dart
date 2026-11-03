/// PayGo — Contact data model

class Contact {
  final String id;
  final String name;
  final String phone;
  final String? upiId;
  final String? avatarUrl;

  const Contact({
    required this.id,
    required this.name,
    required this.phone,
    this.upiId,
    this.avatarUrl,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      upiId: json['upi_id'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  /// Get initials for avatar display
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
