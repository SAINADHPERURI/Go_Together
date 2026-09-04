import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/moderation_model.dart';
import '../repositories/moderation_repository.dart';
import 'auth_provider.dart';

final moderationRepositoryProvider = Provider<ModerationRepository>((ref) {
  return ModerationRepository();
});

/// Stream of blocked users for the current logged-in user
final blockedUsersStreamProvider = StreamProvider<List<BlockModel>>((ref) {
  final user = ref.watch(currentUserProfileProvider).value;
  if (user == null) return Stream.value([]);

  final modRepo = ref.watch(moderationRepositoryProvider);
  return modRepo.getBlockedUsersStream(user.id);
});
