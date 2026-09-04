import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/age_group.dart';
import '../models/trip_model.dart';
import '../repositories/trip_repository.dart';
import 'auth_provider.dart';

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepository();
});

/// Trips stream tailored to the logged-in user's age group
final userAgeGroupTripsStreamProvider = StreamProvider<List<TripModel>>((ref) {
  final user = ref.watch(currentUserProfileProvider).value;
  if (user == null) return Stream.value([]);

  final tripRepo = ref.watch(tripRepositoryProvider);
  return tripRepo.getTripsForAgeGroupStream(user.ageGroup);
});

/// Trips hosted by current user
final hostedTripsStreamProvider = StreamProvider<List<TripModel>>((ref) {
  final user = ref.watch(currentUserProfileProvider).value;
  if (user == null) return Stream.value([]);

  final tripRepo = ref.watch(tripRepositoryProvider);
  return tripRepo.getHostedTripsStream(user.id);
});

/// Trips where current user is an accepted member
final joinedTripsStreamProvider = StreamProvider<List<TripModel>>((ref) {
  final user = ref.watch(currentUserProfileProvider).value;
  if (user == null) return Stream.value([]);

  final tripRepo = ref.watch(tripRepositoryProvider);
  return tripRepo.getJoinedTripsStream(user.id);
});

/// Dynamic Search & Filter State
class TripSearchFilterState {
  final String searchQuery;
  final String? selectedCategory;
  final String? selectedCity;
  final AgeGroup? selectedAgeGroup;
  final DateTime? startDate;
  final DateTime? endDate;

  const TripSearchFilterState({
    this.searchQuery = '',
    this.selectedCategory,
    this.selectedCity,
    this.selectedAgeGroup,
    this.startDate,
    this.endDate,
  });

  TripSearchFilterState copyWith({
    String? searchQuery,
    String? selectedCategory,
    String? selectedCity,
    AgeGroup? selectedAgeGroup,
    DateTime? startDate,
    DateTime? endDate,
    bool clearCategory = false,
    bool clearCity = false,
    bool clearAgeGroup = false,
    bool clearDates = false,
  }) {
    return TripSearchFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedCity: clearCity ? null : (selectedCity ?? this.selectedCity),
      selectedAgeGroup: clearAgeGroup ? null : (selectedAgeGroup ?? this.selectedAgeGroup),
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
    );
  }

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      selectedCategory != null ||
      selectedCity != null ||
      selectedAgeGroup != null ||
      startDate != null;
}

class TripSearchFilterNotifier extends StateNotifier<TripSearchFilterState> {
  TripSearchFilterNotifier() : super(const TripSearchFilterState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategory(String? category) {
    if (state.selectedCategory == category) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  void setCity(String? city) {
    if (state.selectedCity == city) {
      state = state.copyWith(clearCity: true);
    } else {
      state = state.copyWith(selectedCity: city);
    }
  }

  void setAgeGroup(AgeGroup? group) {
    if (state.selectedAgeGroup == group) {
      state = state.copyWith(clearAgeGroup: true);
    } else {
      state = state.copyWith(selectedAgeGroup: group);
    }
  }

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(startDate: start, endDate: end);
  }

  void resetFilters() {
    state = const TripSearchFilterState();
  }
}

final tripSearchFilterProvider =
    StateNotifierProvider<TripSearchFilterNotifier, TripSearchFilterState>((ref) {
  return TripSearchFilterNotifier();
});

/// Filtered trips matching search query and active filters
final filteredTripsProvider = Provider<List<TripModel>>((ref) {
  final allTripsAsync = ref.watch(userAgeGroupTripsStreamProvider);
  final filters = ref.watch(tripSearchFilterProvider);

  return allTripsAsync.when(
    data: (trips) {
      return trips.where((trip) {
        // Query match
        if (filters.searchQuery.isNotEmpty) {
          final query = filters.searchQuery.toLowerCase();
          final titleMatch = trip.title.toLowerCase().contains(query);
          final destMatch = trip.destination.toLowerCase().contains(query);
          final startMatch = trip.startingLocation.toLowerCase().contains(query);
          final typeMatch = trip.tripType.toLowerCase().contains(query);
          if (!titleMatch && !destMatch && !startMatch && !typeMatch) {
            return false;
          }
        }

        // Category match
        if (filters.selectedCategory != null &&
            trip.tripType.toLowerCase() != filters.selectedCategory!.toLowerCase()) {
          return false;
        }

        // City match
        if (filters.selectedCity != null &&
            !trip.startingLocation.toLowerCase().contains(filters.selectedCity!.toLowerCase())) {
          return false;
        }

        // Age group match
        if (filters.selectedAgeGroup != null &&
            trip.ageGroup != filters.selectedAgeGroup) {
          return false;
        }

        // Date range match
        if (filters.startDate != null) {
          if (trip.startDate.isBefore(filters.startDate!)) {
            return false;
          }
        }
        if (filters.endDate != null) {
          if (trip.startDate.isAfter(filters.endDate!)) {
            return false;
          }
        }

        return true;
      }).toList();
    },
    loading: () => [],
    error: (_, _) => [],
  );
});
