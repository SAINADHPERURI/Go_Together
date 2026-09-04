import 'package:flutter_test/flutter_test.dart';
import 'package:go_together/core/constants/age_group.dart';

void main() {
  group('AgeGroup Classification Engine Tests', () {
    test('Correctly maps numerical age to non-overlapping groups', () {
      // 18-24
      expect(AgeGroup.fromAge(18), AgeGroup.g18_24);
      expect(AgeGroup.fromAge(21), AgeGroup.g18_24);
      expect(AgeGroup.fromAge(24), AgeGroup.g18_24);

      // 25-31
      expect(AgeGroup.fromAge(25), AgeGroup.g25_31);
      expect(AgeGroup.fromAge(28), AgeGroup.g25_31);
      expect(AgeGroup.fromAge(31), AgeGroup.g25_31);

      // 32-40
      expect(AgeGroup.fromAge(32), AgeGroup.g32_40);
      expect(AgeGroup.fromAge(36), AgeGroup.g32_40);
      expect(AgeGroup.fromAge(40), AgeGroup.g32_40);

      // 41-50
      expect(AgeGroup.fromAge(41), AgeGroup.g41_50);
      expect(AgeGroup.fromAge(45), AgeGroup.g41_50);
      expect(AgeGroup.fromAge(50), AgeGroup.g41_50);

      // 51+
      expect(AgeGroup.fromAge(51), AgeGroup.g51_plus);
      expect(AgeGroup.fromAge(60), AgeGroup.g51_plus);
      expect(AgeGroup.fromAge(75), AgeGroup.g51_plus);
    });

    test('Throws ArgumentError if user is under 18 years of age', () {
      expect(() => AgeGroup.fromAge(17), throwsArgumentError);
      expect(() => AgeGroup.fromAge(15), throwsArgumentError);
    });

    test('Correctly calculates age and ageGroup from Date of Birth', () {
      final now = DateTime.now();

      // Exactly 20 years old today
      final dob20 = DateTime(now.year - 20, now.month, now.day);
      expect(AgeGroup.calculateAge(dob20), 20);
      expect(AgeGroup.fromDateOfBirth(dob20), AgeGroup.g18_24);

      // Exactly 27 years old today
      final dob27 = DateTime(now.year - 27, now.month, now.day);
      expect(AgeGroup.calculateAge(dob27), 27);
      expect(AgeGroup.fromDateOfBirth(dob27), AgeGroup.g25_31);

      // Exactly 36 years old today
      final dob36 = DateTime(now.year - 36, now.month, now.day);
      expect(AgeGroup.calculateAge(dob36), 36);
      expect(AgeGroup.fromDateOfBirth(dob36), AgeGroup.g32_40);

      // Exactly 45 years old today
      final dob45 = DateTime(now.year - 45, now.month, now.day);
      expect(AgeGroup.calculateAge(dob45), 45);
      expect(AgeGroup.fromDateOfBirth(dob45), AgeGroup.g41_50);

      // Exactly 62 years old today
      final dob62 = DateTime(now.year - 62, now.month, now.day);
      expect(AgeGroup.calculateAge(dob62), 62);
      expect(AgeGroup.fromDateOfBirth(dob62), AgeGroup.g51_plus);
    });

    test('Correctly parses age group string codes', () {
      expect(AgeGroup.fromCode('18-24'), AgeGroup.g18_24);
      expect(AgeGroup.fromCode('25-31'), AgeGroup.g25_31);
      expect(AgeGroup.fromCode('32-40'), AgeGroup.g32_40);
      expect(AgeGroup.fromCode('41-50'), AgeGroup.g41_50);
      expect(AgeGroup.fromCode('51+'), AgeGroup.g51_plus);
    });

    test('Provides tailored categories for each age group', () {
      expect(AgeGroup.g18_24.recommendedCategories, contains('Trekking'));
      expect(AgeGroup.g18_24.recommendedCategories, contains('Adventure'));
      expect(AgeGroup.g51_plus.recommendedCategories, contains('Yatra'));
      expect(AgeGroup.g51_plus.recommendedCategories, contains('Pilgrimage'));
      expect(AgeGroup.g51_plus.recommendedCategories, contains('Spiritual Journey'));
    });
  });
}
