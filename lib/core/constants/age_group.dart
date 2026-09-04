// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

/// Non-overlapping Age Groups for GoTogether
/// Strict classifications:
/// - 18–24: Young Explorers
/// - 25–31: Active Adventurers
/// - 32–40: Prime Travelers
/// - 41–50: Seasoned Wanderers
/// - 51+: Golden Trekkers / Spiritual & Leisure
enum AgeGroup {
  g18_24,
  g25_31,
  g32_40,
  g41_50,
  g51_plus;

  String get code {
    switch (this) {
      case AgeGroup.g18_24:
        return '18-24';
      case AgeGroup.g25_31:
        return '25-31';
      case AgeGroup.g32_40:
        return '32-40';
      case AgeGroup.g41_50:
        return '41-50';
      case AgeGroup.g51_plus:
        return '51+';
    }
  }

  String get displayName {
    switch (this) {
      case AgeGroup.g18_24:
        return '18–24 yrs';
      case AgeGroup.g25_31:
        return '25–31 yrs';
      case AgeGroup.g32_40:
        return '32–40 yrs';
      case AgeGroup.g41_50:
        return '41–50 yrs';
      case AgeGroup.g51_plus:
        return '51+ yrs';
    }
  }

  String get personaTitle {
    switch (this) {
      case AgeGroup.g18_24:
        return 'Young Explorers';
      case AgeGroup.g25_31:
        return 'Active Adventurers';
      case AgeGroup.g32_40:
        return 'Prime Travelers';
      case AgeGroup.g41_50:
        return 'Seasoned Wanderers';
      case AgeGroup.g51_plus:
        return 'Golden Trekkers & Pilgrims';
    }
  }

  String get subtitle {
    switch (this) {
      case AgeGroup.g18_24:
        return 'Backpacking, Camping, Treks & College Getaways';
      case AgeGroup.g25_31:
        return 'Weekend Escapes, High Altitudes & Road Trips';
      case AgeGroup.g32_40:
        return 'Nature Retreats, Heritage Walks & Workcations';
      case AgeGroup.g41_50:
        return 'Scenic Hill Stations, Cultural Tours & Wellness';
      case AgeGroup.g51_plus:
        return 'Yatras, Sacred Pilgrimages & Comfortable Leisure';
    }
  }

  IconData get icon {
    switch (this) {
      case AgeGroup.g18_24:
        return Icons.hiking_rounded;
      case AgeGroup.g25_31:
        return Icons.terrain_rounded;
      case AgeGroup.g32_40:
        return Icons.explore_rounded;
      case AgeGroup.g41_50:
        return Icons.nature_people_rounded;
      case AgeGroup.g51_plus:
        return Icons.temple_hindu_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case AgeGroup.g18_24:
        return const Color(0xFF0284C7); // Vibrant Sky Blue
      case AgeGroup.g25_31:
        return const Color(0xFF0E7A6B); // Deep Emerald
      case AgeGroup.g32_40:
        return const Color(0xFFD97706); // Warm Amber
      case AgeGroup.g41_50:
        return const Color(0xFF7C3AED); // Regal Violet
      case AgeGroup.g51_plus:
        return const Color(0xFFC2410C); // Sacred Saffron / Terracotta
    }
  }

  /// Recommended default trip categories for dashboard personalization
  List<String> get recommendedCategories {
    switch (this) {
      case AgeGroup.g18_24:
        return ['Trekking', 'Adventure', 'Camping', 'Road Trip', 'Weekend Trip'];
      case AgeGroup.g25_31:
        return ['Adventure', 'Trekking', 'Hill Station', 'Climbing', 'Road Trip', 'Vacation'];
      case AgeGroup.g32_40:
        return ['Hill Station', 'Vacation', 'Cultural', 'Nature Retreat', 'Weekend Trip'];
      case AgeGroup.g41_50:
        return ['Cultural', 'Hill Station', 'Comfortable Travel', 'Spiritual Journey', 'Vacation'];
      case AgeGroup.g51_plus:
        return ['Yatra', 'Pilgrimage', 'Spiritual Journey', 'Cultural', 'Comfortable Travel'];
    }
  }

  /// Calculates strict AgeGroup from exact date of birth
  static AgeGroup fromDateOfBirth(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return fromAge(age);
  }

  /// Calculates strict AgeGroup from numerical age
  static AgeGroup fromAge(int age) {
    if (age < 18) {
      throw ArgumentError('Users must be at least 18 years old to join GoTogether.');
    }
    if (age <= 24) return AgeGroup.g18_24;
    if (age <= 31) return AgeGroup.g25_31;
    if (age <= 40) return AgeGroup.g32_40;
    if (age <= 50) return AgeGroup.g41_50;
    return AgeGroup.g51_plus;
  }

  /// Parses from stored code string (e.g., "18-24", "25-31", etc.)
  static AgeGroup fromCode(String code) {
    switch (code.trim()) {
      case '18-24':
      case '18–24':
        return AgeGroup.g18_24;
      case '25-31':
      case '25–31':
        return AgeGroup.g25_31;
      case '32-40':
      case '32–40':
        return AgeGroup.g32_40;
      case '41-50':
      case '41–50':
        return AgeGroup.g41_50;
      case '51+':
      case '51_plus':
        return AgeGroup.g51_plus;
      default:
        return AgeGroup.g25_31;
    }
  }

  /// Calculates exact integer age from DOB
  static int calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }
}
