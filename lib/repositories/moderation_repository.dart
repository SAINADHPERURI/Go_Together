import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/exceptions.dart';
import '../models/moderation_model.dart';

class ModerationRepository {
  final FirebaseFirestore _firestore;

  ModerationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reportsRef =>
      _firestore.collection('reports');

  CollectionReference<Map<String, dynamic>> get _blocksRef =>
      _firestore.collection('blocks');

  /// Submit a safety report against a user or a trip
  Future<void> submitReport(ReportModel report) async {
    try {
      final docRef = _reportsRef.doc();
      final reportData = report.toMap();
      reportData['id'] = docRef.id;
      await docRef.set(reportData);
    } catch (e) {
      throw FirestoreException('Failed to submit report: $e');
    }
  }

  /// Block a user
  Future<void> blockUser(BlockModel block) async {
    try {
      final docRef = _blocksRef.doc();
      final blockData = block.toMap();
      blockData['id'] = docRef.id;
      await docRef.set(blockData);
    } catch (e) {
      throw FirestoreException('Failed to block user: $e');
    }
  }

  /// Stream of blocked users for a specific user
  Stream<List<BlockModel>> getBlockedUsersStream(String userId) {
    return _blocksRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BlockModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Unblock a user
  Future<void> unblockUser(String blockId) async {
    try {
      await _blocksRef.doc(blockId).delete();
    } catch (e) {
      throw FirestoreException('Failed to unblock user: $e');
    }
  }
}
