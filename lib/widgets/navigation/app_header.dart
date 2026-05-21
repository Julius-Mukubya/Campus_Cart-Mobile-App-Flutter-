import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/providers/cart_provider.dart';
import 'package:madpractical/providers/notification_provider.dart';
import 'package:madpractical/pages/customer/notifications_list_screen.dart';
import 'package:madpractical/widgets/common/dark_mode_toggle.dart';

/// Material 3–style header bar that adapts to context.
///
/// - Use [showBack] == false + [onOpenDrawer] for shell/tab screens
/// - Use [showBack] == true for detail screens that need a back button
/// - [showNotificationBell] and [showCartBadge] toggle action icons
class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final bool showNotificationBell;
  final bool showCartBadge;
  final bool showDarkModeToggle;
  final List<Widget> actions;
  final VoidCallback? onOpenDrawer;
  final Widget? titleWidget;

  const AppHeader({
    super.key,
    required this.title,
    this.showBack = false,
    this.showNotificationBell = true,
    this.showCartBadge = false,
    this.showDarkModeToggle = true,
    this.actions = const [],
    this.onOpenDrawer,
    this.titleWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartCount = ref.watch(cartProvider).itemCount;

    // Build left-leading icon
    Widget? leading;
    if (showBack) {
      leading = IconButton(
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
          child: const Icon(
            Icons.arrow_back_ios,
            size: 16,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      );
    } else {
      leading = IconButton(
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
          child: Icon(Icons.menu, size: 20, color: isDark ? AppColors.darkText : AppColors.text),
        ),
        onPressed: onOpenDrawer ?? () => Scaffold.of(context).openDrawer(),
      );
    }

    // Build right-side action icons
    final actionList = <Widget>[...actions];

    if (showDarkModeToggle) {
      actionList.add(
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: DarkModeToggle(),
        ),
      );
    }

    if (showCartBadge) {
      actionList.add(
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/cart'),
            child: Container(
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
              child: cartCount > 0
                  ? Badge(
                      label: Text('$cartCount'),
                      backgroundColor: AppColors.accent,
                      child: Icon(
                        Icons.shopping_cart,
                        color: isDark ? AppColors.darkText : AppColors.text,
                        size: 20,
                      ),
                    )
                  : Icon(
                      Icons.shopping_cart,
                      color: isDark ? AppColors.darkText : AppColors.text,
                      size: 20,
                    ),
            ),
          ),
        ),
      );
    }

    if (showNotificationBell) {
      actionList.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsListScreen(),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8),
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
            child: _NotificationBell(ref: ref),
          ),
        ),
      );
    }

    return AppBar(
      backgroundColor: AppColors.getBackground(context),
      elevation: 0,
      leading: leading,
      title: titleWidget ??
          Text(
            title,
            style: TextStyle(
              color: isDark ? AppColors.darkText : AppColors.text,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
      centerTitle: false,
      actions: actionList.isNotEmpty ? actionList : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Internal widget to show notification bell with unread badge
class _NotificationBell extends ConsumerWidget {
  final WidgetRef ref;

  const _NotificationBell({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef _) {
    final unreadCount = ref.watch(notificationProvider).unreadCount;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return unreadCount > 0
        ? Badge(
            label: Text('$unreadCount'),
            backgroundColor: AppColors.error,
            child: Icon(
              Icons.notifications_outlined,
              color: isDark ? AppColors.darkText : AppColors.text,
              size: 20,
            ),
          )
        : Icon(
            Icons.notifications_outlined,
            color: isDark ? AppColors.darkText : AppColors.text,
            size: 20,
          );
  }
}