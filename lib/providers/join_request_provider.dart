import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/join_request_model.dart';
import '../repositories/join_request_repository.dart';
import 'auth_provider.dart';

final joinRequestRepositoryProvider = Provider<JoinRequestRepository>((ref) {
  return JoinRequestRepository();
});

/// Incoming join requests for trips hosted by current user
final hostIncomingRequestsStreamProvider =
    StreamProvider<List<JoinRequestModel>>((ref) {
  final user = ref.watch(currentUserProfileProvider).value;
  if (user == null) return Stream.value([]);

  final reqRepo = ref.watch(joinRequestRepositoryProvider);
  return reqRepo.getHostRequestsStream(user.id);
});

/// Outbound join requests submitted by current user
final userOutboundRequestsStreamProvider =
    StreamProvider<List<JoinRequestModel>>((ref) {
  final user = ref.watch(currentUserProfileProvider).value;
  if (user == null) return Stream.value([]);

  final reqRepo = ref.watch(joinRequestRepositoryProvider);
  return reqRepo.getUserRequestsStream(user.id);
});

/// Check user's join request status for a specific trip
final userTripRequestStatusStreamProvider =
    StreamProvider.family<JoinRequestModel?, String>((ref, tripId) {
  final user = ref.watch(currentUserProfileProvider).value;
  if (user == null) return Stream.value(null);

  final reqRepo = ref.watch(joinRequestRepositoryProvider);
  return reqRepo.getUserRequestForTripStream(tripId, user.id);
});
