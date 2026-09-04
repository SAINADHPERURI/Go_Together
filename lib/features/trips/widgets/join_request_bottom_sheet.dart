import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/dialogs.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/join_request_model.dart';
import '../../../models/trip_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/join_request_provider.dart';

class JoinRequestBottomSheet extends ConsumerStatefulWidget {
  final TripModel trip;
  final UserModel currentUser;

  const JoinRequestBottomSheet({
    super.key,
    required this.trip,
    required this.currentUser,
  });

  static Future<bool?> show(
    BuildContext context, {
    required TripModel trip,
    required UserModel currentUser,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JoinRequestBottomSheet(
        trip: trip,
        currentUser: currentUser,
      ),
    );
  }

  @override
  ConsumerState<JoinRequestBottomSheet> createState() => _JoinRequestBottomSheetState();
}

class _JoinRequestBottomSheetState extends ConsumerState<JoinRequestBottomSheet> {
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    setState(() => _isLoading = true);

    try {
      final reqRepo = ref.read(joinRequestRepositoryProvider);
      final request = JoinRequestModel(
        id: '',
        tripId: widget.trip.id,
        tripTitle: widget.trip.title,
        tripDestination: widget.trip.destination,
        tripStartDate: widget.trip.startDate,
        userId: widget.currentUser.id,
        userName: widget.currentUser.fullName,
        userPhotoUrl: widget.currentUser.photoUrl,
        userAge: widget.currentUser.age,
        userAgeGroup: widget.currentUser.ageGroup,
        userCity: widget.currentUser.city,
        message: _messageController.text.trim().isEmpty
            ? "Hi! I'd love to join this trip."
            : _messageController.text.trim(),
        hostId: widget.trip.hostId,
        createdAt: DateTime.now(),
      );

      await reqRepo.submitJoinRequest(
        request: request,
        trip: widget.trip,
        requester: widget.currentUser,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showSnackBar(
          context,
          message: e.toString(),
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: AppDimensions.space20,
        right: AppDimensions.space20,
        top: AppDimensions.space20,
        bottom: bottomInset + AppDimensions.space24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusXl),
          topRight: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // Title
          Row(
            children: [
              Text(
                'Request to Join',
                style: AppTypography.titleLarge.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              AppBadge.ageGroup(widget.trip.ageGroup),
            ],
          ),

          const SizedBox(height: AppDimensions.space8),

          Text(
            'You are requesting to join ${widget.trip.hostName}\'s group to ${widget.trip.destination}. The host will review your request and profile.',
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),

          const SizedBox(height: AppDimensions.space20),

          // Message for host
          AppTextField(
            label: 'Message for the Host (Optional)',
            hintText: 'Introduce yourself, travel preferences, or why you want to join...',
            controller: _messageController,
            maxLines: 3,
            maxLength: 300,
          ),

          const SizedBox(height: AppDimensions.space20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Cancel',
                  variant: AppButtonVariant.outline,
                  onPressed: () => Navigator.of(context).pop(),
                  height: 48,
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                flex: 2,
                child: AppButton(
                  text: 'Send Request',
                  onPressed: _submitRequest,
                  isLoading: _isLoading,
                  icon: Icons.send_rounded,
                  height: 48,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
