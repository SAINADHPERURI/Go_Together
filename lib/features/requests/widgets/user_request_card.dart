import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/join_request_model.dart';
import '../../trips/screens/trip_details_screen.dart';

class UserRequestCard extends StatelessWidget {
  final JoinRequestModel request;
  final VoidCallback onCancel;

  const UserRequestCard({
    super.key,
    required this.request,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TripDetailsScreen(tripId: request.tripId),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  request.tripTitle.isNotEmpty ? request.tripTitle : 'Trip to ${request.tripDestination}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              AppBadge.requestStatus(request.status.name),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 15, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
              const SizedBox(width: 4),
              Text(
                request.tripDestination,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.calendar_today_outlined, size: 14, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
              const SizedBox(width: 4),
              Text(
                DateFormatter.timeAgo(request.createdAt),
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
            ],
          ),
          if (request.status == JoinRequestStatus.pending) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel_outlined, size: 16, color: AppColors.error),
                label: Text(
                  'Cancel Request',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.error),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
