import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/exceptions.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _notificationsRef =>
      _firestore.collection('notifications');

  /// Stream notifications for current user
  /// Performs client-side date sorting to guarantee 0 composite index errors
  Stream<List<AppNotificationModel>> getUserNotificationsStream(String userId) {
    return _notificationsRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final notifs = snapshot.docs
          .map((doc) => AppNotificationModel.fromMap(doc.data(), doc.id))
          .toList();
      notifs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifs.take(50).toList();
    });
  }

  /// Stream count of unread notifications
  /// Evaluated client-side to prevent Firestore compound query index exceptions
  Stream<int> getUnreadCountStream(String userId) {
    return _notificationsRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.data()['isRead'] == false)
          .length;
    });
  }

  /// Mark single notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationsRef.doc(notificationId).update({'isRead': true});
    } catch (e) {
      throw FirestoreException('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final unreadDocs = await _notificationsRef
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (final doc in unreadDocs.docs) {
        if (doc.data()['isRead'] == false) {
          batch.update(doc.reference, {'isRead': true});
        }
      }
      await batch.commit();
    } catch (e) {
      throw FirestoreException('Failed to mark all notifications as read: $e');
    }
  }
}
