import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_together/core/constants/age_group.dart';
import 'package:go_together/core/errors/exceptions.dart';
import 'package:go_together/core/theme/app_colors.dart';
import 'package:go_together/core/theme/app_theme.dart';
import 'package:go_together/core/theme/app_typography.dart';
import 'package:go_together/models/notification_model.dart';
import 'package:go_together/models/trip_member_model.dart';
import 'package:go_together/models/trip_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Exception Architecture Tests', () {
    test('Exceptions preserve custom messages and status codes', () {
      const serverEx = ServerException('Database unavailable', '503');
      expect(serverEx.message, 'Database unavailable');
      expect(serverEx.code, '503');
      expect(serverEx.toString(), 'Database unavailable');

      const valEx = ValidationException('Invalid destination', '400');
      expect(valEx.message, 'Invalid destination');
      expect(valEx.code, '400');

      const tripFullEx = TripFullException();
      expect(tripFullEx.code, 'TRIP_FULL');

      const dupEx = DuplicateRequestException();
      expect(dupEx.code, 'DUPLICATE_REQUEST');
    });
  });

  group('Model Serialization & CopyWith Tests', () {
    test('NotificationModel typedef operates correctly', () {
      final notif = NotificationModel(
        id: 'notif_1',
        userId: 'user_1',
        title: 'New Request',
        body: 'User wants to join',
        type: NotificationType.joinRequest,
        createdAt: DateTime.now(),
      );

      expect(notif.isRead, false);
      final updated = notif.copyWith(isRead: true);
      expect(updated.isRead, true);
    });

    test('TripModel copyWith preserves and updates fields correctly', () {
      final trip = TripModel(
        id: 'trip_1',
        title: 'Himalayan Trek',
        destination: 'Manali',
        startingLocation: 'Delhi',
        tripType: 'Trekking',
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 7),
        maxMembers: 8,
        currentMemberCount: 1,
        ageGroup: AgeGroup.g25_31,
        description: 'Adventurous high-altitude trek',
        hostId: 'host_1',
        hostName: 'Rahul Verma',
        hostAge: 27,
        hostCity: 'Delhi',
        imageUrl: 'https://images.unsplash.com/photo-trek',
        createdAt: DateTime(2026, 9, 1),
        updatedAt: DateTime(2026, 9, 1),
      );

      final updatedTrip = trip.copyWith(
        id: 'trip_new',
        currentMemberCount: 2,
        status: TripStatus.open,
      );

      expect(updatedTrip.id, 'trip_new');
      expect(updatedTrip.currentMemberCount, 2);
      expect(updatedTrip.destination, 'Manali');
      expect(updatedTrip.availableSlots, 6);
    });

    test('TripMemberModel correctly identifies host role', () {
      final host = TripMemberModel(
        id: 'member_1',
        tripId: 'trip_1',
        userId: 'user_host',
        fullName: 'Aarav Sharma',
        age: 26,
        city: 'Mumbai',
        role: MemberRole.host,
        joinedAt: DateTime.now(),
      );

      expect(host.isHost, true);

      final member = TripMemberModel(
        id: 'member_2',
        tripId: 'trip_1',
        userId: 'user_member',
        fullName: 'Priya Patel',
        age: 25,
        city: 'Pune',
        role: MemberRole.member,
        joinedAt: DateTime.now(),
      );

      expect(member.isHost, false);
    });
  });

  group('Design System & Theme Tokens Tests', () {
    test('AppColors provides all expected core and shimmer tokens', () {
      expect(AppColors.borderLight, isNotNull);
      expect(AppColors.borderDark, isNotNull);
      expect(AppColors.shimmerBaseLight, isNotNull);
      expect(AppColors.shimmerBaseDark, isNotNull);
      expect(AppColors.ageGroup51Plus, AppColors.ageGroup51_Plus);
    });

    test('AppTypography provides displaySmall style', () {
      expect(AppTypography.displaySmall, isNotNull);
      expect(AppTypography.displaySmall.fontWeight, FontWeight.w800);
    });

    test('Senior Accessible Theme scales dimensions and contrast', () {
      final lightSenior = AppTheme.lightTheme(isSeniorMode: true);
      final lightNormal = AppTheme.lightTheme(isSeniorMode: false);

      expect(lightSenior.textTheme.headlineLarge?.fontSize, greaterThan(lightNormal.textTheme.headlineLarge?.fontSize ?? 0));
    });
  });
}
