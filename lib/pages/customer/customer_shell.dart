import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/providers/cart_provider.dart';
import 'package:madpractical/widgets/navigation/app_header.dart';
import 'package:madpractical/widgets/navigation/app_drawer.dart';

/// Shell scaffold for Customer role with bottom navigation + drawer + header.
/// Used by GoRouter's StatefulShellRoute.
class CustomerShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const CustomerShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartProvider).itemCount;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      drawer: const AppDrawer(),
      appBar: AppHeader(
        title: _getTitle(navigationShell.currentIndex),
        showNotificationBell: true,
        showCartBadge: false,
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
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.grid_view),
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
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat_bubble_outline),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0: return 'Home';
      case 1: return 'Categories';
      case 2: return 'Cart';
      case 3: return 'Chats';
      case 4: return 'Profile';
      default: return 'Home';
    }
  }
}