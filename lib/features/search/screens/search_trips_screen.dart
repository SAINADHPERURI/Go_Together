import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../providers/trip_provider.dart';
import '../../trips/widgets/trip_card.dart';
import '../widgets/filter_modal_sheet.dart';

class SearchTripsScreen extends ConsumerStatefulWidget {
  const SearchTripsScreen({super.key});

  @override
  ConsumerState<SearchTripsScreen> createState() => _SearchTripsScreenState();
}

class _SearchTripsScreenState extends ConsumerState<SearchTripsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(tripSearchFilterProvider);
    final filterNotifier = ref.read(tripSearchFilterProvider.notifier);
    final filteredTrips = ref.watch(filteredTripsProvider);
    final tripsAsync = ref.watch(userAgeGroupTripsStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover & Search'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.tune_rounded),
                if (filters.hasActiveFilters)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Filter Trips',
            onPressed: () => FilterModalSheet.show(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: AppTextField(
              hintText: 'Search destination, city, or trip...',
              controller: _searchController,
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        filterNotifier.setSearchQuery('');
                        setState(() {});
                      },
                    )
                  : null,
              onChanged: (query) {
                filterNotifier.setSearchQuery(query);
                setState(() {});
              },
            ),
          ),

          // Active filter badges
          if (filters.hasActiveFilters)
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (filters.selectedCategory != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(filters.selectedCategory!),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => filterNotifier.setCategory(null),
                      ),
                    ),
                  if (filters.selectedCity != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(filters.selectedCity!),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => filterNotifier.setCity(null),
                      ),
                    ),
                  if (filters.selectedAgeGroup != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(filters.selectedAgeGroup!.displayName),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => filterNotifier.setAgeGroup(null),
                      ),
                    ),
                  if (filters.startDate != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: const Text('Dates Filtered'),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => filterNotifier.setDateRange(null, null),
                      ),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Results header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredTrips.length} ${filteredTrips.length == 1 ? "Trip Found" : "Trips Found"}',
                  style: AppTypography.titleSmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (filters.hasActiveFilters)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      filterNotifier.resetFilters();
                    },
                    child: Text(
                      'Clear All',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Results List
          Expanded(
            child: tripsAsync.when(
              data: (_) {
                if (filteredTrips.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No Matching Trips Found',
                    description: 'Try adjusting your destination keyword or relaxing your active search filters.',
                    actionText: 'Clear Filters',
                    onAction: () {
                      _searchController.clear();
                      filterNotifier.resetFilters();
                    },
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  itemCount: filteredTrips.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.space16),
                      child: TripCard(trip: filteredTrips[index]),
                    );
                  },
                );
              },
              loading: () => const AppLoading(message: 'Searching trips...'),
              error: (err, _) => Center(child: Text(err.toString())),
            ),
          ),
        ],
      ),
    );
  }
}
