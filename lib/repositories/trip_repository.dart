import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/age_group.dart';
import '../core/errors/exceptions.dart';
import '../models/trip_member_model.dart';
import '../models/trip_model.dart';

class TripRepository {
  final FirebaseFirestore _firestore;

  TripRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tripsCollection =>
      _firestore.collection('trips');

  /// Stream of active trips for a specific AgeGroup
  /// Performs client-side status filtering and date sorting to guarantee 0 composite index errors
  Stream<List<TripModel>> getTripsByAgeGroup(AgeGroup ageGroup) {
    return _tripsCollection
        .where('ageGroup', isEqualTo: ageGroup.code)
        .snapshots()
        .map((snapshot) {
      final trips = snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList();
      final openTrips = trips.where((t) => t.status == TripStatus.open).toList();
      openTrips.sort((a, b) => a.startDate.compareTo(b.startDate));
      return openTrips;
    });
  }

  /// Riverpod stream provider alias
  Stream<List<TripModel>> getTripsForAgeGroupStream(AgeGroup ageGroup) =>
      getTripsByAgeGroup(ageGroup);

  /// Stream of all active trips across age groups
  Stream<List<TripModel>> getAllActiveTrips() {
    return _tripsCollection.snapshots().map((snapshot) {
      final trips = snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList();
      final openTrips = trips.where((t) => t.status == TripStatus.open).toList();
      openTrips.sort((a, b) => a.startDate.compareTo(b.startDate));
      return openTrips;
    });
  }

  /// Stream of single trip details
  Stream<TripModel?> getTripByIdStream(String tripId) {
    return _tripsCollection.doc(tripId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return TripModel.fromFirestore(doc);
    });
  }

  /// Riverpod stream provider alias
  Stream<TripModel?> getTripStream(String tripId) => getTripByIdStream(tripId);

  /// Future to get trip by ID
  Future<TripModel?> getTripById(String tripId) async {
    try {
      final doc = await _tripsCollection.doc(tripId).get();
      if (!doc.exists) return null;
      return TripModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Stream of trips hosted by a specific user
  Stream<List<TripModel>> getHostedTrips(String hostId) {
    return _tripsCollection
        .where('hostId', isEqualTo: hostId)
        .snapshots()
        .map((snapshot) {
      final trips = snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList();
      trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return trips;
    });
  }

  /// Riverpod stream provider alias
  Stream<List<TripModel>> getHostedTripsStream(String hostId) => getHostedTrips(hostId);

  /// Stream of trips joined by a user (memberIds contains userId)
  Stream<List<TripModel>> getJoinedTrips(String userId) {
    return _tripsCollection
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final trips = snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList();
      trips.sort((a, b) => a.startDate.compareTo(b.startDate));
      return trips;
    });
  }

  /// Riverpod stream provider alias
  Stream<List<TripModel>> getJoinedTripsStream(String userId) => getJoinedTrips(userId);

  /// Stream of trip members in subcollection trips/{tripId}/members
  Stream<List<TripMemberModel>> getTripMembers(String tripId) {
    return _tripsCollection
        .doc(tripId)
        .collection('members')
        .snapshots()
        .map((snapshot) {
      final members = snapshot.docs.map((doc) => TripMemberModel.fromFirestore(doc)).toList();
      members.sort((a, b) => a.joinedAt.compareTo(b.joinedAt));
      return members;
    });
  }

  /// Riverpod stream provider alias
  Stream<List<TripMemberModel>> getTripMembersStream(String tripId) => getTripMembers(tripId);

  /// Create a new trip (Host is automatically enrolled as first confirmed member)
  Future<String> createTrip(TripModel trip, [TripMemberModel? hostMember]) async {
    try {
      final tripDocRef = _tripsCollection.doc();
      final newTripId = tripDocRef.id;

      final host = hostMember ??
          TripMemberModel(
            id: trip.hostId,
            tripId: newTripId,
            userId: trip.hostId,
            fullName: trip.hostName,
            photoUrl: trip.hostPhotoUrl,
            age: trip.hostAge,
            city: trip.hostCity,
            role: MemberRole.host,
            joinedAt: DateTime.now(),
          );

      final completeTrip = trip.copyWith(
        id: newTripId,
        memberIds: [host.userId],
        currentMemberCount: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final batch = _firestore.batch();

      // 1. Set the trip document
      batch.set(tripDocRef, completeTrip.toMap());

      // 2. Set the host member in subcollection
      final memberDocRef = tripDocRef.collection('members').doc(host.userId);
      batch.set(memberDocRef, host.toMap());

      await batch.commit();
      return newTripId;
    } catch (e) {
      throw ServerException('Failed to create trip: ${e.toString()}');
    }
  }

  /// Update trip details
  Future<void> updateTrip(TripModel trip) async {
    try {
      final updated = trip.copyWith(updatedAt: DateTime.now());
      await _tripsCollection.doc(trip.id).update(updated.toMap());
    } catch (e) {
      throw ServerException('Failed to update trip: ${e.toString()}');
    }
  }

  /// Update trip status
  Future<void> updateTripStatus(String tripId, TripStatus status) async {
    try {
      await _tripsCollection.doc(tripId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to update trip status: ${e.toString()}');
    }
  }

  /// Cancel trip
  Future<void> cancelTrip(String tripId) async {
    try {
      await _tripsCollection.doc(tripId).update({
        'status': TripStatus.cancelled.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to cancel trip: ${e.toString()}');
    }
  }

  /// Remove a member from trip
  Future<void> removeMember({required String tripId, required String memberUserId}) async {
    try {
      final batch = _firestore.batch();

      final tripDocRef = _tripsCollection.doc(tripId);
      batch.update(tripDocRef, {
        'memberIds': FieldValue.arrayRemove([memberUserId]),
        'currentMemberCount': FieldValue.increment(-1),
        'status': TripStatus.open.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final memberDocRef = tripDocRef.collection('members').doc(memberUserId);
      batch.delete(memberDocRef);

      await batch.commit();
    } catch (e) {
      throw ServerException('Failed to remove member: ${e.toString()}');
    }
  }
}
