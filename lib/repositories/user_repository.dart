import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/exceptions.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  /// Stream of user profile for real-time profile updates
  Stream<UserModel?> getUserStream(String userId) {
    return _usersRef.doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return UserModel.fromMap(snapshot.data()!, snapshot.id);
    });
  }

  /// Get user profile by ID once
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _usersRef.doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw FirestoreException('Failed to fetch user profile: $e');
    }
  }

  /// Create new user profile document upon registration/onboarding
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _usersRef.doc(user.id).set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException('Failed to create user profile: $e');
    }
  }

  /// Update existing user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _usersRef.doc(user.id).update(user.toMap());
    } catch (e) {
      throw FirestoreException('Failed to update user profile: $e');
    }
  }

  /// Update FCM device token for notifications
  Future<void> updateFcmToken(String userId, String token) async {
    try {
      await _usersRef.doc(userId).update({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Non-blocking update
    }
  }

  /// Completely delete user profile document
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _usersRef.doc(userId).delete();
    } catch (e) {
      throw FirestoreException('Failed to delete user profile data: $e');
    }
  }
}
