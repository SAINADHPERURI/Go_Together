import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/exceptions.dart';
import '../models/join_request_model.dart';
import '../models/notification_model.dart';
import '../models/trip_member_model.dart';
import '../models/trip_model.dart';

class JoinRequestRepository {
  final FirebaseFirestore _firestore;

  JoinRequestRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _requestsCollection =>
      _firestore.collection('joinRequests');

  /// Stream of incoming join requests for trips hosted by this user
  Stream<List<JoinRequestModel>> getIncomingRequestsForHost(String hostId) {
    return _requestsCollection
        .where('hostId', isEqualTo: hostId)
        .snapshots()
        .map((snapshot) {
      final requests = snapshot.docs.map((doc) => JoinRequestModel.fromFirestore(doc)).toList();
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    });
  }

  /// Riverpod stream provider alias
  Stream<List<JoinRequestModel>> getHostRequestsStream(String hostId) =>
      getIncomingRequestsForHost(hostId);

  /// Stream of join requests submitted by this user
  Stream<List<JoinRequestModel>> getUserJoinRequests(String userId) {
    return _requestsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final requests = snapshot.docs.map((doc) => JoinRequestModel.fromFirestore(doc)).toList();
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    });
  }

  /// Riverpod stream provider alias
  Stream<List<JoinRequestModel>> getUserRequestsStream(String userId) =>
      getUserJoinRequests(userId);

  /// Stream of user's request status for a specific trip
  Stream<JoinRequestModel?> getTripRequestForUser(String tripId, String userId) {
    return _requestsCollection
        .where('tripId', isEqualTo: tripId)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return JoinRequestModel.fromFirestore(snapshot.docs.first);
    });
  }

  /// Riverpod stream provider alias
  Stream<JoinRequestModel?> getUserRequestForTripStream(String tripId, String userId) =>
      getTripRequestForUser(tripId, userId);

  /// Submit a join request
  Future<String> submitJoinRequest({
    required JoinRequestModel request,
    TripModel? trip,
    dynamic requester,
  }) async {
    try {
      // 1. Check if user already requested
      final existing = await _requestsCollection
          .where('tripId', isEqualTo: request.tripId)
          .where('userId', isEqualTo: request.userId)
          .get();

      if (existing.docs.isNotEmpty) {
        final existingStatus = existing.docs.first.data()['status'];
        if (existingStatus == 'pending' || existingStatus == 'accepted') {
          throw const ValidationException('You have already requested or joined this trip.');
        }
      }

      final docRef = _requestsCollection.doc();
      final fullRequest = request.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
      );

      final batch = _firestore.batch();
      batch.set(docRef, fullRequest.toMap());

      // Create in-app notification for host
      final notifDocRef = _firestore.collection('notifications').doc();
      final hostNotif = NotificationModel(
        id: notifDocRef.id,
        userId: request.hostId,
        title: 'New Join Request 🎒',
        body: '${request.userName} requested to join your trip to ${request.tripDestination}.',
        type: NotificationType.joinRequest,
        tripId: request.tripId,
        isRead: false,
        createdAt: DateTime.now(),
      );
      batch.set(notifDocRef, hostNotif.toMap());

      await batch.commit();
      return docRef.id;
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException(e.toString());
    }
  }

  /// Host accepts a join request (Atomic transaction updating request, trip capacity, member list, and notification)
  Future<void> acceptJoinRequest({
    required JoinRequestModel request,
    TripModel? trip,
    TripMemberModel? newMember,
  }) async {
    try {
      final TripModel targetTrip;
      if (trip != null) {
        targetTrip = trip;
      } else {
        final doc = await _firestore.collection('trips').doc(request.tripId).get();
        if (!doc.exists) throw const ServerException('Trip not found');
        targetTrip = TripModel.fromFirestore(doc);
      }

      if (targetTrip.isFull) {
        throw TripFullException('This trip has already reached its maximum capacity of ${targetTrip.maxMembers}.');
      }

      final member = newMember ??
          TripMemberModel(
            id: request.userId,
            tripId: request.tripId,
            userId: request.userId,
            fullName: request.userName,
            photoUrl: request.userPhotoUrl,
            age: request.userAge,
            city: request.userCity,
            role: MemberRole.member,
            joinedAt: DateTime.now(),
          );

      final batch = _firestore.batch();

      // 1. Update Join Request status to accepted
      final reqDocRef = _requestsCollection.doc(request.id);
      batch.update(reqDocRef, {
        'status': JoinRequestStatus.accepted.name,
        'respondedAt': FieldValue.serverTimestamp(),
      });

      // 2. Update Trip document: append memberId, increment count, mark full if reached
      final tripDocRef = _firestore.collection('trips').doc(targetTrip.id);
      final newCount = targetTrip.currentMemberCount + 1;
      batch.update(tripDocRef, {
        'memberIds': FieldValue.arrayUnion([request.userId]),
        'currentMemberCount': FieldValue.increment(1),
        'status': newCount >= targetTrip.maxMembers ? TripStatus.full.name : targetTrip.status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 3. Add to trips/{tripId}/members subcollection
      final memberDocRef = tripDocRef.collection('members').doc(request.userId);
      batch.set(memberDocRef, member.toMap());

      // 4. Send acceptance in-app notification to traveler
      final notifDocRef = _firestore.collection('notifications').doc();
      final acceptNotif = NotificationModel(
        id: notifDocRef.id,
        userId: request.userId,
        title: 'Request Accepted! 🎉',
        body: 'You are now confirmed for the trip to ${targetTrip.destination}! Tap to enter the group chat.',
        type: NotificationType.requestAccepted,
        tripId: targetTrip.id,
        isRead: false,
        createdAt: DateTime.now(),
      );
      batch.set(notifDocRef, acceptNotif.toMap());

      await batch.commit();
    } catch (e) {
      if (e is TripFullException) rethrow;
      throw ServerException('Failed to accept request: ${e.toString()}');
    }
  }

  /// Host rejects a join request
  Future<void> rejectJoinRequest({required JoinRequestModel request}) async {
    try {
      final batch = _firestore.batch();

      final reqDocRef = _requestsCollection.doc(request.id);
      batch.update(reqDocRef, {
        'status': JoinRequestStatus.rejected.name,
        'respondedAt': FieldValue.serverTimestamp(),
      });

      final notifDocRef = _firestore.collection('notifications').doc();
      final rejectNotif = NotificationModel(
        id: notifDocRef.id,
        userId: request.userId,
        title: 'Trip Request Update',
        body: 'Your request for ${request.tripDestination} was not accepted by the host.',
        type: NotificationType.requestRejected,
        tripId: request.tripId,
        isRead: false,
        createdAt: DateTime.now(),
      );
      batch.set(notifDocRef, rejectNotif.toMap());

      await batch.commit();
    } catch (e) {
      throw ServerException('Failed to reject request: ${e.toString()}');
    }
  }

  /// User cancels their pending join request
  Future<void> cancelJoinRequest(String requestId) async {
    try {
      await _requestsCollection.doc(requestId).update({
        'status': JoinRequestStatus.cancelled.name,
        'respondedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to cancel request: ${e.toString()}');
    }
  }
}
