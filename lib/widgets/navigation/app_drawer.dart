import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madpractical/providers/user_provider.dart';
import 'package:madpractical/providers/cart_provider.dart';
import 'package:madpractical/providers/notification_provider.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/app_settings.dart';
import 'package:madpractical/widgets/common/dark_mode_toggle.dart';

/// Role-based drawer widget that shows different menu items
/// depending on the current user's role (customer, seller, admin).
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final notificationState = ref.watch(notificationProvider);
    final cartCount = ref.watch(cartProvider).itemCount;
    final unreadCount = notificationState.unreadCount;
    final isDark = AppSettings().isDark;
    final textColor = isDark ? AppColors.darkText : AppColors.text;
    final subtitleColor = isDark ? AppColors.darkSecondaryText : AppColors.secondaryText;

    return Drawer(
      backgroundColor: AppColors.getBackground(context),
      child: Column(
        children: [
          // ── Header: Avatar + Name + Email ──────────────────────────────
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            currentAccountPicture: CircleAvatar(
              radius: 32,
              backgroundImage: (userState.profileImage.isNotEmpty && 
                  userState.profileImage.startsWith('http'))
                  ? NetworkImage(userState.profileImage) as ImageProvider
                  : AssetImage(userState.profileImage),
              onBackgroundImageError: (_, __) {},
              child: (userState.profileImage.isEmpty ||
                  !userState.profileImage.startsWith('http'))
                  ? Text(
                      userState.name.isNotEmpty
                          ? userState.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    )
                  : null,
            ),
            accountName: Text(
              userState.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.white,
              ),
            ),
            accountEmail: Text(
              userState.email,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.white,
              ),
            ),
          ),

          // ── Menu Items ─────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: _buildMenuItems(context, ref, userState, unreadCount, cartCount, textColor, subtitleColor),
            ),
          ),

          // ── Sign Out Button at Bottom ──────────────────────────────────
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkSecondaryText.withValues(alpha: 0.2) : AppColors.grey.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: SafeArea(
              child: ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => _handleSignOut(context, ref),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems(
    BuildContext context,
    WidgetRef ref,
    UserState userState,
    int unreadCount,
    int cartCount,
    Color textColor,
    Color subtitleColor,
  ) {
    final role = userState.role;
    final items = <_DrawerItem>[];

    // ── Common Items (available to all roles) ──────────────────────
    items.addAll([
      _DrawerItem(icon: Icons.notifications_outlined, title: 'Notifications', route: '/notifications', badge: unreadCount > 0 ? '$unreadCount' : null),
      _DrawerItem.divider(),
    ]);

    // ── Customer-specific items ────────────────────────────────────
    if (role == 'customer') {
      items.addAll([
        _DrawerItem(icon: Icons.favorite_outline, title: 'Wishlist', route: '/wishlist'),
        _DrawerItem(icon: Icons.receipt_long_outlined, title: 'My Orders', route: '/my-orders'),
        _DrawerItem(icon: Icons.store_outlined, title: 'Store Page', route: '/store'),
        _DrawerItem.divider(),
        _DrawerItem(icon: Icons.rocket_launch_outlined, title: 'Become a Seller', route: '/become-seller'),
      ]);
    }

    // ── Seller-specific items ──────────────────────────────────────
    if (role == 'seller') {
      final storeId = userState.storeId;
      items.addAll([
        _DrawerItem(icon: Icons.receipt_long_outlined, title: 'All Orders', route: '/seller/orders'),
        _DrawerItem(icon: Icons.add_box_outlined, title: 'Add Product', route: '/seller/add-product'),
        _DrawerItem(icon: Icons.store_outlined, title: 'View My Store', route: storeId != null ? '/store/$storeId' : '/store'),
        _DrawerItem.divider(),
      ]);
    }

    // ── Admin-specific items ───────────────────────────────────────
    if (role == 'admin') {
      items.addAll([
        _DrawerItem(icon: Icons.receipt_long_outlined, title: 'All Orders', route: '/admin/orders'),
        _DrawerItem(icon: Icons.group_outlined, title: 'All Users', route: '/admin/users'),
        _DrawerItem.divider(),
      ]);
    }

    // ── Settings section (common) ──────────────────────────────────
    items.addAll([
      _DrawerItem(icon: Icons.security_outlined, title: 'Privacy & Security', route: '/privacy-security'),
    ]);

    // Build the list tiles
    return items.map((item) {
      if (item.isDivider) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        );
      }

      // Handle Dark Mode Toggle specially
      if (item.title == 'Dark Mode') {
        return ListTile(
          leading: Icon(Icons.dark_mode_outlined, color: textColor),
          title: Text('Dark Mode', style: TextStyle(color: textColor)),
          trailing: const DarkModeToggle(),
        );
      }

      return ListTile(
        leading: Icon(item.icon, color: textColor),
        title: Text(item.title, style: TextStyle(color: textColor)),
        trailing: item.badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.badge!,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: item.route != null
            ? () {
                Navigator.pop(context); // close drawer
                Navigator.pushNamed(context, item.route!);
              }
            : null,
      );
    }).toList();
  }

  void _handleSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // close dialog
              // Clear user state
              ref.read(userProvider.notifier).logout();
              // Navigate to sign in
              Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

/// Internal helper to define drawer menu items
class _DrawerItem {
  final IconData? icon;
  final String title;
  final String? route;
  final String? badge;
  final bool isDivider;

  const _DrawerItem({
    this.icon,
    required this.title,
    this.route,
    this.badge,
    this.isDivider = false,
  });

  const _DrawerItem.divider()
      : icon = null,
        title = '',
        route = null,
        badge = null,
        isDivider = true;
}