import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/providers/cart_provider.dart';
import 'package:madpractical/providers/user_provider.dart';
import 'package:madpractical/widgets/navigation/app_header.dart';
import 'package:madpractical/widgets/navigation/app_drawer.dart';

/// Unified shell scaffold for all roles (customer, seller, admin).
/// Uses ONE bottom navigation bar layout for everyone.
/// The drawer shows role-specific content.
/// Each tab renders the appropriate screen based on the user's role.
class MainShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartProvider).itemCount;
    final role = ref.watch(userProvider).role;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      drawer: const AppDrawer(),
      appBar: AppHeader(
        title: _getTitle(navigationShell.currentIndex, role),
        showNotificationBell: true,
        showCartBadge: true,
        showDarkModeToggle: false,
      ),
      body: navigationShell,
      bottomNavigationBar: SizedBox(
        height: 65,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: navigationShell.currentIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSecondaryText
              : AppColors.grey,
          selectedFontSize: 13,
          unselectedFontSize: 13,
          iconSize: 26,
          elevation: 8,
          backgroundColor: AppColors.getCards(context),
          selectedLabelStyle: const TextStyle(height: 1.6),
          unselectedLabelStyle: const TextStyle(height: 1.6),
          onTap: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: cartCount > 0
                  ? Badge(
                      label: Text('$cartCount'),
                      backgroundColor: AppColors.accent,
                      child: const Icon(Icons.shopping_cart),
                    )
                  : const Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Chats',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle(int index, String role) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Categories';
      case 2:
        return 'Cart';
      case 3:
        return 'Chats';
      case 4:
        return 'Profile';
      default:
        return 'Home';
    }
  }
}