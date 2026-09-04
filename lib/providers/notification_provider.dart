import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';
import 'auth_provider.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

/// Stream user notifications
final userNotificationsStreamProvider =
    StreamProvider<List<AppNotificationModel>>((ref) {
  final user = ref.watch(currentUserProfileProvider).value;
  if (user == null) return Stream.value([]);

  final notifRepo = ref.watch(notificationRepositoryProvider);
  return notifRepo.getUserNotificationsStream(user.id);
});

/// Stream unread notification count
final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final user = ref.watch(currentUserProfileProvider).value;
  if (user == null) return Stream.value(0);

  final notifRepo = ref.watch(notificationRepositoryProvider);
  return notifRepo.getUnreadCountStream(user.id);
});
