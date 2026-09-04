import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/dialogs.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../models/join_request_model.dart';
import '../../../models/trip_member_model.dart';
import '../../../models/trip_model.dart';
import '../../../providers/join_request_provider.dart';
import '../../../providers/trip_detail_provider.dart';
import '../../../providers/trip_provider.dart';
import '../../profile/screens/view_member_profile_screen.dart';
import 'edit_trip_screen.dart';

class HostManagementScreen extends ConsumerStatefulWidget {
  final String tripId;

  const HostManagementScreen({
    super.key,
    required this.tripId,
  });

  @override
  ConsumerState<HostManagementScreen> createState() => _HostManagementScreenState();
}

class _HostManagementScreenState extends ConsumerState<HostManagementScreen> {
  bool _isProcessing = false;

  Future<void> _handleAccept(JoinRequestModel request) async {
    setState(() => _isProcessing = true);
    try {
      final reqRepo = ref.read(joinRequestRepositoryProvider);
      await reqRepo.acceptJoinRequest(request: request);
      if (mounted) {
        AppDialogs.showSnackBar(
          context,
          message: '${request.userName} was accepted into the trip!',
          isSuccess: true,
        );
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showSnackBar(context, message: e.toString(), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleReject(JoinRequestModel request) async {
    final confirm = await AppDialogs.showConfirmDialog(
      context,
      title: 'Reject Request?',
      message: 'Are you sure you want to decline ${request.userName}\'s request to join?',
      confirmLabel: 'Decline',
      isDestructive: true,
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);
    try {
      final reqRepo = ref.read(joinRequestRepositoryProvider);
      await reqRepo.rejectJoinRequest(request: request);
      if (mounted) {
        AppDialogs.showSnackBar(
          context,
          message: 'Join request was declined.',
        );
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showSnackBar(context, message: e.toString(), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleRemoveMember(TripMemberModel member, TripModel trip) async {
    final confirm = await AppDialogs.showConfirmDialog(
      context,
      title: 'Remove Member?',
      message: 'Remove ${member.fullName} from this trip group? They will no longer have access to the group chat.',
      confirmLabel: 'Remove Member',
      isDestructive: true,
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);
    try {
      final tripRepo = ref.read(tripRepositoryProvider);
      await tripRepo.removeMember(tripId: trip.id, memberUserId: member.userId);
      if (mounted) {
        AppDialogs.showSnackBar(
          context,
          message: '${member.fullName} was removed from the trip.',
        );
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showSnackBar(context, message: e.toString(), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleCancelTrip(TripModel trip) async {
    final confirm = await AppDialogs.showConfirmDialog(
      context,
      title: 'Cancel Entire Trip?',
      message: 'Are you sure you want to cancel this trip? All members will be notified.',
      confirmLabel: 'Cancel Trip',
      isDestructive: true,
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);
    try {
      final tripRepo = ref.read(tripRepositoryProvider);
      await tripRepo.updateTripStatus(trip.id, TripStatus.cancelled);
      if (mounted) {
        AppDialogs.showSnackBar(context, message: 'Trip has been marked as cancelled.');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showSnackBar(context, message: e.toString(), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(tripDetailStreamProvider(widget.tripId));
    final membersAsync = ref.watch(tripMembersStreamProvider(widget.tripId));
    final incomingRequestsAsync = ref.watch(hostIncomingRequestsStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return tripAsync.when(
      data: (trip) {
        if (trip == null) {
          return const Scaffold(body: Center(child: Text('Trip not found')));
        }

        // Filter incoming requests specific to this trip
        final tripPendingRequests = incomingRequestsAsync.value
                ?.where((r) => r.tripId == trip.id && r.status == JoinRequestStatus.pending)
                .toList() ??
            [];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Host Management'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Trip',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditTripScreen(trip: trip),
                    ),
                  );
                },
              ),
            ],
          ),
          body: _isProcessing
              ? const AppLoading(message: 'Updating trip...')
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Trip Summary Card
                      AppCard(
                        padding: const EdgeInsets.all(AppDimensions.space16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                AppBadge.ageGroup(trip.ageGroup),
                                const SizedBox(width: 8),
                                AppBadge.tripStatus(trip.status.name),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              trip.title,
                              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${trip.startingLocation} ➔ ${trip.destination} • ${DateFormatter.formatTripDates(trip.startDate, trip.endDate)}',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${trip.currentMemberCount} of ${trip.maxMembers} spots confirmed (${trip.availableSlots} available)',
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppDimensions.space24),

                      // Section 1: Pending Join Requests
                      Row(
                        children: [
                          Text(
                            'Pending Join Requests',
                            style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 8),
                          if (tripPendingRequests.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                              ),
                              child: Text(
                                '${tripPendingRequests.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.space12),

                      if (tripPendingRequests.isEmpty)
                        AppCard(
                          padding: const EdgeInsets.all(AppDimensions.space20),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.mark_email_read_outlined, size: 36, color: AppColors.primary),
                                const SizedBox(height: 8),
                                Text(
                                  'No pending requests for this trip',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...tripPendingRequests.map((req) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppDimensions.space12),
                            child: AppCard(
                              padding: const EdgeInsets.all(AppDimensions.space16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ViewMemberProfileScreen(userId: req.userId),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        AppAvatar(imageUrl: req.userPhotoUrl, name: req.userName, size: 44),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    req.userName,
                                                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  AppBadge.ageGroup(req.userAgeGroup),
                                                ],
                                              ),
                                              Text(
                                                '${req.userAge} yrs • ${req.userCity}',
                                                style: AppTypography.bodySmall.copyWith(
                                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
                                      ],
                                    ),
                                  ),
                                  if (req.message.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                      ),
                                      child: Text(
                                        '"${req.message}"',
                                        style: AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppButton(
                                          text: 'Decline',
                                          variant: AppButtonVariant.outline,
                                          height: 40,
                                          onPressed: () => _handleReject(req),
                                        ),
                                      ),
                                      const SizedBox(width: AppDimensions.space12),
                                      Expanded(
                                        child: AppButton(
                                          text: 'Accept',
                                          height: 40,
                                          onPressed: () => _handleAccept(req),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                      const SizedBox(height: AppDimensions.space24),

                      // Section 2: Confirmed Members Management
                      Text(
                        'Confirmed Group Members',
                        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppDimensions.space12),

                      membersAsync.when(
                        data: (members) {
                          return Column(
                            children: members.map((m) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppDimensions.space8),
                                child: AppCard(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  child: Row(
                                    children: [
                                      AppAvatar(imageUrl: m.photoUrl, name: m.fullName, size: 40),
                                      const SizedBox(width: 12),
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
                                        )
                                      else
                                        IconButton(
                                          icon: const Icon(Icons.person_remove_outlined, color: AppColors.error, size: 20),
                                          tooltip: 'Remove Member',
                                          onPressed: () => _handleRemoveMember(m, trip),
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

                      const SizedBox(height: AppDimensions.space32),

                      // Section 3: Danger Zone Actions
                      Text(
                        'Trip Actions',
                        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppDimensions.space12),

                      AppButton(
                        text: 'Edit Trip Details',
                        variant: AppButtonVariant.outline,
                        icon: Icons.edit_note_rounded,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EditTripScreen(trip: trip),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: AppDimensions.space12),

                      if (trip.status != TripStatus.cancelled)
                        AppButton(
                          text: 'Cancel Trip',
                          variant: AppButtonVariant.destructive,
                          icon: Icons.cancel_outlined,
                          onPressed: () => _handleCancelTrip(trip),
                        ),

                      const SizedBox(height: AppDimensions.space40),
                    ],
                  ),
                ),
        );
      },
      loading: () => const Scaffold(body: AppLoading(message: 'Loading host management...')),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
    );
  }
}
