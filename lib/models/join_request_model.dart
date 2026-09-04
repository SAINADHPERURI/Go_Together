import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/age_group.dart';

enum JoinRequestStatus {
  pending,
  accepted,
  rejected,
  cancelled;

  static JoinRequestStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return JoinRequestStatus.pending;
      case 'accepted':
        return JoinRequestStatus.accepted;
      case 'rejected':
        return JoinRequestStatus.rejected;
      case 'cancelled':
        return JoinRequestStatus.cancelled;
      default:
        return JoinRequestStatus.pending;
    }
  }
}

class JoinRequestModel {
  final String id;
  final String tripId;
  final String tripTitle;
  final String tripDestination;
  final DateTime tripStartDate;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final int userAge;
  final AgeGroup userAgeGroup;
  final String userCity;
  final String message;
  final JoinRequestStatus status;
  final String hostId;
  final DateTime createdAt;
  final DateTime? respondedAt;

  const JoinRequestModel({
    required this.id,
    required this.tripId,
    required this.tripTitle,
    required this.tripDestination,
    required this.tripStartDate,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.userAge,
    required this.userAgeGroup,
    required this.userCity,
    required this.message,
    this.status = JoinRequestStatus.pending,
    required this.hostId,
    required this.createdAt,
    this.respondedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'tripTitle': tripTitle,
      'tripDestination': tripDestination,
      'tripStartDate': Timestamp.fromDate(tripStartDate),
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'userAge': userAge,
      'userAgeGroup': userAgeGroup.code,
      'userCity': userCity,
      'message': message,
      'status': status.name,
      'hostId': hostId,
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
    };
  }

  factory JoinRequestModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
      return DateTime.now();
    }

    return JoinRequestModel(
      id: docId,
      tripId: map['tripId'] as String? ?? '',
      tripTitle: map['tripTitle'] as String? ?? '',
      tripDestination: map['tripDestination'] as String? ?? '',
      tripStartDate: parseDate(map['tripStartDate']),
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? 'Traveler',
      userPhotoUrl: map['userPhotoUrl'] as String?,
      userAge: map['userAge'] as int? ?? 25,
      userAgeGroup: AgeGroup.fromCode(map['userAgeGroup'] as String? ?? '25-31'),
      userCity: map['userCity'] as String? ?? '',
      message: map['message'] as String? ?? '',
      status: JoinRequestStatus.fromString(map['status'] as String?),
      hostId: map['hostId'] as String? ?? '',
      createdAt: parseDate(map['createdAt']),
      respondedAt: map['respondedAt'] != null ? parseDate(map['respondedAt']) : null,
    );
  }

  factory JoinRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return JoinRequestModel.fromMap(data, doc.id);
  }

  JoinRequestModel copyWith({
    String? id,
    JoinRequestStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return JoinRequestModel(
      id: id ?? this.id,
      tripId: tripId,
      tripTitle: tripTitle,
      tripDestination: tripDestination,
      tripStartDate: tripStartDate,
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      userAge: userAge,
      userAgeGroup: userAgeGroup,
      userCity: userCity,
      message: message,
      status: status ?? this.status,
      hostId: hostId,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}
