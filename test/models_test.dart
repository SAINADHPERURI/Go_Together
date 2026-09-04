import 'package:flutter_test/flutter_test.dart';
import 'package:go_together/core/constants/age_group.dart';
import 'package:go_together/models/join_request_model.dart';
import 'package:go_together/models/trip_model.dart';
import 'package:go_together/models/user_model.dart';

void main() {
  group('Models Unit Tests', () {
    test('UserModel serialization and automatic age calculation', () {
      final dob = DateTime(1998, 5, 15);
      final user = UserModel.create(
        id: 'user_123',
        email: 'traveler@gotogether.com',
        fullName: 'Rahul Sharma',
        dateOfBirth: dob,
        city: 'Bengaluru',
        bio: 'Love mountain treks',
        travelInterests: ['Trekking', 'Camping'],
      );

      expect(user.id, 'user_123');
      expect(user.ageGroup, AgeGroup.fromDateOfBirth(dob));
      expect(user.travelInterests.length, 2);

      final map = user.toMap();
      expect(map['fullName'], 'Rahul Sharma');
      expect(map['city'], 'Bengaluru');
      expect(map['ageGroup'], user.ageGroup.code);
    });

    test('TripModel availability and capacity calculations', () {
      final trip = TripModel(
        id: 'trip_101',
        title: 'Kashmir Trek',
        destination: 'Kashmir',
        startingLocation: 'Chennai',
        tripType: 'Trekking',
        startDate: DateTime(2026, 10, 10),
        endDate: DateTime(2026, 10, 16),
        maxMembers: 8,
        currentMemberCount: 3,
        ageGroup: AgeGroup.g25_31,
        description: 'Trek through alpine valleys',
        hostId: 'host_1',
        hostName: 'Karthik',
        hostAge: 27,
        hostCity: 'Chennai',
        imageUrl: 'https://example.com/kashmir.jpg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(trip.isFull, false);
      expect(trip.isOpen, true);
      expect(trip.availableSlots, 5);

      final fullTrip = trip.copyWith(currentMemberCount: 8);
      expect(fullTrip.isFull, true);
      expect(fullTrip.availableSlots, 0);
    });

    test('JoinRequestModel status transitions', () {
      final request = JoinRequestModel(
        id: 'req_1',
        tripId: 'trip_101',
        tripTitle: 'Kashmir Trek',
        tripDestination: 'Kashmir',
        tripStartDate: DateTime(2026, 10, 10),
        userId: 'user_2',
        userName: 'Pooja',
        userAge: 26,
        userAgeGroup: AgeGroup.g25_31,
        userCity: 'Bengaluru',
        message: 'Excited to join!',
        hostId: 'host_1',
        status: JoinRequestStatus.pending,
        createdAt: DateTime.now(),
      );

      expect(request.status, JoinRequestStatus.pending);

      final accepted = request.copyWith(status: JoinRequestStatus.accepted);
      expect(accepted.status, JoinRequestStatus.accepted);

      final rejected = request.copyWith(status: JoinRequestStatus.rejected);
      expect(rejected.status, JoinRequestStatus.rejected);
    });
  });
}
