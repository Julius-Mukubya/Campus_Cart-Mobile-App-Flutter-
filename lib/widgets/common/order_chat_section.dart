import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/providers/chat_provider.dart';
import 'package:madpractical/providers/order_provider.dart';
import 'package:madpractical/providers/user_provider.dart';

/// Embedded chat section for order details screens.
/// Shows real-time messages, Mark as Complete buttons (dual confirmation),
/// confirmation status, and Follow-up button on completed orders.
class OrderChatSection extends ConsumerStatefulWidget {
  final String orderId;
  final String otherParticipantName;
  final Map<String, dynamic> order;

  const OrderChatSection({
    super.key,
    required this.orderId,
    required this.otherParticipantName,
    required this.order,
  });

  @override
  ConsumerState<OrderChatSection> createState() => _OrderChatSectionState();
}

class _OrderChatSectionState extends ConsumerState<OrderChatSection> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isChatInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isChatInitialized) {
        ref.read(chatProvider.notifier).startOrderMessagesStream(widget.orderId);
        _isChatInitialized = true;
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

    // Collect participants so order chat appears in chat list
    final participants = <String>[
      user.userId!,
      if (widget.order['customerId'] != null &&
          widget.order['customerId'].toString() != user.userId)
        widget.order['customerId'].toString(),
      if (widget.order['sellerId'] != null &&
          widget.order['sellerId'].toString() != user.userId)
        widget.order['sellerId'].toString(),
    ];

    ref.read(chatProvider.notifier).sendOrderMessage(
      orderId: widget.orderId,
      senderId: user.userId!,
      senderName: user.name,
      senderRole: user.role,
      message: text,
      participants: participants,
    );

    _messageController.clear();

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

  bool get _canChat {
    final status = (widget.order['status'] ?? 'pending').toString();
    if (status == 'completed') {
      return widget.order['followUp'] == true;
    }
    return status != 'rejected' && status != 'cancelled';
  }

  bool get _showChatInput => _canChat;

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final chatState = ref.watch(chatProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final messages = chatState.orderMessages;
    final isLoading = chatState.streamingOrder;

    final status = (widget.order['status'] ?? 'pending').toString();
    final sellerConfirmed = widget.order['sellerConfirmed'] == true;
    final customerConfirmed = widget.order['customerConfirmed'] == true;
    final isCompleted = status == 'completed';
    final isCustomer = userState.role == 'customer';
    final isSeller = userState.role == 'seller';

    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  'Chat with ${widget.otherParticipantName}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),

          // ── Dual Confirmation Status ──────────────────────────────
          if (status == 'accepted' || status == 'completed')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
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
                      label: isCustomer ? 'You confirmed' : 'Customer confirmed',
                      confirmed: customerConfirmed,
                    ),
                  ),
                ],
              ),
            ),

          // ── Mark as Complete Button (for accepted orders) ──────────
          if (status == 'accepted') ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (isSeller && !sellerConfirmed) || (isCustomer && !customerConfirmed)
                      ? _markComplete
                      : null,
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Mark as Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],

          // ── Completed Banner + Follow-up ───────────────────────────
          if (isCompleted) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.order['followUp'] == true
                            ? 'Follow-up enabled — chat is active'
                            : 'Order completed',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isCustomer && widget.order['followUp'] != true) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _enableFollowUp,
                    icon: const Icon(Icons.replay, size: 18),
                    label: const Text('Follow-up'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],

          const Divider(height: 24),

          // ── Messages List ─────────────────────────────────────────
          SizedBox(
            height: 300, // Fixed height for scrollable messages
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
                            Icon(Icons.chat_bubble_outline, size: 36, color: AppColors.secondaryText),
                            const SizedBox(height: 8),
                            Text(
                              'No messages yet',
                              style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
                            ),
                            if (_showChatInput)
                              const Text(
                                'Send a message to start chatting',
                                style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isMe = msg.senderId == userState.userId;
                          return _buildMessageBubble(msg, isMe, isDark);
                        },
                      ),
          ),

          // ── Message Input ──────────────────────────────────────────
          if (_showChatInput) ...[
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.all(12),
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: AppColors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Chat Disabled Notice ──────────────────────────────────
          if (!_showChatInput && !isCompleted) ...[
            const Divider(height: 1),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Chat is not available for this order',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.grey, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfirmationChip({required String label, required bool confirmed}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: confirmed ? AppColors.success.withValues(alpha: 0.1) : AppColors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            confirmed ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: confirmed ? AppColors.success : AppColors.grey,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 2),
                child: Text(
                  msg.senderName ?? 'User',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : isDark ? AppColors.darkCards : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isMe ? 14 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 14),
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
                      fontSize: 14,
                      color: isMe ? AppColors.white : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(msg.timestamp),
                    style: TextStyle(
                      fontSize: 10,
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

  void _markComplete() {
    final isSeller = ref.read(userProvider).role == 'seller';
    if (isSeller) {
      ref.read(orderProvider.notifier).markSellerComplete(widget.orderId);
    } else {
      ref.read(orderProvider.notifier).markCustomerComplete(widget.orderId);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Marked as complete! Waiting for the other party.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _enableFollowUp() {
    ref.read(orderProvider.notifier).enableFollowUp(widget.orderId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Follow-up enabled! Chat is now active.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}