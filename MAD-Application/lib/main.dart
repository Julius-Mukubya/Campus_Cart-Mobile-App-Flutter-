import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'package:madpractical/pages/cart_screen.dart';
import 'package:madpractical/pages/home_screen.dart';
import 'package:madpractical/pages/product_details.dart';
import 'package:madpractical/pages/sign_in_screen.dart';
import 'package:madpractical/pages/sign_up_screen.dart';
import 'package:madpractical/pages/forgot_password_screen.dart';
import 'package:madpractical/pages/otp_verification_screen.dart';
import 'package:madpractical/pages/reset_password_screen.dart';
import 'package:madpractical/pages/categories_screen.dart';
import 'package:madpractical/pages/wishlist_screen.dart';
import 'package:madpractical/pages/profile_screen.dart';
import 'package:madpractical/pages/splash_screen.dart';
import 'package:madpractical/pages/my_orders_screen.dart';
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
// Coordinator screens
import 'package:madpractical/pages/staff/coordinator/unassigned_orders_screen.dart';
import 'package:madpractical/pages/staff/coordinator/assign_pickup_screen.dart';
import 'package:madpractical/pages/staff/coordinator/hq_management_screen.dart';
import 'package:madpractical/pages/staff/coordinator/assign_delivery_screen.dart';
// Support screens
import 'package:madpractical/pages/staff/support/support_tickets_screen.dart';
import 'package:madpractical/pages/staff/support/live_chat_screen.dart';
import 'package:madpractical/pages/help_center_screen.dart';
// Deliverer screens
import 'package:madpractical/pages/staff/deliverer/pickup_orders_screen.dart';
import 'package:madpractical/pages/staff/deliverer/final_delivery_orders_screen.dart';
import 'package:madpractical/pages/staff/deliverer/route_planner_screen.dart';
import 'package:madpractical/pages/staff/deliverer/active_deliveries_screen.dart';
import 'package:madpractical/pages/staff/deliverer/delivery_history_screen.dart';
// Seller screens (vendor)
import 'package:madpractical/pages/seller/vendor_order_approval_screen.dart';
// Admin screens
import 'package:madpractical/pages/admin/admin_dashboard_screen.dart';
import 'package:madpractical/pages/admin/manage_sellers_screen.dart';
import 'package:madpractical/pages/debug_firebase_screen.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/user_manager.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Firestore offline persistence — serves from local cache,
  // only fetches from network when data is stale or missing
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

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
        '/help-center': (context) => const HelpCenterScreen(),
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
        '/staff/help-center': (context) => const HelpCenterScreen(),
        '/staff/route-planner': (context) => const RoutePlannerScreen(),
        '/staff/active-deliveries': (context) => const ActiveDeliveriesScreen(),
        '/staff/delivery-history': (context) => const DeliveryHistoryScreen(),
        // Coordinator routes
        '/staff/unassigned-orders': (context) => const UnassignedOrdersScreen(),
        '/staff/assign-pickup': (context) => const AssignPickupScreen(),
        '/staff/hq-management': (context) => const HQManagementScreen(),
        '/staff/assign-delivery': (context) => const AssignDeliveryScreen(),
        // Seller order approval route
        '/seller/order-approvals': (context) => const VendorOrderApprovalScreen(),
        // Delivery routes
        '/delivery/pickup-orders': (context) => const PickupOrdersScreen(),
        '/delivery/final-orders': (context) => const FinalDeliveryOrdersScreen(),
        // Admin routes
        '/admin/dashboard': (context) => const AdminDashboardScreen(),
        '/admin/sellers': (context) => const ManageSellersScreen(),
        
        // Debug route
        '/debug/firebase': (context) => const DebugFirebaseScreen(),
      },
    );
  }
}
