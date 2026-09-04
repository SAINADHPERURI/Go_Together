import 'package:cloud_firestore/cloud_firestore.dart';

enum MemberRole {
  host,
  member;

  static MemberRole fromString(String? role) {
    if (role == 'host') return MemberRole.host;
    return MemberRole.member;
  }
}

class TripMemberModel {
  final String id;
  final String tripId;
  final String userId;
  final String fullName;
  final String? photoUrl;
  final int age;
  final String city;
  final MemberRole role;
  final DateTime joinedAt;

  const TripMemberModel({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.fullName,
    this.photoUrl,
    required this.age,
    required this.city,
    required this.role,
    required this.joinedAt,
  });

  bool get isHost => role == MemberRole.host;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'userId': userId,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'age': age,
      'city': city,
      'role': role.name,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }

  factory TripMemberModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
      return DateTime.now();
    }

    return TripMemberModel(
      id: docId,
      tripId: map['tripId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      fullName: map['fullName'] as String? ?? 'Member',
      photoUrl: map['photoUrl'] as String?,
      age: map['age'] as int? ?? 25,
      city: map['city'] as String? ?? '',
      role: MemberRole.fromString(map['role'] as String?),
      joinedAt: parseDate(map['joinedAt']),
    );
  }

  factory TripMemberModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TripMemberModel.fromMap(data, doc.id);
  }
}
