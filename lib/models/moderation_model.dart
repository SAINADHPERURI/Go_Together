import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String reporterId;
  final String? reportedUserId;
  final String? reportedTripId;
  final String reason;
  final String details;
  final String status;
  final DateTime createdAt;

  const ReportModel({
    required this.id,
    required this.reporterId,
    this.reportedUserId,
    this.reportedTripId,
    required this.reason,
    required this.details,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reporterId': reporterId,
      'reportedUserId': reportedUserId,
      'reportedTripId': reportedTripId,
      'reason': reason,
      'details': details,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
      return DateTime.now();
    }

    return ReportModel(
      id: docId,
      reporterId: map['reporterId'] as String? ?? '',
      reportedUserId: map['reportedUserId'] as String?,
      reportedTripId: map['reportedTripId'] as String?,
      reason: map['reason'] as String? ?? 'Inappropriate behavior',
      details: map['details'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      createdAt: parseDate(map['createdAt']),
    );
  }
}

class BlockModel {
  final String id;
  final String userId;
  final String blockedUserId;
  final String? blockedUserName;
  final DateTime createdAt;

  const BlockModel({
    required this.id,
    required this.userId,
    required this.blockedUserId,
    this.blockedUserName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'blockedUserId': blockedUserId,
      'blockedUserName': blockedUserName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory BlockModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
      return DateTime.now();
    }

    return BlockModel(
      id: docId,
      userId: map['userId'] as String? ?? '',
      blockedUserId: map['blockedUserId'] as String? ?? '',
      blockedUserName: map['blockedUserName'] as String?,
      createdAt: parseDate(map['createdAt']),
    );
  }
}
