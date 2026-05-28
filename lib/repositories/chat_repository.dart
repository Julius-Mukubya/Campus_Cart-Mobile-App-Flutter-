import 'dart:async';
import 'package:madpractical/services/chat_service.dart';
import 'package:madpractical/utils/app_logger.dart';

/// Repository for chat operations.
/// Wraps Firestore-backed ChatService.
class ChatRepository {
  final ChatService _chatService = ChatService();

  // ── Streams ─────────────────────────────────────────────────────────

  /// Stream messages for an order chat
  Stream<List<Map<String, dynamic>>> orderMessagesStream(String orderId) {
    return _chatService.orderMessagesStream(orderId);
  }

  /// Stream messages for a direct chat
  Stream<List<Map<String, dynamic>>> directMessagesStream(String chatId) {
    return _chatService.directMessagesStream(chatId);
  }

  /// Stream all chats for a user
  Stream<List<Map<String, dynamic>>> userChatsStream(String userId) {
    return _chatService.userChatsStream(userId);
  }

  // ── Send Messages ───────────────────────────────────────────────────

  /// Send a message in an order chat
  Future<void> sendOrderMessage({
    required String orderId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
    List<String> participants = const [],
  }) async {
    try {
      await _chatService.sendOrderMessage(
        orderId: orderId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        message: message,
        participants: participants,
      );
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
      await _chatService.sendDirectMessage(
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        message: message,
        participants: participants,
      );
    } catch (e) {
      AppLogger.error('Error sending direct message', error: e);
      rethrow;
    }
  }

  // ── Mark as Read ────────────────────────────────────────────────────

  /// Mark all messages as read
  Future<void> markAllAsRead({
    required String chatId,
    required String userId,
    bool isOrderChat = false,
  }) async {
    await _chatService.markAllAsRead(
      chatId: chatId,
      userId: userId,
      isOrderChat: isOrderChat,
    );
  }

  /// Get unread count
  Future<int> getUnreadCount(String chatId, String userId, {bool isOrderChat = false}) async {
    return _chatService.getUnreadCount(chatId, userId, isOrderChat: isOrderChat);
  }
}