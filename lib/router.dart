import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madpractical/constants/app_colors.dart';

// Auth screens
import 'package:madpractical/pages/auth/sign_in_screen.dart';
import 'package:madpractical/pages/auth/sign_up_screen.dart';
import 'package:madpractical/pages/auth/forgot_password_screen.dart';
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

// Seller screens
import 'package:madpractical/pages/seller/seller_dashboard_screen.dart';
import 'package:madpractical/pages/seller/my_products_screen.dart';
import 'package:madpractical/pages/seller/seller_orders_screen.dart';
import 'package:madpractical/pages/seller/add_product_screen.dart';
import 'package:madpractical/pages/seller/edit_product_screen.dart';
import 'package:madpractical/pages/seller/seller_order_details_screen.dart' as seller_order;

// Admin screens
import 'package:madpractical/pages/admin/admin_dashboard_screen.dart';
import 'package:madpractical/pages/admin/manage_sellers_screen.dart';
import 'package:madpractical/pages/admin/manage_users_screen.dart';
import 'package:madpractical/pages/admin/admin_orders_screen.dart';
import 'package:madpractical/pages/admin/manage_categories_screen.dart';
import 'package:madpractical/pages/admin/add_category_screen.dart';


// Profile screens
import 'package:madpractical/pages/profile/profile_screen.dart';
import 'package:madpractical/pages/profile/edit_profile_screen.dart';
import 'package:madpractical/pages/profile/privacy_security_screen.dart';
import 'package:madpractical/pages/profile/change_password_screen.dart';
import 'package:madpractical/pages/profile/become_seller_screen.dart';
import 'package:madpractical/pages/profile/faq_screen.dart';
import 'package:madpractical/pages/profile/contact_us_screen.dart';

// Chat screens
import 'package:madpractical/pages/chat/chat_list_screen.dart';
import 'package:madpractical/pages/chat/chat_screen.dart';

// Shell screen
import 'package:madpractical/widgets/navigation/main_shell.dart';

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
/// All roles use the same home route now.
String _getRoleHome(String role) {
  return '/home';
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
      final authRoutes = ['/signin', '/signup', '/forgot-password'];
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
      GoRoute(path: '/access-denied', builder: (context, state) => const AccessDeniedScreen()),

      // ── Unified Main Shell (same bottom nav for all roles) ─────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          // Tab 0: Home
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const _HomeTab(),
            ),
          ]),
          // Tab 1: Categories / My Products / Manage Sellers
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/browse',
              builder: (context, state) => const _BrowseTab(),
            ),
          ]),
          // Tab 2: Cart
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/cart',
              builder: (context, state) => CartScreen(),
            ),
          ]),
          // Tab 3: Chats
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/chats',
              builder: (context, state) => const ChatListScreen(),
            ),
          ]),
          // Tab 4: Profile
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ]),
        ],
      ),

      // ── Push routes (outside shell) ─────────────────────────────
      // Role-specific dashboards (accessed from Profile screen)
      GoRoute(
        path: '/seller/dashboard',
        builder: (context, state) => const SellerDashboardScreen(),
      ),
      GoRoute(
        path: '/seller/products',
        builder: (context, state) => const MyProductsScreen(),
      ),
      GoRoute(
        path: '/seller/orders',
        builder: (context, state) => const SellerOrdersScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/sellers',
        builder: (context, state) => const ManageSellersScreen(),
      ),
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
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/become-seller',
        builder: (context, state) => const BecomeSellersScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const ManageUsersScreen(),
      ),
      GoRoute(
        path: '/admin/orders',
        builder: (context, state) => const AdminOrdersScreen(),
      ),
      GoRoute(
        path: '/admin/categories',
        builder: (context, state) => const ManageCategoriesScreen(),
      ),
      GoRoute(
        path: '/admin/categories/edit',
        builder: (context, state) {
          final category = state.extra as Map<String, dynamic>?;
          return AddCategoryScreen(category: category);
        },
      ),

      // ── FAQ & Contact Us ──────────────────────────────────────────
      GoRoute(
        path: '/faq',
        builder: (context, state) => const FaqScreen(),
      ),
      GoRoute(
        path: '/contact-us',
        builder: (context, state) => const ContactUsScreen(),
      ),

      // ── Chat list route (standalone with back button) ─────────────
      GoRoute(
        path: '/chat-list',
        builder: (context, state) => Scaffold(
          backgroundColor: AppColors.getBackground(context),
          appBar: AppBar(
            title: const Text('Chats'),
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.text,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.text),
              onPressed: () => context.pop(),
            ),
          ),
          body: const ChatListScreen(),
        ),
      ),

      // ── Chat route ────────────────────────────────────────────────
      GoRoute(
        path: '/chat/:chatId',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          final extra = state.extra as Map<String, dynamic>?;
          return ChatScreen(
            chatId: chatId,
            otherParticipantName: extra?['name']?.toString() ?? 'User',
            isOrderChat: extra?['isOrderChat'] == true,
          );
        },
      ),

      // ── Store route ───────────────────────────────────────────────
      GoRoute(
        path: '/store',
        builder: (context, state) => const StorePage(),
      ),
      GoRoute(
        path: '/store/:sellerId',
        builder: (context, state) {
          final sellerId = state.pathParameters['sellerId'];
          return StorePage(sellerId: sellerId);
        },
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

/// Tab 0: Home — same product browsing for ALL roles.
/// Sellers and admins access their dashboards from the Profile screen.
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

/// Tab 1: Browse — same categories for ALL roles.
class _BrowseTab extends StatelessWidget {
  const _BrowseTab();

  @override
  Widget build(BuildContext context) {
    return const CategoriesScreen();
  }
}
