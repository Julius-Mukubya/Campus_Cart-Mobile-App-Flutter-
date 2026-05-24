import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_logger.dart';

/// Firestore-backed chat service.
/// Messages stored in: chats/{chatId}/messages/{messageId}
/// Chats are scoped by order (order_{orderId}) or direct (direct_{userId1}_{userId2}).
class ChatService {
  final FirebaseFirestore _firestore;

  ChatService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ── Helpers ────────────────────────────────────────────────────────

  /// Get the chat document reference for an order
  DocumentReference _orderChatDoc(String orderId) {
    return _firestore.collection('chats').doc('order_$orderId');
  }

  /// Get the messages subcollection for an order chat
  CollectionReference _orderMessagesRef(String orderId) {
    return _orderChatDoc(orderId).collection('messages');
  }

  /// Get the chat document reference for a direct chat
  DocumentReference _directChatDoc(String chatId) {
    return _firestore.collection('chats').doc(chatId);
  }

  /// Get the messages subcollection for a direct chat
  CollectionReference _directMessagesRef(String chatId) {
    return _directChatDoc(chatId).collection('messages');
  }

  // ── Streams (real-time) ────────────────────────────────────────────

  /// Stream messages for an order chat
  Stream<List<Map<String, dynamic>>> orderMessagesStream(String orderId) {
    return _orderMessagesRef(orderId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  /// Stream messages for a direct chat
  Stream<List<Map<String, dynamic>>> directMessagesStream(String chatId) {
    return _directMessagesRef(chatId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  // ── Send Messages ──────────────────────────────────────────────────

  /// Send a message in an order chat
  Future<void> sendOrderMessage({
    required String orderId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
  }) async {
    try {
      // Ensure chat document exists
      await _orderChatDoc(orderId).set({
        'type': 'order',
        'orderId': orderId,
        'lastMessage': message,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastSenderId': senderId,
        'lastSenderName': senderName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Add message
      await _orderMessagesRef(orderId).add({
        'senderId': senderId,
        'senderName': senderName,
        'senderRole': senderRole,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      AppLogger.info('Order message sent: $orderId');
    } catch (e) {
      AppLogger.error('Error sending order message', error: e);
      rethrow;
    }
  }

  /// Send a message in a direct chat
  Future<void> sendDirectMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
    required List<String> participants,
  }) async {
    try {
      // Ensure chat document exists
      await _directChatDoc(chatId).set({
        'type': 'direct',
        'participants': participants,
        'lastMessage': message,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastSenderId': senderId,
        'lastSenderName': senderName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Add message
      await _directMessagesRef(chatId).add({
        'senderId': senderId,
        'senderName': senderName,
        'senderRole': senderRole,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      AppLogger.info('Direct message sent: $chatId');
    } catch (e) {
      AppLogger.error('Error sending direct message', error: e);
      rethrow;
    }
  }

  // ── Fetch User Chats ──────────────────────────────────────────────

  /// Get all chats for a user (both order and direct)
  Stream<List<Map<String, dynamic>>> userChatsStream(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  // ── Mark as Read ──────────────────────────────────────────────────

  /// Mark a message as read
  Future<void> markAsRead({
    required String chatId,
    required String messageId,
    bool isOrderChat = false,
  }) async {
    try {
      final ref = isOrderChat
          ? _orderMessagesRef(chatId).doc(messageId)
          : _directMessagesRef(chatId).doc(messageId);
      await ref.update({'isRead': true});
    } catch (e) {
      AppLogger.error('Error marking message as read', error: e);
    }
  }

  /// Mark all messages as read for a chat
  Future<void> markAllAsRead({
    required String chatId,
    required String userId,
    bool isOrderChat = false,
  }) async {
    try {
      final ref = isOrderChat ? _orderMessagesRef(chatId) : _directMessagesRef(chatId);
      final snapshot = await ref
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: userId)
          .get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      AppLogger.error('Error marking all as read', error: e);
    }
  }

  /// Get unread count for a chat
  Future<int> getUnreadCount(String chatId, String userId, {bool isOrderChat = false}) async {
    try {
      final ref = isOrderChat ? _orderMessagesRef(chatId) : _directMessagesRef(chatId);
      final snapshot = await ref
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: userId)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      AppLogger.error('Error getting unread count', error: e);
      return 0;
    }
  }
}