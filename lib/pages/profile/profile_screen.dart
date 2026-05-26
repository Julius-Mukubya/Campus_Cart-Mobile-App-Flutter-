import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/auth_service.dart';
import 'package:madpractical/services/preferences_service.dart';
import 'package:madpractical/services/app_settings.dart';
import 'package:madpractical/providers/user_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);

    final accountItems = [
      {
        'icon': Icons.shopping_cart_outlined,
        'title': 'My Cart',
        'subtitle': 'View your cart items',
        'color': AppColors.primary,
        'onTap': () => context.push('/cart'),
      },
      {
        'icon': Icons.favorite_outline,
        'title': 'My Wishlist',
        'subtitle': 'Your saved items',
        'color': AppColors.primary,
        'onTap': () => context.push('/wishlist'),
      },
      {
        'icon': Icons.receipt_long_outlined,
        'title': 'My Orders',
        'subtitle': 'Track your orders',
        'color': AppColors.primary,
        'onTap': () => context.push('/my-orders'),
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
        'onTap': () => context.push('/faq'),
      },
      {
        'icon': Icons.contact_support_outlined,
        'title': 'Contact Us',
        'subtitle': 'Get in touch with support',
        'color': Colors.blue,
        'onTap': () => context.push('/contact-us'),
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

              const SizedBox(height: 16),

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

  Widget _buildProfileHeader(UserState userState) {
    final hasValidImage = userState.profileImage.isNotEmpty &&
        userState.profileImage.startsWith('http');
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
      child: Column(
        children: [
          // Avatar
          Stack(
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
                child: hasValidImage
                    ? CircleAvatar(
                        radius: 45,
                        backgroundImage: NetworkImage(userState.profileImage),
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      )
                    : CircleAvatar(
                        radius: 45,
                        backgroundColor: AppColors.primary,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.white,
                        ),
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => context.push('/edit-profile'),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: AppColors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            userState.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          // Email
          Text(
            userState.email,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection() {
    final settings = AppSettings();
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
        ],
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
            'onTap': () => context.push('/seller/dashboard'),
          },
          {
            'icon': Icons.inventory_2,
            'title': 'My Products',
            'subtitle': 'Manage product list',
            'color': AppColors.accent,
            'onTap': () => context.push('/seller/products'),
          },
          {
            'icon': Icons.add_box,
            'title': 'Add Product',
            'subtitle': 'Create a new product',
            'color': AppColors.success,
            'onTap': () => context.push('/seller/add-product'),
          },
          {
            'icon': Icons.receipt_long,
            'title': 'Seller Orders',
            'subtitle': 'Manage customer orders',
            'color': Colors.blue,
            'onTap': () => context.push('/seller/orders'),
          },
        ];
      case 'admin':
        return [
          {
            'icon': Icons.admin_panel_settings,
            'title': 'Admin Dashboard',
            'subtitle': 'Platform overview',
            'color': AppColors.primary,
            'onTap': () => context.push('/admin/dashboard'),
          },
          {
            'icon': Icons.store,
            'title': 'Manage Sellers',
            'subtitle': 'Approve/suspend sellers',
            'color': AppColors.accent,
            'onTap': () => context.push('/admin/sellers'),
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
              // Sign out from Firebase Auth and clear ALL local state
              await AuthService().signOut();
              await PreferencesService.clearAll();
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