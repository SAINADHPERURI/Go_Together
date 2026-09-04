import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/join_request_model.dart';
import '../../profile/screens/view_member_profile_screen.dart';

class HostRequestCard extends StatelessWidget {
  final JoinRequestModel request;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final bool isProcessing;

  const HostRequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onReject,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip Destination Tag & Age Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Text(
                  'Trip to ${request.tripDestination}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AppBadge.requestStatus(request.status.name),
            ],
          ),

          const SizedBox(height: 12),

          // Requester Info (Tap to view profile)
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ViewMemberProfileScreen(userId: request.userId),
                ),
              );
            },
            child: Row(
              children: [
                AppAvatar(
                  imageUrl: request.userPhotoUrl,
                  name: request.userName,
                  size: 46,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            request.userName,
                            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 6),
                          AppBadge.ageGroup(request.userAgeGroup),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${request.userAge} yrs • ${request.userCity}',
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

          if (request.message.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Text(
                '"${request.message}"',
                style: AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ],

          if (request.status == JoinRequestStatus.pending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Decline',
                    variant: AppButtonVariant.outline,
                    height: 40,
                    onPressed: isProcessing ? null : onReject,
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: AppButton(
                    text: 'Accept',
                    height: 40,
                    isLoading: isProcessing,
                    onPressed: onAccept,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
