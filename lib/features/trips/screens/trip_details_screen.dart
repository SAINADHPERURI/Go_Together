import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../models/join_request_model.dart';
import '../../../models/trip_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/join_request_provider.dart';
import '../../../providers/trip_detail_provider.dart';
import '../../chat/screens/trip_chat_screen.dart';
import '../../moderation/screens/report_dialog.dart';
import '../../profile/screens/view_member_profile_screen.dart';
import '../widgets/join_request_bottom_sheet.dart';
import 'host_management_screen.dart';

class TripDetailsScreen extends ConsumerWidget {
  final String tripId;

  const TripDetailsScreen({
    super.key,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripDetailStreamProvider(tripId));
    final membersAsync = ref.watch(tripMembersStreamProvider(tripId));
    final currentUser = ref.watch(currentUserProfileProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return tripAsync.when(
      data: (trip) {
        if (trip == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Trip Details')),
            body: const Center(child: Text('Trip not found or has been deleted.')),
          );
        }

        final isHost = currentUser != null && currentUser.id == trip.hostId;
        final isMember = currentUser != null && trip.memberIds.contains(currentUser.id);
        final isAgeCompatible = currentUser != null && currentUser.ageGroup == trip.ageGroup;

        // User join request stream
        final userRequestAsync = currentUser != null
            ? ref.watch(userTripRequestStatusStreamProvider(trip.id))
            : const AsyncValue.data(null);
        final userRequest = userRequestAsync.value;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Hero Image App Bar
              SliverAppBar(
                expandedHeight: 260.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: trip.imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => Container(
                          color: AppColors.primary,
                          child: const Icon(Icons.terrain_rounded, size: 64, color: Colors.white),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.5),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                AppBadge.ageGroup(trip.ageGroup),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                  ),
                                  child: Text(
                                    trip.tripType,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              trip.title,
                              style: AppTypography.headlineMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.flag_outlined, color: Colors.white),
                    tooltip: 'Report Trip',
                    onPressed: () {
                      if (currentUser != null) {
                        ReportDialog.show(
                          context,
                          reporterId: currentUser.id,
                          reportedTripId: trip.id,
                        );
                      }
                    },
                  ),
                ],
              ),

              // Trip Body Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.space20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Route & Status
                      AppCard(
                        padding: const EdgeInsets.all(AppDimensions.space16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                  ),
                                  child: const Icon(Icons.flight_takeoff_rounded, color: AppColors.primary, size: 22),
                                ),
                                const SizedBox(width: AppDimensions.space12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${trip.startingLocation} ➔ ${trip.destination}',
                                        style: AppTypography.titleMedium.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${DateFormatter.formatTripDates(trip.startDate, trip.endDate)} (${DateFormatter.formatDuration(trip.startDate, trip.endDate)})',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AppBadge.tripStatus(trip.status.name),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.space16),
                            const Divider(height: 1),
                            const SizedBox(height: AppDimensions.space16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Member Capacity',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${trip.currentMemberCount} / ${trip.maxMembers} Confirmed',
                                      style: AppTypography.titleSmall.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Available Slots',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      trip.isFull ? 'Full' : '${trip.availableSlots} spots open',
                                      style: AppTypography.titleSmall.copyWith(
                                        color: trip.isFull ? AppColors.warning : AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppDimensions.space24),

                      // Host Information
                      Text(
                        'Hosted By',
                        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppDimensions.space12),

                      AppCard(
                        padding: const EdgeInsets.all(AppDimensions.space16),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ViewMemberProfileScreen(userId: trip.hostId),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            AppAvatar(
                              imageUrl: trip.hostPhotoUrl,
                              name: trip.hostName,
                              size: 52,
                            ),
                            const SizedBox(width: AppDimensions.space12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        trip.hostName,
                                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${trip.hostAge} yrs • ${trip.hostCity}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primary),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppDimensions.space24),

                      // Description & Plan
                      Text(
                        'About This Trip',
                        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppDimensions.space8),
                      Text(
                        trip.description,
                        style: AppTypography.bodyLarge.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          height: 1.6,
                        ),
                      ),

                      if (trip.meetingPointDetails != null && trip.meetingPointDetails!.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.space24),
                        Text(
                          'Meeting & Assembly Point',
                          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppDimensions.space8),
                        AppCard(
                          color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.meeting_room_rounded, color: AppColors.primary, size: 20),
                              const SizedBox(width: AppDimensions.space12),
                              Expanded(
                                child: Text(
                                  trip.meetingPointDetails!,
                                  style: AppTypography.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (trip.budgetEstimateNote != null && trip.budgetEstimateNote!.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.space20),
                        Text(
                          'Estimated Cost Note',
                          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppDimensions.space8),
                        AppCard(
                          color: isDark ? AppColors.surfaceDark : AppColors.secondaryContainer.withValues(alpha: 0.3),
                          borderColor: AppColors.secondary.withValues(alpha: 0.3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline_rounded, color: AppColors.secondary, size: 20),
                              const SizedBox(width: AppDimensions.space12),
                              Expanded(
                                child: Text(
                                  trip.budgetEstimateNote!,
                                  style: AppTypography.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: AppDimensions.space24),

                      // Confirmed Members List
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Confirmed Travelers (${trip.currentMemberCount})',
                            style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.space12),

                      membersAsync.when(
                        data: (members) {
                          if (members.isEmpty) {
                            return const Text('No members yet.');
                          }
                          return Column(
                            children: members.map((m) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppDimensions.space8),
                                child: AppCard(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ViewMemberProfileScreen(userId: m.userId),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      AppAvatar(imageUrl: m.photoUrl, name: m.fullName, size: 38),
                                      const SizedBox(width: AppDimensions.space12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              m.fullName,
                                              style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                                            ),
                                            Text(
                                              '${m.age} yrs • ${m.city}',
                                              style: AppTypography.bodySmall.copyWith(
                                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (m.isHost)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryContainer,
                                            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                                          ),
                                          child: const Text(
                                            'Host',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const AppSkeleton(width: double.infinity, height: 60),
                        error: (_, _) => const SizedBox(),
                      ),

                      const SizedBox(height: 100), // Spacing for bottom floating bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky Bottom Action Bar
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space20, vertical: AppDimensions.space16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              border: Border(
                top: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
              ),
              boxShadow: AppDimensions.shadowMd,
            ),
            child: SafeArea(
              child: _buildBottomAction(
                context,
                trip: trip,
                currentUser: currentUser,
                isHost: isHost,
                isMember: isMember,
                isAgeCompatible: isAgeCompatible,
                userRequest: userRequest,
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: AppLoading(message: 'Loading trip details...')),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(error.toString())),
      ),
    );
  }

  Widget _buildBottomAction(
    BuildContext context, {
    required TripModel trip,
    required UserModel? currentUser,
    required bool isHost,
    required bool isMember,
    required bool isAgeCompatible,
    required JoinRequestModel? userRequest,
  }) {
    if (currentUser == null) {
      return AppButton(
        text: 'Sign In to Join',
        onPressed: () => Navigator.of(context).pop(),
      );
    }

    if (isHost) {
      return AppButton(
        text: 'Manage Trip & Join Requests',
        icon: Icons.admin_panel_settings_rounded,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => HostManagementScreen(tripId: trip.id),
            ),
          );
        },
      );
    }

    if (isMember) {
      return AppButton(
        text: 'Open Trip Group Chat',
        icon: Icons.chat_bubble_rounded,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TripChatScreen(trip: trip),
            ),
          );
        },
      );
    }

    if (userRequest != null && userRequest.status == JoinRequestStatus.pending) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_top_rounded, color: AppColors.warning, size: 20),
            const SizedBox(width: 8),
            Text(
              'Join Request Pending Host Approval',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    if (!isAgeCompatible) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_person_rounded, color: AppColors.error, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Organized for ${trip.ageGroup.displayName} Community',
                textAlign: TextAlign.center,
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (trip.isFull) {
      return AppButton(
        text: 'Trip is Full (Max Capacity Reached)',
        onPressed: null,
        variant: AppButtonVariant.secondary,
      );
    }

    return AppButton(
      text: 'Request to Join Trip',
      icon: Icons.person_add_alt_1_rounded,
      onPressed: () {
        JoinRequestBottomSheet.show(
          context,
          trip: trip,
          currentUser: currentUser,
        );
      },
    );
  }
}
