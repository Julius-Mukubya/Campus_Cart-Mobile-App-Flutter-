import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/pages/customer/notifications_list_screen.dart';
import 'package:madpractical/providers/notification_provider.dart';

class NotificationIcon extends ConsumerWidget {
  final double size;
  final bool showBadge;

  const NotificationIcon({
    super.key,
    this.size = 24,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(notificationProvider).unreadCount;

    return GestureDetector(
      onTap: () {
        context.push('/notifications');
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
