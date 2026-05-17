import 'package:flutter/foundation.dart';

class OrderChatService extends ChangeNotifier {
  static final OrderChatService _instance = OrderChatService._internal();

  factory OrderChatService() {
    return _instance;
  }

  OrderChatService._internal();

  // Map of orderId -> List of messages
  final Map<String, List<Map<String, dynamic>>> _orderChats = {};

  /// Get all messages for an order
  List<Map<String, dynamic>> getOrderMessages(String orderId) {
    return List.unmodifiable(_orderChats[orderId] ?? []);
  }

  /// Send a message in order chat
  Future<void> sendMessage({
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

      print('Message sent in order $orderId: $message');
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  /// Mark message as read
  Future<void> markMessageAsRead(String orderId, String messageId) async {
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
      print('Error marking message as read: $e');
    }
  }

  /// Mark all messages as read for an order
  Future<void> markAllMessagesAsRead(String orderId) async {
    try {
      final messages = _orderChats[orderId];
      if (messages != null) {
        for (var message in messages) {
          message['isRead'] = true;
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  /// Get unread message count for an order
  int getUnreadCount(String orderId) {
    final messages = _orderChats[orderId] ?? [];
    return messages.where((msg) => !msg['isRead']).length;
  }

  /// Get the last message for an order
  Map<String, dynamic>? getLastMessage(String orderId) {
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

  /// Clear all chats (useful for testing)
  void clearAllChats() {
    _orderChats.clear();
    notifyListeners();
  }

  /// Delete a specific order's chat
  void deleteOrderChat(String orderId) {
    _orderChats.remove(orderId);
    notifyListeners();
  }
}
