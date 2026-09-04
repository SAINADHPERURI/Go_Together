import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/exceptions.dart';
import '../models/chat_message_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _messagesRef(String tripId) =>
      _firestore.collection('trips').doc(tripId).collection('messages');

  /// Stream real-time messages for a trip group chat (latest first)
  Stream<List<ChatMessageModel>> getMessagesStream(String tripId, {int limit = 100}) {
    return _messagesRef(tripId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Send a text message to the trip group
  Future<void> sendMessage({
    required String tripId,
    required String senderId,
    required String senderName,
    String? senderPhotoUrl,
    required String text,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    try {
      final docRef = _messagesRef(tripId).doc();
      final message = ChatMessageModel(
        id: docRef.id,
        tripId: tripId,
        senderId: senderId,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        text: cleanText,
        type: MessageType.text,
        createdAt: DateTime.now(),
      );

      await docRef.set(message.toMap());
    } catch (e) {
      throw FirestoreException('Failed to send message: $e');
    }
  }

  /// Send system notification message to chat (e.g. member joined, date changed)
  Future<void> sendSystemMessage({
    required String tripId,
    required String text,
  }) async {
    try {
      final docRef = _messagesRef(tripId).doc();
      final message = ChatMessageModel(
        id: docRef.id,
        tripId: tripId,
        senderId: 'system',
        senderName: 'System',
        text: text,
        type: MessageType.system,
        createdAt: DateTime.now(),
      );

      await docRef.set(message.toMap());
    } catch (e) {
      // Non-blocking
    }
  }
}
