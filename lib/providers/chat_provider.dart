import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message_model.dart';
import '../repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

/// Real-time stream of messages for a trip group chat
final tripChatMessagesStreamProvider =
    StreamProvider.family<List<ChatMessageModel>, String>((ref, tripId) {
  final chatRepo = ref.watch(chatRepositoryProvider);
  return chatRepo.getMessagesStream(tripId);
});
