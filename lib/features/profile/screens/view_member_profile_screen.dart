import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/dialogs.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../models/moderation_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/moderation_provider.dart';
import '../../moderation/screens/report_dialog.dart';

class ViewMemberProfileScreen extends ConsumerWidget {
  final String userId;

  const ViewMemberProfileScreen({
    super.key,
    required this.userId,
  });

  Future<void> _handleBlock(BuildContext context, WidgetRef ref, UserModel member, UserModel currentUser) async {
    final confirm = await AppDialogs.showConfirmDialog(
      context,
      title: 'Block ${member.fullName}?',
      message: 'You will no longer see trips or messages from this traveler.',
      confirmLabel: 'Block User',
      isDestructive: true,
    );

    if (confirm != true) return;

    try {
      final modRepo = ref.read(moderationRepositoryProvider);
      await modRepo.blockUser(
        BlockModel(
          id: '',
          userId: currentUser.id,
          blockedUserId: member.id,
          blockedUserName: member.fullName,
          createdAt: DateTime.now(),
        ),
      );
      if (context.mounted) {
        AppDialogs.showSnackBar(context, message: '${member.fullName} has been blocked.');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        AppDialogs.showSnackBar(context, message: e.toString(), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRepo = ref.watch(userRepositoryProvider);
    final currentUser = ref.watch(currentUserProfileProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<UserModel?>(
      future: userRepo.getUserProfile(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: AppLoading(message: 'Loading traveler profile...'));
        }

        final member = snapshot.data;
        if (member == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Traveler Profile')),
            body: const Center(child: Text('User profile not found.')),
          );
        }

        final isMe = currentUser != null && currentUser.id == member.id;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Traveler Profile'),
            actions: [
              if (!isMe && currentUser != null)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (action) {
                    if (action == 'report') {
                      ReportDialog.show(
                        context,
                        reporterId: currentUser.id,
                        reportedUserId: member.id,
                      );
                    } else if (action == 'block') {
                      _handleBlock(context, ref, member, currentUser);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag_outlined, size: 18, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Report Traveler', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'block',
                      child: Row(
                        children: [
                          Icon(Icons.block_rounded, size: 18, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Block Traveler', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space20, vertical: AppDimensions.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Avatar & Identity
                AppCard(
                  padding: const EdgeInsets.all(AppDimensions.space20),
                  child: Column(
                    children: [
                      Center(
                        child: AppAvatar(
                          imageUrl: member.photoUrl,
                          name: member.fullName,
                          size: 80,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      Text(
                        member.fullName,
                        style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${member.age} years old • ${member.city}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppBadge.ageGroup(member.ageGroup),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.space20),

                // Bio
                if (member.bio.isNotEmpty) ...[
                  Text(
                    'About Traveler',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  AppCard(
                    padding: const EdgeInsets.all(AppDimensions.space16),
                    child: Text(
                      member.bio,
                      style: AppTypography.bodyMedium.copyWith(height: 1.5),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space20),
                ],

                // Preferred Languages
                if (member.preferredLanguages.isNotEmpty) ...[
                  Text(
                    'Languages Spoken',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: member.preferredLanguages.map((lang) {
                      return Chip(label: Text(lang));
                    }).toList(),
                  ),
                  const SizedBox(height: AppDimensions.space20),
                ],

                // Travel Interests
                if (member.travelInterests.isNotEmpty) ...[
                  Text(
                    'Travel Interests',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: member.travelInterests.map((interest) {
                      return Chip(
                        label: Text(interest),
                        backgroundColor: AppColors.secondaryContainer.withValues(alpha: 0.5),
                        labelStyle: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppDimensions.space20),
                ],

                // Privacy Notice Box
                AppCard(
                  color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  child: Row(
                    children: [
                      const Icon(Icons.privacy_tip_outlined, color: AppColors.primary, size: 22),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: Text(
                          'GoTogether respects privacy: Private contact details are never shared automatically. Travelers may coordinate directly inside accepted trip group chats.',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
