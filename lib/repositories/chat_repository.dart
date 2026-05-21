import 'package:madpractical/services/chat_service.dart';
import 'package:madpractical/utils/app_logger.dart';

/// Repository for chat operations.
/// Currently wraps ChatService (in-memory).
/// Will be wired to Firestore in a future phase.
class ChatRepository {
  final ChatService _chatService = ChatService();

  /// Get all messages for an order chat
  List<Map<String, dynamic>> getOrderMessages(String orderId) {
    return _chatService.getOrderMessages(orderId);
  }

  /// Send a message in an order chat
  Future<void> sendOrderMessage({
    required String orderId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
  }) async {
    try {
      await _chatService.sendOrderMessage(
        orderId: orderId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        message: message,
      );
    } catch (e) {
      AppLogger.error('Error sending order message', error: e);
    }
  }

  /// Get all messages for an admin-seller or direct chat
  List<Map<String, dynamic>> getDirectMessages(String chatId) {
    return _chatService.getAdminSellerMessages(chatId);
  }

  /// Send a message in a direct chat
  Future<void> sendDirectMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
  }) async {
    try {
      await _chatService.sendAdminSellerMessage(
        sellerId: chatId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        message: message,
      );
    } catch (e) {
      AppLogger.error('Error sending direct message', error: e);
    }
  }

  /// Get the last message in an order chat
  Map<String, dynamic>? getLastOrderMessage(String orderId) {
    return _chatService.getLastOrderMessage(orderId);
  }

  /// Get the last message in a direct chat
  Map<String, dynamic>? getLastDirectMessage(String chatId) {
    return _chatService.getLastAdminSellerMessage(chatId);
  }

  /// Initialize a new order chat
  void initializeOrderChat(String orderId) {
    _chatService.initializeOrderChat(orderId);
  }

  /// Initialize a new direct chat
  void initializeDirectChat(String chatId) {
    _chatService.initializeSellerChat(chatId);
  }

  /// Get all active chat IDs (from order chats + direct chats)
  List<String> getActiveOrderChats() {
    // This is a simplification - in production, this would come from Firestore
    return [];
  }

  /// Get all active direct chat IDs
  List<String> getActiveDirectChats() {
    return _chatService.getActiveSellers();
  }
}