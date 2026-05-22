import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madpractical/providers/user_provider.dart';
import 'package:madpractical/providers/cart_provider.dart';
import 'package:madpractical/providers/notification_provider.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/app_settings.dart';
import 'package:go_router/go_router.dart';

/// Role-based drawer widget that shows different menu items
/// depending on the current user's role (customer, seller, admin).
/// Theme toggle is accessible here (moved from the header).
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final notificationState = ref.watch(notificationProvider);
    final cartCount = ref.watch(cartProvider).itemCount;
    final unreadCount = notificationState.unreadCount;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.text;
    final subtitleColor = isDark ? AppColors.darkSecondaryText : AppColors.secondaryText;
    final role = userState.role;

    return Drawer(
      backgroundColor: AppColors.getBackground(context),
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header: Avatar + Name + Email + Role Badge ──────────────
            _buildDrawerHeader(context, userState, role, isDark),

            // ── Menu Items ─────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: _buildMenuItems(
                  context,
                  ref,
                  userState,
                  unreadCount,
                  cartCount,
                  textColor,
                  subtitleColor,
                  isDark,
                  role,
                ),
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

  // ──────────────────────────────────────────────────────────────────────
  // DRAWER HEADER
  // ──────────────────────────────────────────────────────────────────────
  Widget _buildDrawerHeader(
    BuildContext context,
    UserState userState,
    String role,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
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
            child: CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.white.withValues(alpha: 0.25),
              backgroundImage: _resolveAvatarImage(userState),
              onBackgroundImageError: (_, __) {},
              child: _buildAvatarFallback(userState),
            ),
          ),
          const SizedBox(height: 14),

          // Name
          Text(
            userState.name.isNotEmpty ? userState.name : 'User',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColors.white,
              letterSpacing: 0.3,
            ),
          ),

          // Email
          if (userState.email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              userState.email,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.white.withValues(alpha: 0.8),
              ),
            ),
          ],

          // Role badge
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              _roleLabel(role),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _resolveAvatarImage(UserState userState) {
    if (userState.profileImage.isNotEmpty &&
        userState.profileImage.startsWith('http')) {
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
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'seller':
        return 'Seller';
      default:
        return 'Customer';
    }
  }

  // ──────────────────────────────────────────────────────────────────────
  // MENU ITEMS
  // ──────────────────────────────────────────────────────────────────────
  List<Widget> _buildMenuItems(
    BuildContext context,
    WidgetRef ref,
    UserState userState,
    int unreadCount,
    int cartCount,
    Color textColor,
    Color subtitleColor,
    bool isDark,
    String role,
  ) {
    final items = <Widget>[];

    // Spacing after header
    items.add(const SizedBox(height: 8));

    // ── Customer-specific items ──────────────────────────────────────
    if (role == 'customer') {
      items.addAll([
        _buildMenuItem(context, icon: Icons.favorite_outline, title: 'Wishlist', route: '/wishlist', textColor: textColor),
        _buildMenuItem(context, icon: Icons.receipt_long_outlined, title: 'My Orders', route: '/my-orders', textColor: textColor),
        _buildMenuItem(context, icon: Icons.store_outlined, title: 'Store Page', route: '/store', textColor: textColor),
        _buildDivider(isDark),
        _buildMenuItem(context, icon: Icons.rocket_launch_outlined, title: 'Become a Seller', route: '/become-seller', textColor: textColor),
      ]);
    }

    // ── Seller-specific items ────────────────────────────────────────
    if (role == 'seller') {
      final storeId = userState.storeId;
      items.addAll([
        _buildMenuItem(context, icon: Icons.receipt_long_outlined, title: 'All Orders', route: '/seller/orders', textColor: textColor),
        _buildMenuItem(context, icon: Icons.add_box_outlined, title: 'Add Product', route: '/seller/add-product', textColor: textColor),
        _buildMenuItem(
          context,
          icon: Icons.store_outlined,
          title: 'View My Store',
          route: storeId != null ? '/store/$storeId' : '/store',
          textColor: textColor,
        ),
        _buildDivider(isDark),
      ]);
    }

    // ── Admin-specific items ─────────────────────────────────────────
    if (role == 'admin') {
      items.addAll([
        _buildMenuItem(context, icon: Icons.receipt_long_outlined, title: 'All Orders', route: '/admin/orders', textColor: textColor),
        _buildMenuItem(context, icon: Icons.group_outlined, title: 'All Users', route: '/admin/users', textColor: textColor),
        _buildDivider(isDark),
      ]);
    }

    // ── Settings section (common) ────────────────────────────────────
    items.add(
      _buildMenuItem(context, icon: Icons.security_outlined, title: 'Privacy & Security', route: '/privacy-security', textColor: textColor),
    );

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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : const SizedBox(width: 8, height: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          context.pop(); // close drawer
          context.push(route);
        },
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Divider(
        color: isDark
            ? AppColors.darkSecondaryText.withValues(alpha: 0.2)
            : AppColors.grey.withValues(alpha: 0.3),
        height: 1,
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // THEME TOGGLE SECTION
  // ──────────────────────────────────────────────────────────────────────
  Widget _buildThemeSection(BuildContext context, bool isDark, Color textColor) {
    final settings = AppSettings();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.darkSecondaryText.withValues(alpha: 0.15)
                : AppColors.grey.withValues(alpha: 0.25),
          ),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isDark ? Colors.amber : AppColors.primary).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            color: isDark ? Colors.amber : AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          isDark ? 'Light Mode' : 'Dark Mode',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        trailing: Switch(
          value: isDark,
          activeThumbColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
          onChanged: (_) async {
            await settings.toggleTheme();
          },
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // SIGN OUT
  // ──────────────────────────────────────────────────────────────────────
  Widget _buildSignOut(BuildContext context, WidgetRef ref, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.darkSecondaryText.withValues(alpha: 0.15)
                : AppColors.grey.withValues(alpha: 0.25),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.logout, color: AppColors.error, size: 20),
        ),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              Navigator.pop(ctx); // close dialog
              // Clear user state
              ref.read(userProvider.notifier).logout();
              // Navigate to sign in
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