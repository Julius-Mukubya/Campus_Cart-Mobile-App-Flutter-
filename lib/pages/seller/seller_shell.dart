import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/providers/notification_provider.dart';
import 'package:madpractical/widgets/navigation/app_header.dart';
import 'package:madpractical/widgets/navigation/app_drawer.dart';

/// Shell scaffold for Seller role with bottom navigation + drawer + header.
/// Used by GoRouter's StatefulShellRoute.
class SellerShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const SellerShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(notificationProvider).unreadCount;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      drawer: const AppDrawer(),
      appBar: AppHeader(
        title: _getTitle(navigationShell.currentIndex),
        showNotificationBell: true,
        showCartBadge: false,
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0: return 'Dashboard';
      case 1: return 'My Products';
      case 2: return 'Orders';
      case 3: return 'Chats';
      case 4: return 'Profile';
      default: return 'Seller';
    }
  }
}