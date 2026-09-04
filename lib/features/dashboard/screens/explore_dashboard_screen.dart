import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/trip_provider.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../search/screens/search_trips_screen.dart';
import '../../trips/screens/create_trip_screen.dart';
import '../../trips/widgets/trip_card.dart';
import '../widgets/age_group_banner.dart';
import '../widgets/category_chips.dart';

class ExploreDashboardScreen extends ConsumerStatefulWidget {
  const ExploreDashboardScreen({super.key});

  @override
  ConsumerState<ExploreDashboardScreen> createState() => _ExploreDashboardScreenState();
}

class _ExploreDashboardScreenState extends ConsumerState<ExploreDashboardScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProfileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unreadNotifCount = ref.watch(unreadNotificationCountProvider).value ?? 0;

    return Scaffold(
      body: SafeArea(
        child: userAsync.when(
          data: (user) {
            if (user == null) {
              return const AppLoading(message: 'Loading your profile...');
            }

            final tripsAsync = ref.watch(userAgeGroupTripsStreamProvider);

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(userAgeGroupTripsStreamProvider);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // App Bar Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.space16,
                        AppDimensions.space16,
                        AppDimensions.space16,
                        AppDimensions.space8,
                      ),
                      child: Row(
                        children: [
                          AppAvatar(
                            imageUrl: user.photoUrl,
                            name: user.fullName,
                            size: 44,
                          ),
                          const SizedBox(width: AppDimensions.space12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, ${user.fullName.split(' ').first}! 👋',
                                  style: AppTypography.titleLarge.copyWith(
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Explore ${user.ageGroup.displayName} travel community',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Notifications Bell with Badge
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_none_rounded, size: 26),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                                  );
                                },
                              ),
                              if (unreadNotifCount > 0)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      '$unreadNotifCount',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Age Group Banner
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space16,
                        vertical: AppDimensions.space8,
                      ),
                      child: AgeGroupBanner(user: user),
                    ),
                  ),

                  // Search Quick Bar Trigger
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space16,
                        vertical: AppDimensions.space8,
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SearchTripsScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                            border: Border.all(
                              color: isDark ? AppColors.dividerDark : AppColors.borderLight,
                            ),
                            boxShadow: isDark ? [] : AppDimensions.shadowSm,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                              const SizedBox(width: AppDimensions.space12),
                              Expanded(
                                child: Text(
                                  'Search destination, city, or trip type...',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                                ),
                                child: const Icon(
                                  Icons.tune_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Category Filters
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppDimensions.space12),
                      child: CategoryChipsList(
                        ageGroup: user.ageGroup,
                        selectedCategory: _selectedCategory,
                        onSelectCategory: (category) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ),
                    ),
                  ),

                  // Section Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.space16,
                        AppDimensions.space8,
                        AppDimensions.space16,
                        AppDimensions.space8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedCategory == null
                                ? 'Trips For Your Community'
                                : '$_selectedCategory Trips',
                            style: AppTypography.titleLarge.copyWith(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SearchTripsScreen()),
                              );
                            },
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Trips List Stream
                  tripsAsync.when(
                    data: (trips) {
                      final filteredList = _selectedCategory == null
                          ? trips
                          : trips
                              .where((t) =>
                                  t.tripType.toLowerCase() == _selectedCategory!.toLowerCase())
                              .toList();

                      if (filteredList.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: AppEmptyState(
                            icon: Icons.travel_explore_rounded,
                            title: 'No Active Trips Yet',
                            description:
                                'Be the first in the ${user.ageGroup.displayName} community to host a memorable journey!',
                            actionText: 'Host a Trip',
                            onAction: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CreateTripScreen(),
                                ),
                              );
                            },
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimensions.space16,
                          AppDimensions.space4,
                          AppDimensions.space16,
                          AppDimensions.space32,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final trip = filteredList[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppDimensions.space16),
                                child: TripCard(trip: trip),
                              );
                            },
                            childCount: filteredList.length,
                          ),
                        ),
                      );
                    },
                    loading: () => SliverPadding(
                      padding: const EdgeInsets.all(AppDimensions.space16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: AppDimensions.space16),
                            child: AppSkeleton(
                              width: double.infinity,
                              height: 280,
                              borderRadius: AppDimensions.radiusLg,
                            ),
                          ),
                          childCount: 3,
                        ),
                      ),
                    ),
                    error: (error, stack) => SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppErrorState(
                        message: error.toString(),
                        onRetry: () => ref.invalidate(userAgeGroupTripsStreamProvider),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const AppLoading(message: 'Preparing your travel feed...'),
          error: (error, stack) => AppErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(currentUserProfileProvider),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateTripScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Host Trip', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
