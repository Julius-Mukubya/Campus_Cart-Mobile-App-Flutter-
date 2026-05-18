import 'package:flutter/foundation.dart';
import '../utils/app_logger.dart';

/// Merged ChatService combining order_chat_service and admin_seller_chat_service
class ChatService extends ChangeNotifier {
  static final ChatService _instance = ChatService._internal();

  factory ChatService() {
    return _instance;
  }

  ChatService._internal();

  // Map of orderId -> List of messages (for order chats)
  final Map<String, List<Map<String, dynamic>>> _orderChats = {};

  // Map of sellerId -> List of messages (for admin-seller chats)
  final Map<String, List<Map<String, dynamic>>> _adminSellerChats = {};

  // ======================================================================
  // ORDER CHAT METHODS (from order_chat_service.dart)
  // ======================================================================

  /// Get all messages for an order
  List<Map<String, dynamic>> getOrderMessages(String orderId) {
    return List.unmodifiable(_orderChats[orderId] ?? []);
  }

  /// Send a message in order chat
  Future<void> sendOrderMessage({
    required String orderId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
  }) async {
    try {
      final newMessage = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'orderId': orderId,
        'senderId': senderId,
        'senderName': senderName,
        'senderRole': senderRole,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      };

      if (!_orderChats.containsKey(orderId)) {
        _orderChats[orderId] = [];
      }

      _orderChats[orderId]!.add(newMessage);
      notifyListeners();

      AppLogger.info('Message sent in order $orderId: $message');
    } catch (e) {
      AppLogger.error('Error sending message', error: e);
    }
  }

  /// Mark order message as read
  Future<void> markOrderMessageAsRead(String orderId, String messageId) async {
    try {
      final messages = _orderChats[orderId];
      if (messages != null) {
        final messageIndex =
            messages.indexWhere((msg) => msg['id'] == messageId);
        if (messageIndex != -1) {
          messages[messageIndex]['isRead'] = true;
          notifyListeners();
        }
      }
    } catch (e) {
      AppLogger.error('Error marking message as read', error: e);
    }
  }

  /// Mark all messages as read for an order
  Future<void> markAllOrderMessagesAsRead(String orderId) async {
    try {
      final messages = _orderChats[orderId];
      if (messages != null) {
        for (var message in messages) {
          message['isRead'] = true;
        }
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Error marking messages as read', error: e);
    }
  }

  /// Get unread message count for an order
  int getOrderUnreadCount(String orderId) {
    final messages = _orderChats[orderId] ?? [];
    return messages.where((msg) => !msg['isRead']).length;
  }

  /// Get the last message for an order
  Map<String, dynamic>? getLastOrderMessage(String orderId) {
    final messages = _orderChats[orderId];
    if (messages?.isNotEmpty ?? false) {
      return messages!.last;
    }
    return null;
  }

  /// Initialize chat for a new order
  void initializeOrderChat(String orderId) {
    if (!_orderChats.containsKey(orderId)) {
      _orderChats[orderId] = [];
    }
  }

  /// Delete a specific order's chat
  void deleteOrderChat(String orderId) {
    _orderChats.remove(orderId);
    notifyListeners();
  }

  // ======================================================================
  // ADMIN-SELLER CHAT METHODS (from admin_seller_chat_service.dart)
  // ======================================================================

  /// Get all messages between admin and a seller
  List<Map<String, dynamic>> getAdminSellerMessages(String sellerId) {
    return List.unmodifiable(_adminSellerChats[sellerId] ?? []);
  }

  /// Send message from admin or seller
  Future<void> sendAdminSellerMessage({
    required String sellerId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
  }) async {
    try {
      final newMessage = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'sellerId': sellerId,
        'senderId': senderId,
        'senderName': senderName,
        'senderRole': senderRole,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      };

      if (!_adminSellerChats.containsKey(sellerId)) {
        _adminSellerChats[sellerId] = [];
      }

      _adminSellerChats[sellerId]!.add(newMessage);
      notifyListeners();

      AppLogger.info('Message sent in admin-seller chat with $sellerId: $message');
    } catch (e) {
      AppLogger.error('Error sending message', error: e);
    }
  }

  /// Mark admin-seller message as read
  Future<void> markAdminSellerMessageAsRead(String sellerId, String messageId) async {
    try {
      final messages = _adminSellerChats[sellerId];
      if (messages != null) {
        final messageIndex =
            messages.indexWhere((msg) => msg['id'] == messageId);
        if (messageIndex != -1) {
          messages[messageIndex]['isRead'] = true;
          notifyListeners();
        }
      }
    } catch (e) {
      AppLogger.error('Error marking message as read', error: e);
    }
  }

  /// Mark all messages as read for a seller
  Future<void> markAllAdminSellerMessagesAsRead(String sellerId) async {
    try {
      final messages = _adminSellerChats[sellerId];
      if (messages != null) {
        for (var message in messages) {
          message['isRead'] = true;
        }
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Error marking messages as read', error: e);
    }
  }

  /// Get unread message count for a seller chat
  int getAdminSellerUnreadCount(String sellerId) {
    final messages = _adminSellerChats[sellerId] ?? [];
    return messages.where((msg) => !msg['isRead']).length;
  }

  /// Get the last message for a seller
  Map<String, dynamic>? getLastAdminSellerMessage(String sellerId) {
    final messages = _adminSellerChats[sellerId];
    if (messages?.isNotEmpty ?? false) {
      return messages!.last;
    }
    return null;
  }

  /// Initialize chat for a new seller
  void initializeSellerChat(String sellerId) {
    if (!_adminSellerChats.containsKey(sellerId)) {
      _adminSellerChats[sellerId] = [];
    }
  }

  /// Get all sellers with active chats
  List<String> getActiveSellers() {
    return _adminSellerChats.keys.toList();
  }

  /// Delete a specific seller's chat
  void deleteSellerChat(String sellerId) {
    _adminSellerChats.remove(sellerId);
    notifyListeners();
  }

  /// Clear all chats (useful for testing)
  void clearAllChats() {
    _orderChats.clear();
    _adminSellerChats.clear();
    notifyListeners();
  }
}