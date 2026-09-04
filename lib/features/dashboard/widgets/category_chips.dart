import 'package:flutter/material.dart';
import '../../../core/constants/age_group.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';

class CategoryChipsList extends StatelessWidget {
  final AgeGroup ageGroup;
  final String? selectedCategory;
  final ValueChanged<String?> onSelectCategory;

  const CategoryChipsList({
    super.key,
    required this.ageGroup,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    final categories = ageGroup.recommendedCategories;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.space8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isAllSelected = selectedCategory == null;
            return ChoiceChip(
              label: const Text('All Trips'),
              selected: isAllSelected,
              onSelected: (_) => onSelectCategory(null),
              selectedColor: AppColors.primary,
              backgroundColor: isDark ? AppColors.cardDark : Colors.white,
              labelStyle: AppTypography.labelMedium.copyWith(
                color: isAllSelected
                    ? Colors.white
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                fontWeight: isAllSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                side: BorderSide(
                  color: isAllSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
                ),
              ),
            );
          }

          final category = categories[index - 1];
          final isSelected = selectedCategory == category;

          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (_) => onSelectCategory(isSelected ? null : category),
            selectedColor: AppColors.primary,
            backgroundColor: isDark ? AppColors.cardDark : Colors.white,
            labelStyle: AppTypography.labelMedium.copyWith(
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
              ),
            ),
          );
        },
      ),
    );
  }
}
