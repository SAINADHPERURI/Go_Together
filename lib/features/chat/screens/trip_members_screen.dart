import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../models/trip_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/trip_detail_provider.dart';
import '../../moderation/screens/report_dialog.dart';
import '../../profile/screens/view_member_profile_screen.dart';

class TripMembersScreen extends ConsumerWidget {
  final TripModel trip;

  const TripMembersScreen({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(tripMembersStreamProvider(trip.id));
    final currentUser = ref.watch(currentUserProfileProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Members'),
      ),
      body: membersAsync.when(
        data: (members) {
          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.space16),
            itemCount: members.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.space8),
            itemBuilder: (context, index) {
              final member = members[index];
              final isMe = currentUser != null && member.userId == currentUser.id;

              return AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ViewMemberProfileScreen(userId: member.userId),
                    ),
                  );
                },
                child: Row(
                  children: [
                    AppAvatar(
                      imageUrl: member.photoUrl,
                      name: member.fullName,
                      size: 46,
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                isMe ? '${member.fullName} (You)' : member.fullName,
                                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                              ),
                              if (member.isHost) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                                  ),
                                  child: const Text(
                                    'Host',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${member.age} yrs • ${member.city}',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isMe && currentUser != null)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                        onSelected: (val) {
                          if (val == 'view') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ViewMemberProfileScreen(userId: member.userId),
                              ),
                            );
                          } else if (val == 'report') {
                            ReportDialog.show(
                              context,
                              reporterId: currentUser.id,
                              reportedUserId: member.userId,
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Text('View Profile'),
                          ),
                          const PopupMenuItem(
                            value: 'report',
                            child: Text('Report Member'),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const AppLoading(message: 'Loading trip members...'),
        error: (err, _) => Center(child: Text(err.toString())),
      ),
    );
  }
}
