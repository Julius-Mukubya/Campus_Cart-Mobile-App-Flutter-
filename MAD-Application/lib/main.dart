import 'package:flutter/material.dart';
import 'package:madpractical/pages/CartScreen.dart';
import 'package:madpractical/pages/HomeScreen.dart';
import 'package:madpractical/pages/ProductDetails.dart';
import 'package:madpractical/pages/SignInScreen.dart';
import 'package:madpractical/pages/SignUpScreen.dart';
import 'package:madpractical/pages/ForgotPasswordScreen.dart';
import 'package:madpractical/pages/OtpVerificationScreen.dart';
import 'package:madpractical/pages/ResetPasswordScreen.dart';
import 'package:madpractical/pages/CategoriesScreen.dart';
import 'package:madpractical/pages/WishlistScreen.dart';
import 'package:madpractical/pages/ProfileScreen.dart';
import 'package:madpractical/pages/SplashScreen.dart';
import 'package:madpractical/pages/MyOrdersScreen.dart';
import 'package:madpractical/pages/access_denied_screen.dart';
// Seller screens
import 'package:madpractical/pages/seller/seller_dashboard_screen.dart';
import 'package:madpractical/pages/seller/my_products_screen.dart';
import 'package:madpractical/pages/seller/add_product_screen.dart';
import 'package:madpractical/pages/seller/edit_product_screen.dart';
import 'package:madpractical/pages/seller/seller_orders_screen.dart';
import 'package:madpractical/pages/seller/order_details_screen.dart';
import 'package:madpractical/pages/seller/earnings_screen.dart';
import 'package:madpractical/pages/seller/store_settings_screen.dart';
// Staff screens
import 'package:madpractical/pages/staff/staff_dashboard_screen.dart';
import 'package:madpractical/pages/staff/orders_to_process_screen.dart';
import 'package:madpractical/pages/staff/support_tickets_screen.dart';
import 'package:madpractical/pages/staff/live_chat_screen.dart';
import 'package:madpractical/pages/staff/moderation_screen.dart';
import 'package:madpractical/pages/staff/active_deliveries_screen.dart';
import 'package:madpractical/pages/staff/delivery_history_screen.dart';
// Admin screens
import 'package:madpractical/pages/admin/admin_dashboard_screen.dart';
import 'package:madpractical/pages/admin/manage_sellers_screen.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/user_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Cart',
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
        // Check user role for protected routes
        final userManager = UserManager();
        final userRole = userManager.role;
        
        // Role-based route protection
        if (settings.name?.startsWith('/seller/') == true && userRole != 'seller') {
          return MaterialPageRoute(builder: (context) => const AccessDeniedScreen());
        }
        if (settings.name?.startsWith('/staff/') == true && userRole != 'staff') {
          return MaterialPageRoute(builder: (context) => const AccessDeniedScreen());
        }
        if (settings.name?.startsWith('/admin/') == true && userRole != 'admin') {
          return MaterialPageRoute(builder: (context) => const AccessDeniedScreen());
        }
        
        // Handle product details route
        if (settings.name == '/product_details' || settings.name == '/product-details') {
          final product = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          );
        }
        
        // Handle edit product route
        if (settings.name == '/seller/edit-product') {
          final product = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => EditProductScreen(product: product),
          );
        }
        
        // Handle order details route
        if (settings.name == '/seller/order-details') {
          final order = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order: order),
          );
        }
        
        return null;
      },
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => SignInScreen(),
        '/signup': (context) => SignUpScreen(),
        '/signin': (context) => SignInScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/otp-verification': (context) => const OtpVerificationScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/home': (context) => HomeScreen(),
        '/cart': (context) => CartScreen(),
        '/categories': (context) => const CategoriesScreen(),
        '/wishlist': (context) => const WishlistScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/my-orders': (context) => const MyOrdersScreen(),
        '/access-denied': (context) => const AccessDeniedScreen(),
        // Seller routes
        '/seller/dashboard': (context) => const SellerDashboardScreen(),
        '/seller/products': (context) => const MyProductsScreen(),
        '/seller/add-product': (context) => const AddProductScreen(),
        '/seller/orders': (context) => const SellerOrdersScreen(),
        '/seller/earnings': (context) => const EarningsScreen(),
        '/seller/settings': (context) => const StoreSettingsScreen(),
        // Staff routes
        '/staff/dashboard': (context) => const StaffDashboardScreen(),
        '/staff/orders': (context) => const OrdersToProcessScreen(),
        '/staff/tickets': (context) => const SupportTicketsScreen(),
        '/staff/chat': (context) => const LiveChatScreen(),
        '/staff/moderation': (context) => const ModerationScreen(),
        '/staff/active-deliveries': (context) => const ActiveDeliveriesScreen(),
        '/staff/delivery-history': (context) => const DeliveryHistoryScreen(),
        // Admin routes
        '/admin/dashboard': (context) => const AdminDashboardScreen(),
        '/admin/sellers': (context) => const ManageSellersScreen(),
      },
    );
  }
}
