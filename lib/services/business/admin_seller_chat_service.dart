import 'package:flutter/foundation.dart';
import '../../utils/app_logger.dart';

class AdminSellerChatService extends ChangeNotifier {
  static final AdminSellerChatService _instance =
      AdminSellerChatService._internal();

  factory AdminSellerChatService() {
    return _instance;
  }

  AdminSellerChatService._internal();

  // Map of sellerId -> List of messages
  final Map<String, List<Map<String, dynamic>>> _adminSellerChats = {};

  /// Get all messages between admin and a seller
  List<Map<String, dynamic>> getAdminSellerMessages(String sellerId) {
    return List.unmodifiable(_adminSellerChats[sellerId] ?? []);
  }

  /// Send message from admin or seller
  Future<void> sendMessage({
    required String sellerId,
    required String senderId, // adminId or sellerId
    required String senderName,
    required String senderRole, // 'admin' or 'seller'
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

  /// Mark message as read
  Future<void> markMessageAsRead(String sellerId, String messageId) async {
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
  Future<void> markAllMessagesAsRead(String sellerId) async {
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
  int getUnreadCount(String sellerId) {
    final messages = _adminSellerChats[sellerId] ?? [];
    return messages.where((msg) => !msg['isRead']).length;
  }

  /// Get the last message for a seller
  Map<String, dynamic>? getLastMessage(String sellerId) {
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

  /// Clear all chats (useful for testing)
  void clearAllChats() {
    _adminSellerChats.clear();
    notifyListeners();
  }

  /// Delete a specific seller's chat
  void deleteSellerChat(String sellerId) {
    _adminSellerChats.remove(sellerId);
    notifyListeners();
  }
}
