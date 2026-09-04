import 'package:flutter/material.dart';
import '../constants/age_group.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_typography.dart';

class AppBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? fontSize;
  final EdgeInsetsGeometry padding;

  const AppBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.fontSize,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });

  /// Factory for Age Group pill
  factory AppBadge.ageGroup(AgeGroup group) {
    return AppBadge(
      label: group.displayName,
      backgroundColor: group.accentColor.withValues(alpha: 0.12),
      textColor: group.accentColor,
      icon: group.icon,
    );
  }

  /// Factory for Trip Status pill
  factory AppBadge.tripStatus(String status) {
    Color bg;
    Color fg;
    IconData ic;

    switch (status.toLowerCase()) {
      case 'open':
        bg = AppColors.success.withValues(alpha: 0.15);
        fg = AppColors.success;
        ic = Icons.check_circle_outline_rounded;
        break;
      case 'full':
        bg = AppColors.warning.withValues(alpha: 0.15);
        fg = AppColors.warning;
        ic = Icons.people_alt_outlined;
        break;
      case 'closed':
      case 'completed':
        bg = AppColors.primary.withValues(alpha: 0.12);
        fg = AppColors.primary;
        ic = Icons.task_alt_rounded;
        break;
      case 'cancelled':
        bg = AppColors.error.withValues(alpha: 0.15);
        fg = AppColors.error;
        ic = Icons.cancel_outlined;
        break;
      default:
        bg = AppColors.borderLight;
        fg = AppColors.textSecondaryLight;
        ic = Icons.info_outline_rounded;
    }

    return AppBadge(
      label: status.toUpperCase(),
      backgroundColor: bg,
      textColor: fg,
      icon: ic,
    );
  }

  /// Factory for Join Request Status
  factory AppBadge.requestStatus(String status) {
    Color bg;
    Color fg;
    IconData ic;

    switch (status.toLowerCase()) {
      case 'pending':
        bg = AppColors.warning.withValues(alpha: 0.15);
        fg = AppColors.warning;
        ic = Icons.hourglass_top_rounded;
        break;
      case 'accepted':
        bg = AppColors.success.withValues(alpha: 0.15);
        fg = AppColors.success;
        ic = Icons.verified_rounded;
        break;
      case 'rejected':
        bg = AppColors.error.withValues(alpha: 0.15);
        fg = AppColors.error;
        ic = Icons.block_rounded;
        break;
      default:
        bg = AppColors.borderLight;
        fg = AppColors.textSecondaryLight;
        ic = Icons.help_outline_rounded;
    }

    return AppBadge(
      label: status[0].toUpperCase() + status.substring(1),
      backgroundColor: bg,
      textColor: fg,
      icon: ic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primaryContainer;
    final fg = textColor ?? AppColors.primary;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: fontSize ?? 11,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
