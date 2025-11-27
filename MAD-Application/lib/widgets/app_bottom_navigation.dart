import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavigation({Key? key, required this.currentIndex})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap BottomNavigationBar in a SizedBox to increase visual height.
    return SizedBox(
      height: 65,
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        selectedFontSize: 13,
        unselectedFontSize: 13,
        iconSize: 26,
        elevation: 8,
        backgroundColor: AppColors.white,
        selectedLabelStyle: const TextStyle(height: 1.6),
        unselectedLabelStyle: const TextStyle(height: 1.6),
        onTap: (index) {
          if (index == currentIndex) return;
          String route;
          switch (index) {
            case 0:
              route = '/home';
              break;
            case 1:
              route = '/categories';
              break;
            case 2:
              route = '/wishlist';
              break;
            case 3:
              route = '/cart';
              break;
            case 4:
              route = '/profile';
              break;
            default:
              route = '/home';
          }

          Navigator.pushNamed(context, route);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
