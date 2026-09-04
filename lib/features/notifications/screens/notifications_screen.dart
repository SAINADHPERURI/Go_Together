import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../models/notification_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../trips/screens/trip_details_screen.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.joinRequest:
        return Icons.person_add_rounded;
      case NotificationType.requestAccepted:
        return Icons.verified_rounded;
      case NotificationType.requestRejected:
        return Icons.cancel_rounded;
      case NotificationType.newGroupMessage:
        return Icons.chat_bubble_rounded;
      case NotificationType.tripUpdate:
        return Icons.info_rounded;
      case NotificationType.tripCancelled:
        return Icons.event_busy_rounded;
      case NotificationType.tripMatch:
        return Icons.explore_rounded;
    }
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.requestAccepted:
      case NotificationType.tripMatch:
        return AppColors.success;
      case NotificationType.joinRequest:
        return AppColors.primary;
      case NotificationType.requestRejected:
      case NotificationType.tripCancelled:
        return AppColors.error;
      case NotificationType.newGroupMessage:
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(userNotificationsStreamProvider);
    final user = ref.watch(currentUserProfileProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (user != null)
            TextButton(
              onPressed: () {
                ref.read(notificationRepositoryProvider).markAllAsRead(user.id);
              },
              child: const Text('Mark all as read'),
            ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return AppEmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No Notifications Yet',
              description: 'You\'re all caught up! You\'ll receive updates for trip requests and group activity here.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.space16),
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.space8),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final color = _getColorForType(notif.type);
              final icon = _getIconForType(notif.type);

              return AppCard(
                color: notif.isRead
                    ? (isDark ? AppColors.cardDark : Colors.white)
                    : (isDark ? AppColors.surfaceDark : AppColors.primaryContainer.withValues(alpha: 0.35)),
                borderColor: notif.isRead
                    ? (isDark ? AppColors.dividerDark : AppColors.dividerLight)
                    : AppColors.primary.withValues(alpha: 0.4),
                padding: const EdgeInsets.all(14),
                onTap: () {
                  if (!notif.isRead) {
                    ref.read(notificationRepositoryProvider).markAsRead(notif.id);
                  }
                  if (notif.tripId != null && notif.tripId!.isNotEmpty) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TripDetailsScreen(tripId: notif.tripId!),
                      ),
                    );
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  notif.title,
                                  style: AppTypography.titleSmall.copyWith(
                                    fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                                  ),
                                ),
                              ),
                              Text(
                                DateFormatter.timeAgo(notif.createdAt),
                                style: AppTypography.bodySmall.copyWith(
                                  fontSize: 10,
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notif.body,
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!notif.isRead) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
        loading: () => const AppLoading(message: 'Loading notifications...'),
        error: (e, _) => AppErrorState(message: e.toString()),
      ),
    );
  }
}
