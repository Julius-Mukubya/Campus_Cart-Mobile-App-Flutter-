import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/notification_manager.dart';
import 'package:madpractical/pages/notifications_list_screen.dart';

class NotificationIcon extends StatelessWidget {
  final double size;
  final bool showBadge;

  const NotificationIcon({
    super.key,
    this.size = 24,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final notificationManager = NotificationManager();
    final unreadCount = notificationManager.unreadCount;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NotificationsListScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
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
        child: showBadge && unreadCount > 0
            ? Badge(
                label: Text('$unreadCount'),
                backgroundColor: AppColors.error,
                child: Icon(
                  Icons.notifications_outlined,
                  color: Theme.of(context).iconTheme.color,
                  size: size,
                ),
              )
            : Icon(
                Icons.notifications_outlined,
                color: Theme.of(context).iconTheme.color,
                size: size,
              ),
      ),
    );
  }
}
