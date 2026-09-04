import 'package:flutter_test/flutter_test.dart';
import 'package:go_together/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('Email validation tests', () {
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('invalid-email'), isNotNull);
      expect(Validators.validateEmail('test@domain'), isNotNull);
      expect(Validators.validateEmail('user@example.com'), isNull);
      expect(Validators.validateEmail('traveler.companion@go-together.org'), isNull);
    });

    test('Password validation tests', () {
      expect(Validators.validatePassword(''), isNotNull);
      expect(Validators.validatePassword('12345'), isNotNull);
      expect(Validators.validatePassword('123456'), isNull);
      expect(Validators.validatePassword('securePassword!2026'), isNull);
    });

    test('Trip capacity validation tests', () {
      expect(Validators.validateCapacity(''), isNotNull);
      expect(Validators.validateCapacity('0'), isNotNull);
      expect(Validators.validateCapacity('1'), isNotNull);
      expect(Validators.validateCapacity('6'), isNull);
      expect(Validators.validateCapacity('12'), isNull);
      expect(Validators.validateCapacity('51'), isNotNull);
    });

    test('Trip date range validation tests', () {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final nextWeek = now.add(const Duration(days: 7));
      final pastDate = now.subtract(const Duration(days: 5));

      expect(Validators.validateTripDates(null, nextWeek), isNotNull);
      expect(Validators.validateTripDates(tomorrow, null), isNotNull);
      expect(Validators.validateTripDates(pastDate, tomorrow), isNotNull);
      expect(Validators.validateTripDates(nextWeek, tomorrow), isNotNull);
      expect(Validators.validateTripDates(tomorrow, nextWeek), isNull);
    });
  });
}
