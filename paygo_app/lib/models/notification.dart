/// PayGo — Notification data model

enum NotificationType { txn, offer, system }

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: NotificationType.values.firstWhere(
        (t) => t.name == json['type'],
      ),
      title: json['title'] as String,
      body: json['body'] as String,
      read: json['read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
