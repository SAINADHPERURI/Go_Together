import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/trip_provider.dart';
import '../../settings/screens/settings_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);
    final joinedTripsAsync = ref.watch(joinedTripsStreamProvider);
    final hostedTripsAsync = ref.watch(hostedTripsStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Traveler Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const AppLoading(message: 'Loading profile...');
          }

          final joinedCount = joinedTripsAsync.value?.length ?? 0;
          final hostedCount = hostedTripsAsync.value?.length ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space20, vertical: AppDimensions.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                AppCard(
                  padding: const EdgeInsets.all(AppDimensions.space20),
                  child: Column(
                    children: [
                      Center(
                        child: AppAvatar(
                          imageUrl: user.photoUrl,
                          name: user.fullName,
                          size: 80,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      Text(
                        user.fullName,
                        style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user.age} years old • ${user.city}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppBadge.ageGroup(user.ageGroup),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                '$joinedCount',
                                style: AppTypography.titleLarge.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Trips Joined',
                                style: AppTypography.labelSmall.copyWith(
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 30,
                            width: 1,
                            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                          ),
                          Column(
                            children: [
                              Text(
                                '$hostedCount',
                                style: AppTypography.titleLarge.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Trips Hosted',
                                style: AppTypography.labelSmall.copyWith(
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.space20),

                // Edit Profile Quick Button
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(user: user),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit Profile & Preferences'),
                ),

                const SizedBox(height: AppDimensions.space24),

                // Bio
                if (user.bio.isNotEmpty) ...[
                  Text(
                    'About Me',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  AppCard(
                    padding: const EdgeInsets.all(AppDimensions.space16),
                    child: Text(
                      user.bio,
                      style: AppTypography.bodyMedium.copyWith(height: 1.5),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space20),
                ],

                // Preferred Languages
                if (user.preferredLanguages.isNotEmpty) ...[
                  Text(
                    'Languages',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.preferredLanguages.map((lang) {
                      return Chip(
                        label: Text(lang),
                        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppDimensions.space20),
                ],

                // Travel Interests
                if (user.travelInterests.isNotEmpty) ...[
                  Text(
                    'Travel Interests',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.travelInterests.map((interest) {
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

                // Date of Birth & Age Group Policy Information
                AppCard(
                  color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 22),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DOB: ${DateFormatter.formatDob(user.dateOfBirth)}',
                              style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Age group is calculated securely and cannot be altered arbitrarily to protect community compatibility.',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.space40),
              ],
            ),
          );
        },
        loading: () => const AppLoading(message: 'Loading your profile...'),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
