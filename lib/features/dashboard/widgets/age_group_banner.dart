import 'package:flutter/material.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/user_model.dart';

class AgeGroupBanner extends StatelessWidget {
  final UserModel user;

  const AgeGroupBanner({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final ageGroup = user.ageGroup;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16, vertical: AppDimensions.space16),
      decoration: BoxDecoration(
        color: ageGroup.accentColor.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: ageGroup.accentColor.withValues(alpha: isDark ? 0.35 : 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: ageGroup.accentColor.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              ageGroup.icon,
              color: ageGroup.accentColor,
              size: 26,
            ),
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      ageGroup.displayName,
                      style: AppTypography.titleMedium.copyWith(
                        color: ageGroup.accentColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: ageGroup.accentColor,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: Text(
                        ageGroup.personaTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  ageGroup.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
