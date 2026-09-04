import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/age_group.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../providers/trip_provider.dart';

class FilterModalSheet extends ConsumerStatefulWidget {
  const FilterModalSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FilterModalSheet(),
    );
  }

  @override
  ConsumerState<FilterModalSheet> createState() => _FilterModalSheetState();
}

class _FilterModalSheetState extends ConsumerState<FilterModalSheet> {
  String? _selectedCategory;
  String? _selectedCity;
  AgeGroup? _selectedAgeGroup;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final currentFilters = ref.read(tripSearchFilterProvider);
    _selectedCategory = currentFilters.selectedCategory;
    _selectedCity = currentFilters.selectedCity;
    _selectedAgeGroup = currentFilters.selectedAgeGroup;
    _startDate = currentFilters.startDate;
    _endDate = currentFilters.endDate;
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _applyFilters() {
    final notifier = ref.read(tripSearchFilterProvider.notifier);
    notifier.setCategory(_selectedCategory);
    notifier.setCity(_selectedCity);
    notifier.setAgeGroup(_selectedAgeGroup);
    notifier.setDateRange(_startDate, _endDate);
    Navigator.of(context).pop();
  }

  void _resetFilters() {
    ref.read(tripSearchFilterProvider.notifier).resetFilters();
    setState(() {
      _selectedCategory = null;
      _selectedCity = null;
      _selectedAgeGroup = null;
      _startDate = null;
      _endDate = null;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space20, vertical: AppDimensions.space20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusXl),
          topRight: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Trips',
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: const Text('Reset All'),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.space12),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Age Group Filter
                  Text(
                    'Age Group Community',
                    style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AgeGroup.values.map((group) {
                      final isSelected = _selectedAgeGroup == group;
                      return ChoiceChip(
                        label: Text('${group.displayName} (${group.personaTitle.split(' ').first})'),
                        selected: isSelected,
                        selectedColor: group.accentColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textPrimaryLight),
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedAgeGroup = selected ? group : null;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppDimensions.space20),

                  // Trip Type / Category
                  Text(
                    'Trip Category',
                    style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.tripTypes.map((type) {
                      final isSelected = _selectedCategory == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textPrimaryLight),
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? type : null;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppDimensions.space20),

                  // Starting City Filter
                  Text(
                    'Starting Origin City',
                    style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.majorCities.map((city) {
                      final isSelected = _selectedCity == city;
                      return ChoiceChip(
                        label: Text(city),
                        selected: isSelected,
                        selectedColor: AppColors.secondary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textPrimaryLight),
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCity = selected ? city : null;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppDimensions.space20),

                  // Travel Dates
                  Text(
                    'Departure Date Range',
                    style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDateRange,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined, size: 20, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _startDate != null && _endDate != null
                                  ? DateFormatter.formatTripDates(_startDate!, _endDate!)
                                  : 'Any travel dates',
                              style: AppTypography.bodyMedium,
                            ),
                          ),
                          if (_startDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                setState(() {
                                  _startDate = null;
                                  _endDate = null;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.space24),
                ],
              ),
            ),
          ),

          // Apply Button
          AppButton(
            text: 'Apply Filters',
            onPressed: _applyFilters,
          ),
        ],
      ),
    );
  }
}
