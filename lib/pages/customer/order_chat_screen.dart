import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/chat_service.dart';

class OrderChatScreen extends StatefulWidget {
  final String orderId;
  final String customerName;
  final String customerPhone;
  final String shippingAddress;
  final String currentUserId;
  final String currentUserName;
  final String userRole; // 'buyer' or 'seller'

  const OrderChatScreen({
    super.key,
    required this.orderId,
    required this.customerName,
    required this.customerPhone,
    required this.shippingAddress,
    required this.currentUserId,
    required this.currentUserName,
    required this.userRole,
  });

  @override
  State<OrderChatScreen> createState() => _OrderChatScreenState();
}

class _OrderChatScreenState extends State<OrderChatScreen> {
  final OrderChatService _chatService = OrderChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _chatService.initializeOrderChat(widget.orderId);
    _chatService.markAllMessagesAsRead(widget.orderId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    _chatService.sendMessage(
      orderId: widget.orderId,
      senderId: widget.currentUserId,
      senderName: widget.currentUserName,
      senderRole: widget.userRole,
      message: _messageController.text.trim(),
    );

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Chat'),
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Contact Information Card
          Container(
            color: AppColors.primary.withValues(alpha: 0.05),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order ${widget.orderId}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildContactRow('Customer', widget.customerName),
                _buildContactRow('Phone', widget.customerPhone),
                _buildContactRow(
                  'Address',
                  widget.shippingAddress,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Chat Messages
          Expanded(
            child: ListenableBuilder(
              listenable: _chatService,
              builder: (context, _) {
                final messages =
                    _chatService.getOrderMessages(widget.orderId);

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet. Start the conversation!',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSender = message['senderId'] == widget.currentUserId;

                    return Align(
                      alignment: isSender
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isSender
                              ? AppColors.primary
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: isSender
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['senderName'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSender ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message['message'],
                              style: TextStyle(
                                fontSize: 14,
                                color: isSender ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(message['timestamp']),
                              style: TextStyle(
                                fontSize: 11,
                                color: isSender
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          // Message Input
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return 'unknown';
    }
  }
}
