import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  system;

  static MessageType fromString(String? type) {
    if (type == 'system') return MessageType.system;
    return MessageType.text;
  }
}

class ChatMessageModel {
  final String id;
  final String tripId;
  final String senderId;
  final String senderName;
  final String? senderPhotoUrl;
  final String text;
  final MessageType type;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.tripId,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.text,
    this.type = MessageType.text,
    required this.createdAt,
  });

  bool get isSystem => type == MessageType.system;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'text': text,
      'type': type.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
      return DateTime.now();
    }

    return ChatMessageModel(
      id: docId,
      tripId: map['tripId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? 'Member',
      senderPhotoUrl: map['senderPhotoUrl'] as String?,
      text: map['text'] as String? ?? '',
      type: MessageType.fromString(map['type'] as String?),
      createdAt: parseDate(map['createdAt']),
    );
  }
}
