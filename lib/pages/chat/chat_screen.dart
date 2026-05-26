import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/providers/chat_provider.dart';
import 'package:madpractical/providers/order_provider.dart';
import 'package:madpractical/providers/user_provider.dart';

/// Chat screen that works for both order chats and direct chats.
/// Uses Firestore-backed real-time streams.
class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String otherParticipantName;
  final bool isOrderChat;

  const ChatScreen({
    super.key,
    required this.chatId,
    this.otherParticipantName = 'User',
    this.isOrderChat = false,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Start streaming the appropriate chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isOrderChat) {
        ref.read(chatProvider.notifier).startOrderMessagesStream(widget.chatId);
      } else {
        ref.read(chatProvider.notifier).startDirectMessagesStream(widget.chatId);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(userProvider);
    if (user.userId == null || user.userId!.isEmpty) return;

    if (widget.isOrderChat) {
      ref.read(chatProvider.notifier).sendOrderMessage(
        orderId: widget.chatId,
        senderId: user.userId!,
        senderName: user.name,
        senderRole: user.role,
        message: text,
      );
    } else {
      // Extract the other participant from the chatId format: direct_{id1}_{id2}
      final parts = widget.chatId.split('_');
      final otherUserId = parts.length >= 3
          ? (parts[1] == user.userId ? parts[2] : parts[1])
          : user.userId!;
      ref.read(chatProvider.notifier).sendDirectMessage(
        chatId: widget.chatId,
        senderId: user.userId!,
        senderName: user.name,
        senderRole: user.role,
        message: text,
        participants: [user.userId!, otherUserId],
      );
    }

    _messageController.clear();

    // Auto-scroll to bottom
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final chatState = ref.watch(chatProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final messages = widget.isOrderChat ? chatState.orderMessages : chatState.directMessages;
    final isLoading = widget.isOrderChat ? chatState.streamingOrder : chatState.streamingDirect;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.getBackground(context),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.getSurface(context),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios, size: 16),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.otherParticipantName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Order Chat Controls (only for order chats) ─────────────
          if (widget.isOrderChat)
            _buildOrderChatControls(),

          // ── Messages ──────────────────────────────────────────────
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.secondaryText),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(fontSize: 16, color: AppColors.secondaryText),
                            ),
                            const Text(
                              'Send a message to start chatting',
                              style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isMe = msg.senderId == userState.userId;
                          return _buildMessageBubble(msg, isMe, isDark);
                        },
                      ),
          ),

          // ── Message Input ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.getSurface(context),
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkSecondaryText.withValues(alpha: 0.2) : AppColors.lightGrey,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.getBackground(context),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? const Color(0xFF3A3A3A) : AppColors.lightGrey,
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: AppColors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: AppColors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderChatControls() {
    // For order chats, get the order's current completion status from the order provider
    // This would be better handled by passing the order data, but since this is a general
    // chat screen, we read from the existing order state
    final userState = ref.watch(userProvider);
    final isSeller = userState.role == 'seller';
    final isCustomer = userState.role == 'customer';

    // Find the order in the provider's state
    final orderState = ref.watch(orderProvider);
    final order = orderState.orders.firstWhere(
      (o) => (o['orderId'] ?? o['id']) == widget.chatId,
      orElse: () => <String, dynamic>{},
    );
    final status = (order['status'] ?? '').toString();
    final sellerConfirmed = order['sellerConfirmed'] == true;
    final customerConfirmed = order['customerConfirmed'] == true;
    final isCompleted = status == 'completed';

    if (isCompleted) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        border: Border(
          bottom: BorderSide(color: AppColors.lightGrey.withValues(alpha: 0.5)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildConfirmationChip(
                  label: 'Seller confirmed',
                  confirmed: sellerConfirmed,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildConfirmationChip(
                  label: 'Customer confirmed',
                  confirmed: customerConfirmed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isSeller && !sellerConfirmed)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(orderProvider.notifier).markSellerComplete(widget.chatId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Marked as complete. Waiting for customer.'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Mark as Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          if (isCustomer && !customerConfirmed)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(orderProvider.notifier).markCustomerComplete(widget.chatId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Marked as complete. Waiting for seller.'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Mark as Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConfirmationChip({required String label, required bool confirmed}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: confirmed ? AppColors.success.withValues(alpha: 0.1) : AppColors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            confirmed ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: confirmed ? AppColors.success : AppColors.grey,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: confirmed ? AppColors.success : AppColors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic msg, bool isMe, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  msg.senderName ?? 'User',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : isDark ? AppColors.darkCards : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: isDark ? [] : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.message,
                    style: TextStyle(
                      fontSize: 15,
                      color: isMe ? AppColors.white : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(msg.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: isMe ? AppColors.white.withValues(alpha: 0.7) : AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    if (timestamp is DateTime) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
    return timestamp.toString();
  }
}