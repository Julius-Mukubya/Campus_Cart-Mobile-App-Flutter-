import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/providers/user_provider.dart';

/// Chat list screen showing all conversations for any user.
class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  // Sample chat data for UI demo
  final List<Map<String, dynamic>> _sampleChats = [];

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    // Show sample chats when no real chats exist
    _sampleChats.addAll([
      {
        'id': 'order_1',
        'name': 'Order #1001',
        'lastMessage': 'Your order has been confirmed',
        'time': '2m ago',
        'unread': 2,
        'isOrder': true,
        'icon': Icons.receipt_long,
      },
      {
        'id': 'direct_1',
        'name': 'John Seller',
        'lastMessage': 'Yes, the product is available',
        'time': '1h ago',
        'unread': 0,
        'isOrder': false,
        'icon': Icons.person,
      },
    ]);
  }

  String _formatTimestamp(String time) => time;

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: _sampleChats.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No Conversations',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your chats will appear here\nwhen you start a conversation.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.secondaryText,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _sampleChats.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final chat = _sampleChats[index];
                return _buildChatItem(chat, isDark);
              },
            ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: const Color(0xFF2A2A2A)) : null,
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (chat['isOrder'] as bool)
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            chat['icon'] as IconData,
            color: (chat['isOrder'] as bool)
                ? AppColors.primary
                : AppColors.accent,
            size: 24,
          ),
        ),
        title: Text(
          chat['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            chat['lastMessage'],
            style: TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              chat['time'],
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
              ),
            ),
            if ((chat['unread'] as int) > 0)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${chat['unread']}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/chat/${chat['id']}',
            arguments: {'name': chat['name']},
          );
        },
      ),
    );
  }
}