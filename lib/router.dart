import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madpractical/providers/user_provider.dart';
import 'package:madpractical/services/preferences_service.dart';

// Auth screens
import 'package:madpractical/pages/auth/sign_in_screen.dart';
import 'package:madpractical/pages/auth/sign_up_screen.dart';
import 'package:madpractical/pages/auth/forgot_password_screen.dart';
import 'package:madpractical/pages/auth/otp_verification_screen.dart';
import 'package:madpractical/pages/auth/reset_password_screen.dart';
import 'package:madpractical/pages/auth/access_denied_screen.dart';

// Customer screens
import 'package:madpractical/pages/customer/home_screen.dart';
import 'package:madpractical/pages/customer/categories_screen.dart';
import 'package:madpractical/pages/customer/cart_screen.dart';
import 'package:madpractical/pages/customer/wishlist_screen.dart';
import 'package:madpractical/pages/customer/my_orders_screen.dart';
import 'package:madpractical/pages/customer/order_details_screen.dart' as customer_order;
import 'package:madpractical/pages/customer/product_details.dart';
import 'package:madpractical/pages/customer/checkout_screen.dart';
import 'package:madpractical/pages/customer/notifications_list_screen.dart';
import 'package:madpractical/pages/customer/store_page.dart';
import 'package:madpractical/pages/customer/review_product_screen.dart';

// Seller screens
import 'package:madpractical/pages/seller/seller_dashboard_screen.dart';
import 'package:madpractical/pages/seller/my_products_screen.dart';
import 'package:madpractical/pages/seller/add_product_screen.dart';
import 'package:madpractical/pages/seller/edit_product_screen.dart';
import 'package:madpractical/pages/seller/seller_orders_screen.dart';
import 'package:madpractical/pages/seller/seller_order_details_screen.dart' as seller_order;

// Admin screens
import 'package:madpractical/pages/admin/admin_dashboard_screen.dart';
import 'package:madpractical/pages/admin/manage_sellers_screen.dart';
import 'package:madpractical/pages/admin/seller_management_screen.dart';

// Profile screens
import 'package:madpractical/pages/profile/profile_screen.dart';
import 'package:madpractical/pages/profile/edit_profile_screen.dart';
import 'package:madpractical/pages/profile/privacy_security_screen.dart';
import 'package:madpractical/pages/profile/become_seller_screen.dart';

// Chat screens
import 'package:madpractical/pages/chat/chat_list_screen.dart';
import 'package:madpractical/pages/chat/chat_screen.dart';

// Shell screens
import 'package:madpractical/pages/customer/customer_shell.dart';
import 'package:madpractical/pages/seller/seller_shell.dart';
import 'package:madpractical/pages/admin/admin_shell.dart';

// Splash
import 'package:madpractical/pages/splash_screen.dart';

/// Provider that holds user state for the router redirect guard.
/// This is updated from main.dart when user state changes.
class RouterUserState {
  final bool isLoggedIn;
  final String role;

  const RouterUserState({
    this.isLoggedIn = false,
    this.role = 'customer',
  });
}

/// Global router state notifier for the redirect guard.
/// The GoRouter's refreshListenable watches this.
class RouterAuthNotifier extends ChangeNotifier {
  RouterUserState _state = const RouterUserState();
  RouterUserState get state => _state;

  void update(RouterUserState newState) {
    _state = newState;
    notifyListeners();
  }
}

final routerAuthNotifier = RouterAuthNotifier();

/// Role-based home route helper.
String _getRoleHome(String role) {
  switch (role) {
    case 'admin':
      return '/admin/dashboard';
    case 'seller':
      return '/seller/dashboard';
    default:
      return '/customer/home';
  }
}

/// Build the GoRouter configuration.
/// Uses [routerAuthNotifier] as refreshListenable so redirects re-evaluate
/// when auth state changes.
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    refreshListenable: routerAuthNotifier,

    // ── Redirect guard ──────────────────────────────────────────────
    redirect: (context, state) {
      final authState = routerAuthNotifier.state;
      final location = state.uri.toString();

      // Always allow splash screen
      if (location == '/splash') return null;

      // Allow auth screens when not logged in
      final authRoutes = ['/signin', '/signup', '/forgot-password', '/otp-verification', '/reset-password'];
      if (!authState.isLoggedIn) {
        if (authRoutes.contains(location) || location == '/access-denied') return null;
        return '/signin';
      }

      // If logged in and on an auth route, redirect to home
      if (authRoutes.contains(location) || location == '/splash') {
        return _getRoleHome(authState.role);
      }

      // Role-based access control
      if (location.startsWith('/admin') && authState.role != 'admin') {
        return '/access-denied';
      }
      if (location.startsWith('/seller') && authState.role != 'seller' && authState.role != 'admin') {
        return '/access-denied';
      }

      return null; // no redirect
    },

    // ── Routes ──────────────────────────────────────────────────────
    routes: [
      // Splash
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),

      // Auth
      GoRoute(path: '/signin', builder: (context, state) => SignInScreen()),
      GoRoute(path: '/signup', builder: (context, state) => SignUpScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/otp-verification', builder: (context, state) => const OtpVerificationScreen()),
      GoRoute(path: '/reset-password', builder: (context, state) => const ResetPasswordScreen()),
      GoRoute(path: '/access-denied', builder: (context, state) => const AccessDeniedScreen()),

      // ── Customer Shell ──────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => CustomerShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/customer/home', builder: (context, state) => HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/customer/categories', builder: (context, state) => const CategoriesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/customer/cart', builder: (context, state) => CartScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/customer/chats', builder: (context, state) => const ChatListScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/customer/profile', builder: (context, state) => const ProfileScreen()),
          ]),
        ],
      ),

      // ── Seller Shell ────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => SellerShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/seller/dashboard', builder: (context, state) => const SellerDashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/seller/products', builder: (context, state) => const MyProductsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/seller/orders', builder: (context, state) => const SellerOrdersScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/seller/chats', builder: (context, state) => const ChatListScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/seller/profile', builder: (context, state) => const ProfileScreen()),
          ]),
        ],
      ),

      // ── Admin Shell ─────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AdminShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/admin/dashboard', builder: (context, state) => const AdminDashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/admin/sellers', builder: (context, state) => const ManageSellersScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/admin/chats', builder: (context, state) => const ChatListScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/admin/profile', builder: (context, state) => const ProfileScreen()),
          ]),
        ],
      ),

      // ── Push routes (outside shell) ─────────────────────────────
      GoRoute(
        path: '/product-details',
        builder: (context, state) {
          final product = state.extra as Map<String, dynamic>;
          return ProductDetailScreen(product: product);
        },
      ),
      GoRoute(
        path: '/order-details',
        builder: (context, state) {
          final order = state.extra as Map<String, dynamic>;
          return customer_order.OrderDetailsScreen(order: order);
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsListScreen(),
      ),
      GoRoute(
        path: '/wishlist',
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: '/my-orders',
        builder: (context, state) => const MyOrdersScreen(),
      ),
      GoRoute(
        path: '/seller/edit-product',
        builder: (context, state) {
          final product = state.extra as Map<String, dynamic>;
          return EditProductScreen(product: product);
        },
      ),
      GoRoute(
        path: '/seller/add-product',
        builder: (context, state) => const AddProductScreen(),
      ),
      GoRoute(
        path: '/seller/order-details',
        builder: (context, state) {
          final order = state.extra as Map<String, dynamic>;
          return seller_order.OrderDetailsScreen(order: order);
        },
      ),
      GoRoute(
        path: '/privacy-security',
        builder: (context, state) => const PrivacySecurityScreen(),
      ),
      GoRoute(
        path: '/become-seller',
        builder: (context, state) => const BecomeSellersScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const ManageSellersScreen(),
      ),
      GoRoute(
        path: '/admin/orders',
        builder: (context, state) => const SellerManagementScreen(),
      ),
    ],

    // ── Error page ─────────────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('404: ${state.error?.message ?? "Page not found"}'),
      ),
    ),
  );
}