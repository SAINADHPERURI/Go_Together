import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  joinRequest,
  requestAccepted,
  requestRejected,
  newGroupMessage,
  tripUpdate,
  tripCancelled,
  tripMatch;

  static NotificationType fromString(String? type) {
    switch (type) {
      case 'join_request':
      case 'joinRequest':
        return NotificationType.joinRequest;
      case 'request_accepted':
      case 'requestAccepted':
        return NotificationType.requestAccepted;
      case 'request_rejected':
      case 'requestRejected':
        return NotificationType.requestRejected;
      case 'new_group_message':
      case 'newGroupMessage':
        return NotificationType.newGroupMessage;
      case 'trip_update':
      case 'tripUpdate':
        return NotificationType.tripUpdate;
      case 'trip_cancelled':
      case 'tripCancelled':
        return NotificationType.tripCancelled;
      case 'trip_match':
      case 'tripMatch':
        return NotificationType.tripMatch;
      default:
        return NotificationType.tripUpdate;
    }
  }

  String get code {
    switch (this) {
      case NotificationType.joinRequest:
        return 'join_request';
      case NotificationType.requestAccepted:
        return 'request_accepted';
      case NotificationType.requestRejected:
        return 'request_rejected';
      case NotificationType.newGroupMessage:
        return 'new_group_message';
      case NotificationType.tripUpdate:
        return 'trip_update';
      case NotificationType.tripCancelled:
        return 'trip_cancelled';
      case NotificationType.tripMatch:
        return 'trip_match';
    }
  }
}

class AppNotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final String? tripId;
  final bool isRead;
  final DateTime createdAt;

  const AppNotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.tripId,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.code,
      'tripId': tripId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AppNotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
      return DateTime.now();
    }

    return AppNotificationModel(
      id: docId,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? 'GoTogether Update',
      body: map['body'] as String? ?? '',
      type: NotificationType.fromString(map['type'] as String?),
      tripId: map['tripId'] as String?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: parseDate(map['createdAt']),
    );
  }

  factory AppNotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppNotificationModel.fromMap(data, doc.id);
  }

  AppNotificationModel copyWith({bool? isRead}) {
    return AppNotificationModel(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      tripId: tripId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}

typedef NotificationModel = AppNotificationModel;

