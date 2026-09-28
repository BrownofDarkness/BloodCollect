import '../../../core/constants/app_enums.dart';

// collection  ---- notifications/{notificationId}
class AppNotification {
  const AppNotification({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.body,
    this.payload,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
  });

  final String id;
  final String recipientId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic>? payload;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  AppNotification copyWith({
    String? id,
    String? recipientId,
    NotificationType? type,
    String? title,
    String? body,
    Map<String, dynamic>? Function()? payload,
    bool? isRead,
    DateTime? createdAt,
    DateTime? Function()? readAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload != null ? payload() : this.payload,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt != null ? readAt() : this.readAt,
    );
  }
}
