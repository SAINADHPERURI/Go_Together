import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip_member_model.dart';
import '../models/trip_model.dart';
import 'trip_provider.dart';

/// Stream of a specific trip by its ID
final tripDetailStreamProvider = StreamProvider.family<TripModel?, String>((ref, tripId) {
  final tripRepo = ref.watch(tripRepositoryProvider);
  return tripRepo.getTripStream(tripId);
});

/// Stream of all members for a specific trip
final tripMembersStreamProvider =
    StreamProvider.family<List<TripMemberModel>, String>((ref, tripId) {
  final tripRepo = ref.watch(tripRepositoryProvider);
  return tripRepo.getTripMembersStream(tripId);
});
