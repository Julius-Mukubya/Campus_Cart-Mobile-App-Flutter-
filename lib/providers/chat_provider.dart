import 'dart:async';
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
      timestamp: (map['timestamp'] as dynamic)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }
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
  final bool streamingOrder;
  final bool streamingDirect;

  const ChatState({
    this.orderMessages = const [],
    this.directMessages = const [],
    this.chatList = const [],
    this.isLoading = false,
    this.error,
    this.streamingOrder = false,
    this.streamingDirect = false,
  });

  ChatState copyWith({
    List<ChatMessage>? orderMessages,
    List<ChatMessage>? directMessages,
    List<ChatListItem>? chatList,
    bool? isLoading,
    String? error,
    bool? streamingOrder,
    bool? streamingDirect,
  }) {
    return ChatState(
      orderMessages: orderMessages ?? this.orderMessages,
      directMessages: directMessages ?? this.directMessages,
      chatList: chatList ?? this.chatList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      streamingOrder: streamingOrder ?? this.streamingOrder,
      streamingDirect: streamingDirect ?? this.streamingDirect,
    );
  }
}

/// ChatNotifier - handles chat state with real-time Firestore streams
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _chatRepository = ChatRepository();
  StreamSubscription? _orderMessagesSub;
  StreamSubscription? _directMessagesSub;
  StreamSubscription? _chatListSub;

  ChatNotifier() : super(const ChatState());

  @override
  void dispose() {
    _orderMessagesSub?.cancel();
    _directMessagesSub?.cancel();
    _chatListSub?.cancel();
    super.dispose();
  }

  /// Start streaming messages for an order chat
  void startOrderMessagesStream(String orderId) {
    _orderMessagesSub?.cancel();
    state = state.copyWith(streamingOrder: true);
    _orderMessagesSub = _chatRepository.orderMessagesStream(orderId).listen(
      (rawMessages) {
        final messages = rawMessages
            .map((m) => ChatMessage.fromMap(m, orderId))
            .toList();
        if (mounted) {
          state = state.copyWith(orderMessages: messages, streamingOrder: false);
        }
      },
      onError: (e) {
        state = state.copyWith(error: 'Failed to load messages: $e', streamingOrder: false);
      },
    );
  }

  /// Start streaming messages for a direct chat
  void startDirectMessagesStream(String chatId) {
    _directMessagesSub?.cancel();
    state = state.copyWith(streamingDirect: true);
    _directMessagesSub = _chatRepository.directMessagesStream(chatId).listen(
      (rawMessages) {
        final messages = rawMessages
            .map((m) => ChatMessage.fromMap(m, chatId))
            .toList();
        if (mounted) {
          state = state.copyWith(directMessages: messages, streamingDirect: false);
        }
      },
      onError: (e) {
        state = state.copyWith(error: 'Failed to load messages: $e', streamingDirect: false);
      },
    );
  }

  /// Start streaming the chat list for a user
  void startChatListStream(String userId) {
    _chatListSub?.cancel();
    state = state.copyWith(isLoading: true);
    _chatListSub = _chatRepository.userChatsStream(userId).listen(
      (chats) {
        final chatList = chats.map((chat) {
          final data = chat;
          final isOrder = data['type'] == 'order';
          final name = isOrder
              ? 'Order ${data['orderId'] ?? ''}'
              : data['lastSenderName'] ?? 'User';
          return ChatListItem(
            id: data['id'] ?? '',
            otherParticipantName: name,
            lastMessage: data['lastMessage'],
            lastMessageTime: (data['lastMessageAt'] as dynamic)?.toDate(),
            isOrderChat: isOrder,
          );
        }).toList();
        if (mounted) {
          state = state.copyWith(chatList: chatList, isLoading: false);
        }
      },
      onError: (e) {
        state = state.copyWith(error: 'Failed to load chats: $e', isLoading: false);
      },
    );
  }

  /// Stop all streams
  void stopAllStreams() {
    _orderMessagesSub?.cancel();
    _directMessagesSub?.cancel();
    _chatListSub?.cancel();
  }

  /// Send a message in an order chat
  Future<void> sendOrderMessage({
    required String orderId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
    List<String> participants = const [],
  }) async {
    if (message.trim().isEmpty) return;
    try {
      await _chatRepository.sendOrderMessage(
        orderId: orderId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        message: message.trim(),
        participants: participants,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to send message');
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
    if (message.trim().isEmpty) return;
    try {
      await _chatRepository.sendDirectMessage(
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        message: message.trim(),
        participants: participants,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to send message');
    }
  }
}

/// Chat provider
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});