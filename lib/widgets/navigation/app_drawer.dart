import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madpractical/providers/user_provider.dart';
import 'package:madpractical/providers/cart_provider.dart';
import 'package:madpractical/providers/wishlist_provider.dart';
import 'package:madpractical/providers/notification_provider.dart';
import 'package:madpractical/providers/order_provider.dart';
import 'package:madpractical/providers/seller_provider.dart';
import 'package:madpractical/providers/chat_provider.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/app_settings.dart';
import 'package:go_router/go_router.dart';

/// Role-based drawer with section headers and quick stats cards.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final notificationState = ref.watch(notificationProvider);
    final cartCount = ref.watch(cartProvider).itemCount;
    final wishlistCount = ref.watch(wishlistProvider).itemCount;
    final unreadCount = notificationState.unreadCount;
    final orderCount = ref.watch(orderProvider).orderCount;
    final sellerState = ref.watch(sellerProvider);
    final chatState = ref.watch(chatProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.text;
    final role = userState.role;

    return Drawer(
      backgroundColor: AppColors.getBackground(context),
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header: Avatar + Name + Email + Role Badge + Stats ─────
            _buildDrawerHeader(context, userState, role, isDark, cartCount, wishlistCount, unreadCount, ref,
                orderCount, sellerState, chatState),

            // ── Menu Items (sectioned) ──────────────────────────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: _buildMenuItems(context, ref, userState, textColor, isDark, role,
                    cartCount, wishlistCount, unreadCount, sellerState),
              ),
            ),

            // ── Theme Toggle Section ────────────────────────────────────
            _buildThemeSection(context, isDark, textColor),

            // ── Sign Out Button ─────────────────────────────────────────
            _buildSignOut(context, ref, isDark),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════
  // DRAWER HEADER
  // ═════════════════════════════════════════════════════════════════════
  Widget _buildDrawerHeader(
    BuildContext context,
    UserState userState,
    String role,
    bool isDark,
    int cartCount,
    int wishlistCount,
    int unreadCount,
    WidgetRef ref,
    int orderCount,
    SellerState sellerState,
    ChatState chatState,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar Row ─────────────────────────────────────────────
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _resolveAvatarImage(userState) != null
                    ? CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.white.withValues(alpha: 0.25),
                        backgroundImage: _resolveAvatarImage(userState),
                        onBackgroundImageError: (_, __) {},
                      )
                    : CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.white.withValues(alpha: 0.25),
                        child: _buildAvatarFallback(userState),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userState.name.isNotEmpty ? userState.name : 'User',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.white,
                      ),
                    ),
                    if (userState.email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        userState.email,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.white.withValues(alpha: 0.8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Role Badge Row ─────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.white.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _roleLabel(role),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (role == 'seller' && userState.storeId != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    userState.name.isNotEmpty ? '${userState.name.split(' ').first}\'s Store' : 'Store',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 14),

          // ── Quick Stats Cards ──────────────────────────────────────
          _buildQuickStats(context, role, cartCount, wishlistCount, unreadCount, ref,
              orderCount, sellerState, chatState),
        ],
      ),
    );
  }

  /// Role-specific quick stat cards in the header
  Widget _buildQuickStats(BuildContext context, String role, int cartCount, int wishlistCount, int unreadCount, WidgetRef ref,
      int orderCount, SellerState sellerState, ChatState chatState) {
    List<Widget> stats = [];

    switch (role) {
      case 'customer':
        stats = [
          _buildStatCard(Icons.shopping_cart_outlined, cartCount.toString(), 'Cart', AppColors.white, () => context.push('/cart')),
          _buildStatCard(Icons.favorite_outline, wishlistCount.toString(), 'Wishlist', AppColors.white, () => context.push('/wishlist')),
          _buildStatCard(Icons.receipt_long_outlined, orderCount.toString(), 'Orders', AppColors.white, () => context.push('/my-orders')),
          _buildStatCard(Icons.notifications_outlined, unreadCount.toString(), 'Alerts', AppColors.white, () => context.push('/notifications')),
        ];
        break;
      case 'seller':
        final productCount = sellerState.products.length;
        final orderCountSeller = sellerState.orders.length;
        final rating = sellerState.rating.toStringAsFixed(1);
        stats = [
          _buildStatCard(Icons.inventory_2_outlined, productCount.toString(), 'Products', Colors.amber, () => context.push('/seller/products')),
          _buildStatCard(Icons.receipt_long_outlined, orderCountSeller.toString(), 'Orders', AppColors.white, () => context.push('/seller/orders')),
          _buildStatCard(Icons.star_outline, rating, 'Rating', Colors.amber, () => context.push('/seller/dashboard')),
          _buildStatCard(Icons.chat_outlined, chatState.chatList.length.toString(), 'Chats', AppColors.white, () => context.push('/chat-list')),
        ];
        break;
      case 'admin':
        stats = [
          _buildStatCard(Icons.group_outlined, '0', 'Users', AppColors.white, () => context.push('/admin/users')),
          _buildStatCard(Icons.receipt_long_outlined, orderCount.toString(), 'Orders', AppColors.white, () => context.push('/admin/orders')),
          _buildStatCard(Icons.store_outlined, '0', 'Sellers', AppColors.white, () => context.push('/admin/sellers')),
          _buildStatCard(Icons.notifications_outlined, unreadCount.toString(), 'Alerts', AppColors.white, () => context.push('/notifications')),
        ];
        break;
    }

    return Row(
      children: stats.map((stat) => Expanded(child: stat)).toList(),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 14),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.7),
                fontSize: 8,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════
  // AVATAR HELPERS (unchanged)
  // ═════════════════════════════════════════════════════════════════════
  ImageProvider? _resolveAvatarImage(UserState userState) {
    if (userState.profileImage.isNotEmpty && userState.profileImage.startsWith('http')) {
      return NetworkImage(userState.profileImage) as ImageProvider;
    }
    if (userState.profileImage.isNotEmpty) {
      return AssetImage(userState.profileImage);
    }
    return null;
  }

  Widget _buildAvatarFallback(UserState userState) {
    return Text(
      _getInitials(userState.name),
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.white),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin': return 'Admin';
      case 'seller': return 'Seller';
      default: return 'Customer';
    }
  }

  // ═════════════════════════════════════════════════════════════════════
  // SECTIONED MENU ITEMS
  // ═════════════════════════════════════════════════════════════════════
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(
    BuildContext context,
    WidgetRef ref,
    UserState userState,
    Color textColor,
    bool isDark,
    String role,
    int cartCount,
    int wishlistCount,
    int unreadCount,
    SellerState sellerState,
  ) {
    final items = <Widget>[];
    items.add(const SizedBox(height: 8));

    switch (role) {
      case 'customer':
        items.add(_buildSectionHeader('SHOPPING'));
        items.add(_buildMenuItem(context,
            icon: Icons.favorite_outline,
            title: 'Wishlist',
            route: '/wishlist',
            badge: wishlistCount > 0 ? '$wishlistCount' : null,
            textColor: textColor));
        items.add(_buildMenuItem(context,
            icon: Icons.receipt_long_outlined,
            title: 'My Orders',
            route: '/my-orders',
            textColor: textColor));
        items.add(_buildMenuItem(context,
            icon: Icons.shopping_cart_outlined,
            title: 'My Cart',
            route: '/cart',
            badge: cartCount > 0 ? '$cartCount' : null,
            textColor: textColor));
        items.add(_buildMenuItem(context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            route: '/notifications',
            badge: unreadCount > 0 ? '$unreadCount' : null,
            textColor: textColor));
        items.add(_buildDivider(isDark));
        items.add(_buildSectionHeader('OPPORTUNITIES'));
        items.add(_buildMenuItem(context, icon: Icons.rocket_launch_outlined, title: 'Become a Seller', route: '/become-seller', textColor: textColor));
        items.add(_buildMenuItem(context, icon: Icons.store_outlined, title: 'Store Page', route: '/store', textColor: textColor));
        items.add(_buildDivider(isDark));
        items.add(_buildSectionHeader('SETTINGS'));
        items.add(_buildMenuItem(context, icon: Icons.security_outlined, title: 'Privacy & Security', route: '/privacy-security', textColor: textColor));
        items.add(_buildMenuItem(context, icon: Icons.person_outline, title: 'Edit Profile', route: '/edit-profile', textColor: textColor));
        break;

      case 'seller':
        items.add(_buildSectionHeader('STORE OVERVIEW'));
        items.add(_buildMenuItem(context, icon: Icons.dashboard_outlined, title: 'Dashboard', route: '/seller/dashboard', textColor: textColor));
        items.add(_buildMenuItem(context, icon: Icons.receipt_long_outlined, title: 'All Orders', route: '/seller/orders', textColor: textColor));
        items.add(_buildMenuItem(context, icon: Icons.chat_outlined, title: 'Chats', route: '/chat-list', textColor: textColor));
        items.add(_buildDivider(isDark));
        items.add(_buildSectionHeader('PRODUCTS'));
        items.add(_buildMenuItem(context,
            icon: Icons.inventory_2_outlined,
            title: 'My Products',
            route: '/seller/products',
            badge: sellerState.products.isNotEmpty ? '${sellerState.products.length}' : null,
            textColor: textColor));
        items.add(_buildMenuItem(context, icon: Icons.add_box_outlined, title: 'Add Product', route: '/seller/add-product', textColor: textColor));
        items.add(_buildMenuItem(context, icon: Icons.settings_outlined, title: 'Store Settings', route: '/seller/store-settings', textColor: textColor));
        final userId = userState.userId;
        items.add(_buildMenuItem(
          context,
          icon: Icons.visibility_outlined,
          title: 'View My Store',
          route: userId != null && userId.isNotEmpty ? '/store/$userId' : '/store',
          textColor: textColor,
        ));
        items.add(_buildDivider(isDark));
        items.add(_buildSectionHeader('SETTINGS'));
        items.add(_buildMenuItem(context, icon: Icons.security_outlined, title: 'Privacy & Security', route: '/privacy-security', textColor: textColor));
        items.add(_buildMenuItem(context, icon: Icons.person_outline, title: 'Edit Profile', route: '/edit-profile', textColor: textColor));
        break;

      case 'admin':
        items.add(_buildSectionHeader('ADMINISTRATION'));
        items.add(_buildMenuItem(context, icon: Icons.dashboard_outlined, title: 'Dashboard', route: '/admin/dashboard', textColor: textColor));
        items.add(_buildMenuItem(context, icon: Icons.receipt_long_outlined, title: 'All Orders', route: '/admin/orders', textColor: textColor));
        items.add(_buildMenuItem(context, icon: Icons.group_outlined, title: 'All Users', route: '/admin/users', textColor: textColor));
        items.add(_buildMenuItem(context, icon: Icons.store_outlined, title: 'Manage Sellers', route: '/admin/sellers', textColor: textColor));
        items.add(_buildMenuItem(context, icon: Icons.chat_outlined, title: 'Conversations', route: '/chat-list', textColor: textColor));
        items.add(_buildDivider(isDark));
        items.add(_buildSectionHeader('CATEGORIES'));
        items.add(_buildMenuItem(context, icon: Icons.category_outlined, title: 'Manage Categories', route: '/admin/categories', textColor: textColor));
        items.add(_buildDivider(isDark));
        items.add(_buildSectionHeader('SETTINGS'));
        items.add(_buildMenuItem(context, icon: Icons.security_outlined, title: 'Privacy & Security', route: '/privacy-security', textColor: textColor));
        items.add(_buildMenuItem(context, icon: Icons.person_outline, title: 'Edit Profile', route: '/edit-profile', textColor: textColor));
        break;
    }

    return items;
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    String? badge,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              )
            : Icon(Icons.chevron_right, size: 16, color: textColor.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: () {
          context.pop(); // close drawer
          context.push(route);
        },
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Divider(
        color: isDark
            ? AppColors.darkSecondaryText.withValues(alpha: 0.2)
            : AppColors.grey.withValues(alpha: 0.3),
        height: 1,
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════
  // THEME TOGGLE
  // ═════════════════════════════════════════════════════════════════════
  Widget _buildThemeSection(BuildContext context, bool isDark, Color textColor) {
    final settings = AppSettings();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkSecondaryText.withValues(alpha: 0.15) : AppColors.grey.withValues(alpha: 0.25),
          ),
        ),
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: (isDark ? Colors.amber : AppColors.primary).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            color: isDark ? Colors.amber : AppColors.primary,
            size: 18,
          ),
        ),
        title: Text(
          isDark ? 'Light Mode' : 'Dark Mode',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 14),
        ),
        trailing: Switch(
          value: isDark,
          activeThumbColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
          onChanged: (_) async => await settings.toggleTheme(),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════
  // SIGN OUT
  // ═════════════════════════════════════════════════════════════════════
  Widget _buildSignOut(BuildContext context, WidgetRef ref, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkSecondaryText.withValues(alpha: 0.15) : AppColors.grey.withValues(alpha: 0.25),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.logout, color: AppColors.error, size: 18),
        ),
        title: const Text(
          'Sign Out',
          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 14),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: () => _handleSignOut(context, ref),
      ),
    );
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
              Navigator.pop(ctx);
              ref.read(userProvider.notifier).logout();
              context.go('/signin');
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