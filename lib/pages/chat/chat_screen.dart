import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/providers/user_provider.dart';

/// Direct chat screen for store chats and admin chats.
/// Also supports order chat mode with Mark as Complete buttons.
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

  // Sample messages for UI demo
  final List<Map<String, dynamic>> _sampleMessages = [];
  bool _customerConfirmed = false;
  bool _sellerConfirmed = false;
  bool _isCompleted = false;
  bool _isFollowUpMode = false;

  @override
  void initState() {
    super.initState();
    _loadSampleMessages();
  }

  void _loadSampleMessages() {
    _sampleMessages.addAll([
      {
        'isMe': false,
        'message': 'Hi! I\'m interested in your product.',
        'time': '10:30 AM',
        'senderName': widget.otherParticipantName,
      },
      {
        'isMe': true,
        'message': 'Hello! Yes, it\'s still available.',
        'time': '10:32 AM',
        'senderName': 'You',
      },
      {
        'isMe': false,
        'message': 'Great, I\'d like to place an order.',
        'time': '10:35 AM',
        'senderName': widget.otherParticipantName,
      },
    ]);
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _sampleMessages.add({
        'isMe': true,
        'message': text,
        'time': 'Just now',
        'senderName': 'You',
      });
      _messageController.clear();
    });

    // Auto-scroll to bottom
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
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSeller = userState.role == 'seller';
    final isCustomer = userState.role == 'customer';

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
            if (widget.isOrderChat)
              Text(
                _isCompleted ? 'Completed' : _isFollowUpMode ? 'Follow-up' : 'Active',
                style: TextStyle(
                  fontSize: 12,
                  color: _isCompleted
                      ? AppColors.success
                      : AppColors.primary,
                ),
              ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Order Chat Controls (only for order chats) ─────────────
          if (widget.isOrderChat && !_isCompleted && !_isFollowUpMode)
            _buildOrderControls(isSeller, isCustomer),

          // ── Completion Banner ─────────────────────────────────────
          if (_isCompleted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.success.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Order completed',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (isCustomer)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isCompleted = false;
                          _isFollowUpMode = true;
                        });
                      },
                      child: const Text('Follow-up'),
                    ),
                ],
              ),
            ),

          // ── Messages ──────────────────────────────────────────────
          Expanded(
            child: _sampleMessages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: AppColors.secondaryText,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        const Text(
                          'Send a message to start chatting',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _sampleMessages.length,
                    itemBuilder: (context, index) {
                      final msg = _sampleMessages[index];
                      return _buildMessageBubble(msg, isDark);
                    },
                  ),
          ),

          // ── Message Input ─────────────────────────────────────────
          if (!_isCompleted || _isFollowUpMode)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.getSurface(context),
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.darkSecondaryText.withValues(alpha: 0.2)
                        : AppColors.lightGrey,
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
                          color: isDark
                              ? const Color(0xFF3A3A3A)
                              : AppColors.lightGrey,
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: AppColors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
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
                      child: const Icon(
                        Icons.send,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderControls(bool isSeller, bool isCustomer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        border: Border(
          bottom: BorderSide(
            color: AppColors.lightGrey.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildConfirmationChip(
                  label: 'Customer confirmed',
                  confirmed: _customerConfirmed,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildConfirmationChip(
                  label: 'Seller confirmed',
                  confirmed: _sellerConfirmed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isSeller && !_sellerConfirmed)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _sellerConfirmed = true;
                    _checkBothConfirmed();
                  });
                },
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
          if (isCustomer && !_customerConfirmed)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _customerConfirmed = true;
                    _checkBothConfirmed();
                  });
                },
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
        ],
      ),
    );
  }

  Widget _buildConfirmationChip({required String label, required bool confirmed}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: confirmed
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.grey.withValues(alpha: 0.1),
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

  void _checkBothConfirmed() {
    if (_customerConfirmed && _sellerConfirmed) {
      setState(() {
        _isCompleted = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Order completed!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isDark) {
    final isMe = msg['isMe'] as bool;
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
                  msg['senderName'],
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
                color: isMe
                    ? AppColors.primary
                    : isDark
                        ? AppColors.darkCards
                        : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: isDark
                    ? []
                    : [
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
                    msg['message'],
                    style: TextStyle(
                      fontSize: 15,
                      color: isMe ? AppColors.white : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg['time'],
                    style: TextStyle(
                      fontSize: 11,
                      color: isMe
                          ? AppColors.white.withValues(alpha: 0.7)
                          : AppColors.secondaryText,
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
}