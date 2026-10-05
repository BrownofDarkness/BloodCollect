import '../../../core/constants/app_enums.dart';
import '../../domain/entities/app_notification.dart';
import 'firestore_converters.dart';

// ---- notifications
class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.recipientId,
    required super.type,
    required super.title,
    required super.body,
    super.payload,
    super.isRead = false,
    required super.createdAt,
    super.readAt,
  });

  factory AppNotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return AppNotificationModel(
      id: id,
      recipientId: map['recipientId'] as String? ?? '',
      type:
          NotificationType.fromString(map['type'] as String?) ??
          NotificationType.bloodRequest,
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      payload: map['payload'] == null
          ? null
          : Map<String, dynamic>.from(map['payload'] as Map),
      isRead: map['isRead'] as bool? ?? false,
      createdAt: tsToDate(map['createdAt'], fallback: DateTime.now()),
      readAt: tsToDateOrNull(map['readAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'recipientId': recipientId,
    'type': type.firestoreValue,
    'title': title,
    'body': body,
    'payload': payload,
    'isRead': isRead,
    'createdAt': dateToTs(createdAt),
    'readAt': readAt == null ? null : dateToTs(readAt!),
  };
}
