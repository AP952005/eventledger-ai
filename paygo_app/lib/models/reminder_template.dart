// PayGo — Event Collect: ReminderTemplate model
// Fixed set of message templates with variable substitution.
//
// OUT OF SCOPE (by design):
// - No AI-drafted copy, no NLP parsing, no auto-generated text
// - No auto-send, no scheduling — organizer triggers each send explicitly
// - Fixed templates only — this is a deliberate auditability decision

class ReminderTemplate {
  final String id;
  final String name;
  final String bodyTemplate;

  const ReminderTemplate({
    required this.id,
    required this.name,
    required this.bodyTemplate,
  });

  /// Substitute variables into the template
  String render({
    required String participantName,
    String? amount,
    required String eventTitle,
    required String deadline,
  }) {
    return bodyTemplate
        .replaceAll('{participantName}', participantName)
        .replaceAll('{amount}', amount ?? 'the required amount')
        .replaceAll('{eventTitle}', eventTitle)
        .replaceAll('{deadline}', deadline);
  }

  factory ReminderTemplate.fromJson(Map<String, dynamic> json) {
    return ReminderTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      bodyTemplate: json['body_template'] as String,
    );
  }

  /// The fixed set of reminder templates — no AI, no NLP, no dynamic generation
  static const List<ReminderTemplate> templates = [
    ReminderTemplate(
      id: 'tmpl-payment-reminder',
      name: 'Payment Reminder',
      bodyTemplate:
          'Hi {participantName}, this is a reminder to pay {amount} for "{eventTitle}". '
          'The deadline is {deadline}. Please pay at your earliest convenience.',
    ),
    ReminderTemplate(
      id: 'tmpl-final-reminder',
      name: 'Final Reminder — Event Closes Soon',
      bodyTemplate:
          'Hi {participantName}, "{eventTitle}" closes on {deadline}. '
          'Your payment of {amount} is still pending. This is the final reminder.',
    ),
    ReminderTemplate(
      id: 'tmpl-gentle-nudge',
      name: 'Gentle Nudge',
      bodyTemplate:
          'Hey {participantName}! Just a quick note — your contribution of {amount} '
          'for "{eventTitle}" is still pending. Deadline: {deadline}.',
    ),
    ReminderTemplate(
      id: 'tmpl-thank-you',
      name: 'Thank You (Post-Payment)',
      bodyTemplate:
          'Thank you {participantName}! Your payment of {amount} for "{eventTitle}" '
          'has been received. We appreciate your contribution!',
    ),
  ];
}
