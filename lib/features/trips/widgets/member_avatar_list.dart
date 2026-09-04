import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../models/trip_member_model.dart';

class MemberAvatarList extends StatelessWidget {
  final List<TripMemberModel> members;
  final int maxMembers;
  final double avatarSize;

  const MemberAvatarList({
    super.key,
    required this.members,
    required this.maxMembers,
    this.avatarSize = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    final displayMembers = members.take(4).toList();
    final remainingCount = (members.length > 4) ? (members.length - 4) : 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: avatarSize,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayMembers.length,
            itemBuilder: (context, index) {
              final member = displayMembers[index];
              return Align(
                widthFactor: 0.75,
                child: AppAvatar(
                  imageUrl: member.photoUrl,
                  name: member.fullName,
                  size: avatarSize,
                ),
              );
            },
          ),
        ),
        if (remainingCount > 0) ...[
          const SizedBox(width: AppDimensions.space6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: Text(
              '+$remainingCount',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
