import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/age_group.dart';

enum UserRole {
  user,
  admin;

  static UserRole fromString(String? role) {
    if (role == 'admin') return UserRole.admin;
    return UserRole.user;
  }
}

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? photoUrl;
  final DateTime dateOfBirth;
  final int age;
  final AgeGroup ageGroup;
  final String city;
  final String? state;
  final String bio;
  final List<String> preferredLanguages;
  final List<String> travelInterests;
  final List<String> travelStyles;
  final UserRole role;
  final bool isBlocked;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? fcmToken;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.photoUrl,
    required this.dateOfBirth,
    required this.age,
    required this.ageGroup,
    required this.city,
    this.state,
    required this.bio,
    this.preferredLanguages = const [],
    this.travelInterests = const [],
    this.travelStyles = const [],
    this.role = UserRole.user,
    this.isBlocked = false,
    required this.createdAt,
    required this.updatedAt,
    this.fcmToken,
  });

  /// Factory constructor to create a UserModel with automatic calculation of age & ageGroup
  factory UserModel.create({
    required String id,
    required String email,
    required String fullName,
    String? photoUrl,
    required DateTime dateOfBirth,
    required String city,
    String? state,
    String bio = '',
    List<String> preferredLanguages = const ['English'],
    List<String> travelInterests = const [],
    List<String> travelStyles = const [],
    UserRole role = UserRole.user,
    String? fcmToken,
  }) {
    final age = AgeGroup.calculateAge(dateOfBirth);
    final ageGroup = AgeGroup.fromDateOfBirth(dateOfBirth);
    final now = DateTime.now();

    return UserModel(
      id: id,
      email: email,
      fullName: fullName,
      photoUrl: photoUrl,
      dateOfBirth: dateOfBirth,
      age: age,
      ageGroup: ageGroup,
      city: city,
      state: state,
      bio: bio,
      preferredLanguages: preferredLanguages,
      travelInterests: travelInterests,
      travelStyles: travelStyles,
      role: role,
      isBlocked: false,
      createdAt: now,
      updatedAt: now,
      fcmToken: fcmToken,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'age': age,
      'ageGroup': ageGroup.code,
      'city': city,
      'state': state,
      'bio': bio,
      'preferredLanguages': preferredLanguages,
      'travelInterests': travelInterests,
      'travelStyles': travelStyles,
      'role': role.name,
      'isBlocked': isBlocked,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'fcmToken': fcmToken,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime(2000, 1, 1);
      if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
      return DateTime(2000, 1, 1);
    }

    final dob = parseDate(map['dateOfBirth']);
    final calculatedAge = map['age'] as int? ?? AgeGroup.calculateAge(dob);
    final ageGroup = map['ageGroup'] != null
        ? AgeGroup.fromCode(map['ageGroup'].toString())
        : AgeGroup.fromDateOfBirth(dob);

    return UserModel(
      id: docId,
      email: map['email'] as String? ?? '',
      fullName: map['fullName'] as String? ?? 'Traveler',
      photoUrl: map['photoUrl'] as String?,
      dateOfBirth: dob,
      age: calculatedAge,
      ageGroup: ageGroup,
      city: map['city'] as String? ?? 'India',
      state: map['state'] as String?,
      bio: map['bio'] as String? ?? '',
      preferredLanguages: List<String>.from(map['preferredLanguages'] ?? []),
      travelInterests: List<String>.from(map['travelInterests'] ?? []),
      travelStyles: List<String>.from(map['travelStyles'] ?? []),
      role: UserRole.fromString(map['role'] as String?),
      isBlocked: map['isBlocked'] as bool? ?? false,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
      fcmToken: map['fcmToken'] as String?,
    );
  }

  UserModel copyWith({
    String? fullName,
    String? photoUrl,
    DateTime? dateOfBirth,
    String? city,
    String? state,
    String? bio,
    List<String>? preferredLanguages,
    List<String>? travelInterests,
    List<String>? travelStyles,
    UserRole? role,
    bool? isBlocked,
    String? fcmToken,
  }) {
    final effectiveDob = dateOfBirth ?? this.dateOfBirth;
    final effectiveAge = AgeGroup.calculateAge(effectiveDob);
    final effectiveAgeGroup = AgeGroup.fromDateOfBirth(effectiveDob);

    return UserModel(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      photoUrl: photoUrl ?? this.photoUrl,
      dateOfBirth: effectiveDob,
      age: effectiveAge,
      ageGroup: effectiveAgeGroup,
      city: city ?? this.city,
      state: state ?? this.state,
      bio: bio ?? this.bio,
      preferredLanguages: preferredLanguages ?? this.preferredLanguages,
      travelInterests: travelInterests ?? this.travelInterests,
      travelStyles: travelStyles ?? this.travelStyles,
      role: role ?? this.role,
      isBlocked: isBlocked ?? this.isBlocked,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
