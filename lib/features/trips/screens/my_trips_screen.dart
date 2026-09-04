import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../providers/trip_provider.dart';
import '../widgets/trip_card.dart';
import 'create_trip_screen.dart';

class MyTripsScreen extends ConsumerStatefulWidget {
  const MyTripsScreen({super.key});

  @override
  ConsumerState<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends ConsumerState<MyTripsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final joinedTripsAsync = ref.watch(joinedTripsStreamProvider);
    final hostedTripsAsync = ref.watch(hostedTripsStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journeys'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: isDark ? AppColors.textPrimaryDark : AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
          tabs: const [
            Tab(text: 'Joined Trips'),
            Tab(text: 'Hosted by Me'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Joined Trips
          joinedTripsAsync.when(
            data: (trips) {
              if (trips.isEmpty) {
                return AppEmptyState(
                  icon: Icons.flight_takeoff_rounded,
                  title: 'No Joined Trips Yet',
                  description: 'Discover trips in your community and send join requests to travel together!',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.space16),
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.space16),
                    child: TripCard(trip: trips[index]),
                  );
                },
              );
            },
            loading: () => const AppLoading(message: 'Loading joined trips...'),
            error: (e, _) => AppErrorState(message: e.toString()),
          ),

          // Tab 2: Hosted Trips
          hostedTripsAsync.when(
            data: (trips) {
              if (trips.isEmpty) {
                return AppEmptyState(
                  icon: Icons.add_location_alt_rounded,
                  title: 'You Haven\'t Hosted a Trip Yet',
                  description: 'Create a trip, choose your destination, and let compatible travelers join you!',
                  actionText: 'Host a Trip',
                  onAction: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CreateTripScreen()),
                    );
                  },
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.space16),
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.space16),
                    child: TripCard(trip: trips[index]),
                  );
                },
              );
            },
            loading: () => const AppLoading(message: 'Loading hosted trips...'),
            error: (e, _) => AppErrorState(message: e.toString()),
          ),
        ],
      ),
    );
  }
}
