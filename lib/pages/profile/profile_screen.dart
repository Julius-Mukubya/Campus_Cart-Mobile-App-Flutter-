import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/auth_service.dart';
import 'package:madpractical/services/preferences_service.dart';
import 'package:madpractical/services/app_settings.dart';
import 'package:madpractical/providers/user_provider.dart';
import 'package:madpractical/providers/cart_provider.dart';
import 'package:madpractical/providers/wishlist_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final cartState = ref.watch(cartProvider);
    final wishlistState = ref.watch(wishlistProvider);

    final accountItems = [
      {
        'icon': Icons.receipt_long_outlined,
        'title': 'My Orders',
        'subtitle': 'Track your orders',
        'color': AppColors.primary,
        'onTap': () => context.push('/my-orders'),
      },
      {
        'icon': Icons.location_on_outlined,
        'title': 'Addresses',
        'subtitle': 'Manage delivery addresses',
        'color': AppColors.accent,
        'onTap': () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address management not available in this version')),
        ),
      },
      {
        'icon': Icons.payment_outlined,
        'title': 'Payment Methods',
        'subtitle': 'Manage payment options',
        'color': AppColors.success,
        'onTap': () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment methods not available in this version')),
        ),
      },
    ];

    final settingsItems = [
      {
        'icon': Icons.notifications_outlined,
        'title': 'Notifications',
        'subtitle': 'Manage notifications',
        'color': AppColors.primary,
        'onTap': () => context.push('/notifications'),
      },
      {
        'icon': Icons.security_outlined,
        'title': 'Privacy & Security',
        'subtitle': 'Account security settings',
        'color': AppColors.accent,
        'onTap': () => context.push('/privacy-security'),
      },
    ];

    final helpSupportItems = [
      {
        'icon': Icons.quiz_outlined,
        'title': 'FAQ',
        'subtitle': 'Frequently asked questions',
        'color': AppColors.success,
        'onTap': () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('FAQ not available in this version')),
        ),
      },
      {
        'icon': Icons.contact_support_outlined,
        'title': 'Contact Us',
        'subtitle': 'Get in touch with support',
        'color': Colors.blue,
        'onTap': () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact us feature not available in this version')),
        ),
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              _buildProfileHeader(userState),

              const SizedBox(height: 24),

              // Stats Row
              _buildStatsRow(userState, cartState, wishlistState),

              const SizedBox(height: 24),

              // Account Section
              _buildMenuSection('Account', accountItems),

              const SizedBox(height: 20),

              // Become Seller Section (only for customers)
              if (userState.role == 'customer') ...[
                _buildMenuSection('Opportunity', [
                  {
                    'icon': Icons.store_outlined,
                    'title': 'Become a Seller',
                    'subtitle': 'Start selling your products',
                    'color': Colors.green,
                    'onTap': () => context.push('/become-seller'),
                  },
                ]),
                const SizedBox(height: 20),
              ],

              // Business/Management Section (only for non-customer roles)
              if (userState.role != 'customer') ...[
                _buildMenuSection('Business / Management', _getBusinessMenuItems(userState.role)),
                const SizedBox(height: 20),
              ],

              // Settings Section
              _buildMenuSection('Settings', settingsItems),

              const SizedBox(height: 20),

              // Appearance Section
              _buildAppearanceSection(),

              const SizedBox(height: 20),

              // Help & Support Section
              _buildMenuSection('Help & Support', helpSupportItems),

              const SizedBox(height: 32),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showLogoutDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Widget _buildProfileHeader(UserState userState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.getSurface(context),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: userState.profileImage.isNotEmpty &&
                    userState.profileImage.startsWith('http')
                ? CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(userState.profileImage),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  )
                : CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      _getInitials(userState.name),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userState.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userState.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              context.push('/edit-profile');
            },
            child: Container(
              padding: const EdgeInsets.all(12),
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
                Icons.edit,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(UserState userState, CartState cartState, WishlistState wishlistState) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
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
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${cartState.items.length}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  'Cart',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
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
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: AppColors.accent,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${wishlistState.items.length}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  'Wishlist',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
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
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.star,
                    color: AppColors.success,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '4.8',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  'Rating',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    final settings = AppSettings();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Appearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.getText(context))),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.indigo.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.dark_mode_outlined, color: Colors.indigo, size: 20),
            ),
            title: Text('Dark Mode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.getText(context))),
            subtitle: Text(settings.isDark ? 'Dark theme enabled' : 'Light theme enabled',
                style: TextStyle(fontSize: 12, color: AppColors.getSecondaryText(context))),
            trailing: Switch(
              value: settings.isDark,
              activeThumbColor: AppColors.primary,
              onChanged: (_) async {
                await settings.toggleTheme();
                setState(() {});
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 0.5,
              color: isDark
                  ? AppColors.darkSecondaryText.withValues(alpha: 0.12)
                  : AppColors.grey.withValues(alpha: 0.12),
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.teal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.language, color: Colors.teal, size: 20),
            ),
            title: Text('Language', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.getText(context))),
            subtitle: Text(
              AppSettings.supportedLanguages
                  .firstWhere((l) => l['code'] == settings.locale.languageCode,
                      orElse: () => {'name': 'English'})['name']!,
              style: TextStyle(fontSize: 12, color: AppColors.getSecondaryText(context)),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: isDark ? AppColors.darkSurface : AppColors.secondary, borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.getText(context)),
            ),
            onTap: () => _showLanguagePicker(settings),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(AppSettings settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.getSurface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Select Language', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 16),
            ...AppSettings.supportedLanguages.map((lang) {
              final isSelected = settings.locale.languageCode == lang['code'];
              return ListTile(
                leading: Icon(Icons.language, color: isSelected ? AppColors.primary : AppColors.grey),
                title: Text(lang['name']!, style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : Theme.of(context).textTheme.bodyLarge?.color,
                )),
                trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () async {
                  await settings.setLanguage(lang['code']!);
                  setState(() {});
                  if (mounted) Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Map<String, dynamic>> items) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                if (index > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 0.5,
                      color: AppColors.grey.withValues(alpha: 0.12),
                    ),
                  ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item['color'].withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item['icon'],
                      color: item['color'],
                      size: 20,
                    ),
                  ),
                  title: Text(
                    item['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  subtitle: item['subtitle'] != null
                      ? Text(
                          item['subtitle'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        )
                      : null,
                  trailing: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.getCards(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                  onTap: item['onTap'],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getBusinessMenuItems(String role) {
    switch (role) {
      case 'seller':
        return [
          {
            'icon': Icons.dashboard,
            'title': 'Seller Dashboard',
            'subtitle': 'Sales overview',
            'color': AppColors.primary,
            'onTap': () => context.go('/seller/dashboard'),
          },
          {
            'icon': Icons.inventory_2,
            'title': 'My Products',
            'subtitle': 'Manage product list',
            'color': AppColors.accent,
            'onTap': () => context.go('/seller/products'),
          },
          {
            'icon': Icons.add_box,
            'title': 'Add Product',
            'subtitle': 'Create a new product',
            'color': AppColors.success,
            'onTap': () => context.go('/seller/add-product'),
          },
          {
            'icon': Icons.receipt_long,
            'title': 'Seller Orders',
            'subtitle': 'Manage customer orders',
            'color': Colors.blue,
            'onTap': () => context.go('/seller/orders'),
          },
        ];
      case 'admin':
        return [
          {
            'icon': Icons.admin_panel_settings,
            'title': 'Admin Dashboard',
            'subtitle': 'Platform overview',
            'color': AppColors.primary,
            'onTap': () => context.go('/admin/dashboard'),
          },
          {
            'icon': Icons.store,
            'title': 'Manage Sellers',
            'subtitle': 'Approve/suspend sellers',
            'color': AppColors.accent,
            'onTap': () => context.go('/admin/sellers'),
          },
        ];
      default:
        return [];
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.secondaryText),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              // Sign out from Firebase Auth and clear local state
              await AuthService().signOut();
              await PreferencesService.clearUser();
              await PreferencesService.clearCartItems();
              await PreferencesService.clearWishlistItems();
              ref.read(userProvider.notifier).logout();
              if (!context.mounted) return;
              context.go('/signin');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}