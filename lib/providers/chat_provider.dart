import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madpractical/repositories/chat_repository.dart';

/// Chat message state model
class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, String chatId) {
    return ChatMessage(
      id: map['id'] ?? '',
      chatId: chatId,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderRole: map['senderRole'] ?? '',
      message: map['message'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'senderRole': senderRole,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
      };
}

/// Chat list item (for chat list screen)
class ChatListItem {
  final String id;
  final String otherParticipantName;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isOrderChat;

  const ChatListItem({
    required this.id,
    required this.otherParticipantName,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isOrderChat = false,
  });
}

/// Chat state
class ChatState {
  final List<ChatMessage> orderMessages;
  final List<ChatMessage> directMessages;
  final List<ChatListItem> chatList;
  final bool isLoading;
  final String? error;

  const ChatState({
    this.orderMessages = const [],
    this.directMessages = const [],
    this.chatList = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? orderMessages,
    List<ChatMessage>? directMessages,
    List<ChatListItem>? chatList,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      orderMessages: orderMessages ?? this.orderMessages,
      directMessages: directMessages ?? this.directMessages,
      chatList: chatList ?? this.chatList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// ChatNotifier - handles chat state
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _chatRepository = ChatRepository();

  ChatNotifier() : super(const ChatState());

  /// Load messages for an order chat
  void loadOrderMessages(String orderId) {
    _chatRepository.initializeOrderChat(orderId);
    final rawMessages = _chatRepository.getOrderMessages(orderId);
    final messages = rawMessages
        .map((m) => ChatMessage.fromMap(m, orderId))
        .toList();
    state = state.copyWith(orderMessages: messages);
  }

  /// Load messages for a direct chat
  void loadDirectMessages(String chatId) {
    _chatRepository.initializeDirectChat(chatId);
    final rawMessages = _chatRepository.getDirectMessages(chatId);
    final messages = rawMessages
        .map((m) => ChatMessage.fromMap(m, chatId))
        .toList();
    state = state.copyWith(directMessages: messages);
  }

  /// Send a message in an order chat
  Future<void> sendOrderMessage({
    required String orderId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
  }) async {
    if (message.trim().isEmpty) return;
    state = state.copyWith(isLoading: true);
    try {
      await _chatRepository.sendOrderMessage(
        orderId: orderId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        message: message.trim(),
      );
      loadOrderMessages(orderId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to send message');
    }
  }

  /// Send a message in a direct chat
  Future<void> sendDirectMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
  }) async {
    if (message.trim().isEmpty) return;
    state = state.copyWith(isLoading: true);
    try {
      await _chatRepository.sendDirectMessage(
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        message: message.trim(),
      );
      loadDirectMessages(chatId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to send message');
    }
  }

  /// Load the chat list for the current user
  void loadChatList() {
    // This is a stub. In production, this would fetch from Firestore.
    // For now, we return an empty list.
    state = state.copyWith(chatList: []);
  }
}

/// Chat provider
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});