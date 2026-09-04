import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/age_group.dart';
import '../core/constants/app_assets.dart';

enum TripStatus {
  open,
  full,
  closed,
  completed,
  cancelled;

  static TripStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'open':
        return TripStatus.open;
      case 'full':
        return TripStatus.full;
      case 'closed':
        return TripStatus.closed;
      case 'completed':
        return TripStatus.completed;
      case 'cancelled':
        return TripStatus.cancelled;
      default:
        return TripStatus.open;
    }
  }
}

class TripModel {
  final String id;
  final String title;
  final String destination;
  final String startingLocation;
  final String tripType;
  final DateTime startDate;
  final DateTime endDate;
  final int maxMembers;
  final int currentMemberCount;
  final AgeGroup ageGroup;
  final String description;
  final String? meetingPointDetails;
  final String? budgetEstimateNote;
  final String hostId;
  final String hostName;
  final String? hostPhotoUrl;
  final int hostAge;
  final String hostCity;
  final TripStatus status;
  final List<String> memberIds;
  final String imageUrl;
  final List<String> destinationPhotos;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TripModel({
    required this.id,
    required this.title,
    required this.destination,
    required this.startingLocation,
    required this.tripType,
    required this.startDate,
    required this.endDate,
    required this.maxMembers,
    required this.currentMemberCount,
    required this.ageGroup,
    required this.description,
    this.meetingPointDetails,
    this.budgetEstimateNote,
    required this.hostId,
    required this.hostName,
    this.hostPhotoUrl,
    required this.hostAge,
    required this.hostCity,
    this.status = TripStatus.open,
    this.memberIds = const [],
    required this.imageUrl,
    this.destinationPhotos = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isFull => currentMemberCount >= maxMembers;
  bool get isOpen => status == TripStatus.open && !isFull;
  int get availableSlots => (maxMembers - currentMemberCount).clamp(0, maxMembers);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'startingLocation': startingLocation,
      'tripType': tripType,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'maxMembers': maxMembers,
      'currentMemberCount': currentMemberCount,
      'ageGroup': ageGroup.code,
      'description': description,
      'meetingPointDetails': meetingPointDetails,
      'budgetEstimateNote': budgetEstimateNote,
      'hostId': hostId,
      'hostName': hostName,
      'hostPhotoUrl': hostPhotoUrl,
      'hostAge': hostAge,
      'hostCity': hostCity,
      'status': status.name,
      'memberIds': memberIds,
      'imageUrl': imageUrl,
      'destinationPhotos': destinationPhotos,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory TripModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
      return DateTime.now();
    }

    final destination = map['destination'] as String? ?? '';
    final imageUrl = map['imageUrl'] as String? ?? AppAssets.getImageUrlForDestination(destination);

    return TripModel(
      id: docId,
      title: map['title'] as String? ?? '$destination Trip',
      destination: destination,
      startingLocation: map['startingLocation'] as String? ?? '',
      tripType: map['tripType'] as String? ?? 'Adventure',
      startDate: parseDate(map['startDate']),
      endDate: parseDate(map['endDate']),
      maxMembers: map['maxMembers'] as int? ?? 6,
      currentMemberCount: map['currentMemberCount'] as int? ?? 1,
      ageGroup: AgeGroup.fromCode(map['ageGroup'] as String? ?? '25-31'),
      description: map['description'] as String? ?? '',
      meetingPointDetails: map['meetingPointDetails'] as String?,
      budgetEstimateNote: map['budgetEstimateNote'] as String?,
      hostId: map['hostId'] as String? ?? '',
      hostName: map['hostName'] as String? ?? 'Host',
      hostPhotoUrl: map['hostPhotoUrl'] as String?,
      hostAge: map['hostAge'] as int? ?? 25,
      hostCity: map['hostCity'] as String? ?? '',
      status: TripStatus.fromString(map['status'] as String?),
      memberIds: List<String>.from(map['memberIds'] ?? []),
      imageUrl: imageUrl,
      destinationPhotos: List<String>.from(map['destinationPhotos'] ?? []),
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  factory TripModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TripModel.fromMap(data, doc.id);
  }

  TripModel copyWith({
    String? id,
    String? title,
    String? destination,
    String? startingLocation,
    String? tripType,
    DateTime? startDate,
    DateTime? endDate,
    int? maxMembers,
    int? currentMemberCount,
    AgeGroup? ageGroup,
    String? description,
    String? meetingPointDetails,
    String? budgetEstimateNote,
    String? hostId,
    String? hostName,
    String? hostPhotoUrl,
    int? hostAge,
    String? hostCity,
    TripStatus? status,
    List<String>? memberIds,
    String? imageUrl,
    List<String>? destinationPhotos,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TripModel(
      id: id ?? this.id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      startingLocation: startingLocation ?? this.startingLocation,
      tripType: tripType ?? this.tripType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maxMembers: maxMembers ?? this.maxMembers,
      currentMemberCount: currentMemberCount ?? this.currentMemberCount,
      ageGroup: ageGroup ?? this.ageGroup,
      description: description ?? this.description,
      meetingPointDetails: meetingPointDetails ?? this.meetingPointDetails,
      budgetEstimateNote: budgetEstimateNote ?? this.budgetEstimateNote,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      hostPhotoUrl: hostPhotoUrl ?? this.hostPhotoUrl,
      hostAge: hostAge ?? this.hostAge,
      hostCity: hostCity ?? this.hostCity,
      status: status ?? this.status,
      memberIds: memberIds ?? this.memberIds,
      imageUrl: imageUrl ?? this.imageUrl,
      destinationPhotos: destinationPhotos ?? this.destinationPhotos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
