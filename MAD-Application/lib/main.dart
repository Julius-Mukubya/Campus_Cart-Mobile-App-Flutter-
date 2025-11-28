import 'package:flutter/material.dart';
import 'package:madpractical/pages/CartScreen.dart';
import 'package:madpractical/pages/HomeScreen.dart';
import 'package:madpractical/pages/ProductDetails.dart';
import 'package:madpractical/pages/SignInScreen.dart';
import 'package:madpractical/pages/SignUpScreen.dart';
import 'package:madpractical/pages/CategoriesScreen.dart';
import 'package:madpractical/pages/WishlistScreen.dart';
import 'package:madpractical/pages/ProfileScreen.dart';
import 'package:madpractical/pages/SplashScreen.dart';
import 'package:madpractical/pages/MyOrdersScreen.dart';
import 'package:madpractical/constants/app_colors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopHub - Your Shopping Destination',
      debugShowCheckedModeBanner: false,
      // Theme Configuration
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.cards,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.text),
          bodyMedium: TextStyle(color: AppColors.secondaryText),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.text,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttons,
            foregroundColor: AppColors.white,
          ),
        ),
      ),
      themeMode: ThemeMode.light, // Use light theme for now
      // Start on a splash screen which will redirect to sign in
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        if (settings.name == '/product_details') {
          final product = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          );
        }
        return null;
      },
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => SignInScreen(),
        '/signup': (context) => SignUpScreen(),
        '/signin': (context) => SignInScreen(),
        '/home': (context) => HomeScreen(),
        '/cart': (context) => CartScreen(),
        '/categories': (context) => const CategoriesScreen(),
        '/wishlist': (context) => const WishlistScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/my-orders': (context) => const MyOrdersScreen(),
      },
    );
  }
}
