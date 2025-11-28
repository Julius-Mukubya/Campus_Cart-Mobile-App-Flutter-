import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/notification_manager.dart';

class NotificationsListScreen extends StatefulWidget {
  const NotificationsListScreen({super.key});

  @override
  State<NotificationsListScreen> createState() => _NotificationsListScreenState();
}

class _NotificationsListScreenState extends State<NotificationsListScreen> {
  final NotificationManager _notificationManager = NotificationManager();

  @override
  void initState() {
    super.initState();
    _notificationManager.addListener(_onNotificationsChanged);
  }

  @override
  void dispose() {
    _notificationManager.removeListener(_onNotificationsChanged);
    super.dispose();
  }

  void _onNotificationsChanged() {
    setState(() {});
  }

  Color _getColorFromString(dynamic colorName) {
    if (colorName is Color) return colorName;
    final String colorStr = colorName.toString();
    switch (colorStr.toLowerCase()) {
      case 'success':
        return AppColors.success;
      case 'primary':
        return AppColors.primary;
      case 'accent':
        return AppColors.accent;
      case 'error':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'check_circle':
        return Icons.check_circle;
      case 'local_offer':
        return Icons.local_offer;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'trending_down':
        return Icons.trending_down;
      case 'new_releases':
        return Icons.new_releases;
      default:
        return Icons.notifications;
    }
  }

  // Keep the old list for reference but use manager
  final List<Map<String, dynamic>> _oldNotifications = [
    {
      'id': '1',
      'title': 'Order Delivered',
      'message': 'Your order #ORD-2024-001 has been delivered successfully',
      'type': 'order',
      'time': '2 hours ago',
      'isRead': false,
      'icon': Icons.check_circle,
      'color': AppColors.success,
    },
    {
      'id': '2',
      'title': 'Special Offer',
      'message': 'Get 30% off on all electronics! Limited time offer.',
      'type': 'promotion',
      'time': '5 hours ago',
      'isRead': false,
      'icon': Icons.local_offer,
      'color': AppColors.accent,
    },
    {
      'id': '3',
      'title': 'Order Shipped',
      'message': 'Your order #ORD-2024-002 is on the way',
      'type': 'order',
      'time': '1 day ago',
      'isRead': true,
      'icon': Icons.local_shipping,
      'color': AppColors.primary,
    },
    {
      'id': '4',
      'title': 'Price Drop Alert',
      'message': 'Smart Watch in your wishlist is now 15% off!',
      'type': 'price_drop',
      'time': '2 days ago',
      'isRead': true,
      'icon': Icons.trending_down,
      'color': AppColors.success,
    },
    {
      'id': '5',
      'title': 'New Arrival',
      'message': 'Check out the latest collection of designer t-shirts',
      'type': 'new_arrival',
      'time': '3 days ago',
      'isRead': true,
      'icon': Icons.new_releases,
      'color': AppColors.primary,
    },
  ];

  int get unreadCount => _notificationManager.unreadCount;
  List<Map<String, dynamic>> get _notifications => _notificationManager.notifications;

  void _markAsRead(String id) {
    _notificationManager.markAsRead(id);
  }

  void _markAllAsRead() {
    _notificationManager.markAllAsRead();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All notifications marked as read'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _deleteNotification(String id) {
    _notificationManager.deleteNotification(id);
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All Notifications?'),
        content: const Text('This will delete all your notifications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _notificationManager.clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All notifications cleared'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.text,
              size: 16,
            ),
          ),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        actions: [
          if (_notifications.isNotEmpty)
            PopupMenuButton(
              icon: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.more_vert,
                  color: AppColors.text,
                  size: 20,
                ),
              ),
              itemBuilder: (context) => [
                if (unreadCount > 0)
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.done_all, size: 18),
                        SizedBox(width: 8),
                        Text('Mark All as Read'),
                      ],
                    ),
                    onTap: () {
                      Future.delayed(Duration.zero, _markAllAsRead);
                    },
                  ),
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.delete_sweep, size: 18),
                      SizedBox(width: 8),
                      Text('Clear All'),
                    ],
                  ),
                  onTap: () {
                    Future.delayed(Duration.zero, _clearAll);
                  },
                ),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_notifications.isNotEmpty && unreadCount > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Text(
                  '$unreadCount unread notification${unreadCount > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Expanded(
              child: _notifications.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.notifications_off_outlined,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No Notifications',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You\'re all caught up!\nWe\'ll notify you when something new arrives.',
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
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return Dismissible(
                    key: Key(notification['id']),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(
                        Icons.delete,
                        color: AppColors.white,
                      ),
                    ),
                    onDismissed: (direction) {
                      _deleteNotification(notification['id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Notification deleted'),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    child: InkWell(
                      onTap: () {
                        if (!notification['isRead']) {
                          _markAsRead(notification['id']);
                        }
                        // Handle notification tap - navigate to relevant screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Opening ${notification['title']}'),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: notification['isRead'] 
                              ? AppColors.white 
                              : AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: notification['isRead']
                              ? null
                              : Border.all(
                                  color: AppColors.primary.withOpacity(0.2),
                                  width: 1,
                                ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _getColorFromString(notification['color']).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getIconFromString(notification['icon']),
                                  color: _getColorFromString(notification['color']),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            notification['title'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: notification['isRead']
                                                  ? FontWeight.w600
                                                  : FontWeight.bold,
                                              color: AppColors.text,
                                            ),
                                          ),
                                        ),
                                        if (!notification['isRead'])
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      notification['message'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.secondaryText,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 12,
                                          color: AppColors.secondaryText,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          notification['time'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
