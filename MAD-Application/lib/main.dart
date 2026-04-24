import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
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
import 'package:madpractical/services/preferences_service.dart';
import 'package:madpractical/services/app_settings.dart';
import 'package:madpractical/services/cart_manager.dart';
import 'package:madpractical/services/wishlist_manager.dart';
import 'package:madpractical/services/database_service.dart';
import 'package:madpractical/services/notification_manager.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize SharedPreferences
  await PreferencesService.init();

  // Load saved theme and language
  AppSettings().loadFromPrefs();

  // Restore user session from SharedPreferences into UserManager
  if (PreferencesService.isLoggedIn) {
    UserManager().updateProfile(
      userId: PreferencesService.userId,
      name: PreferencesService.userName,
      email: PreferencesService.userEmail,
      phone: PreferencesService.userPhone,
      role: PreferencesService.userRole,
      staffType: PreferencesService.staffType,
      storeId: PreferencesService.storeId,
    );
  }

  // Restore cart and wishlist from SharedPreferences
  CartManager().loadFromPrefs();
  WishlistManager().loadFromPrefs();

  // Initialize SQLite and load persisted notifications
  await DatabaseService().database; // opens/creates the DB
  await NotificationManager().loadFromDb();

  // Initialize App Check — uses debug provider in debug builds
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  // Enable Firestore offline persistence — serves from local cache,
  // only fetches from network when data is stale or missing
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppSettings _settings = AppSettings();

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() => setState(() {});

  ThemeData _buildLightTheme() => ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.cards,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.cards,
          error: AppColors.error,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF212121)),
          bodyMedium: TextStyle(color: Color(0xFF616161)),
          titleLarge: TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.w600),
          titleSmall: TextStyle(color: Color(0xFF616161)),
          labelLarge: TextStyle(color: Color(0xFF212121)),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: const Color(0xFF212121),
          elevation: 0,
          titleTextStyle: const TextStyle(
            color: Color(0xFF212121),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttons,
            foregroundColor: AppColors.white,
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected) ? AppColors.primary : AppColors.grey),
        ),
      );

  ThemeData _buildDarkTheme() => ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.darkBackground,
        cardColor: AppColors.darkCards,
        dialogBackgroundColor: AppColors.darkCards,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.darkCards,
          error: AppColors.error,
          onSurface: AppColors.darkText,
          onBackground: AppColors.darkText,
          onPrimary: AppColors.white,
          outline: Color(0xFF3A3A3A),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.darkText),
          bodyMedium: TextStyle(color: AppColors.darkSecondaryText),
          titleLarge: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(color: AppColors.darkSecondaryText),
          labelLarge: TextStyle(color: AppColors.darkText),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          foregroundColor: AppColors.darkText,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.darkText),
          titleTextStyle: TextStyle(
            color: AppColors.darkText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkCards,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.darkSecondaryText,
          elevation: 8,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurface,
          labelStyle: const TextStyle(color: AppColors.darkSecondaryText),
          hintStyle: const TextStyle(color: AppColors.darkSecondaryText),
          prefixIconColor: AppColors.darkSecondaryText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.darkText),
        dividerColor: const Color(0xFF2A2A2A),
        dividerTheme: const DividerThemeData(color: Color(0xFF2A2A2A), thickness: 1),
        cardTheme: CardThemeData(
          color: AppColors.darkCards,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF2A2A2A)),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected) ? AppColors.primary : AppColors.darkSecondaryText),
          trackColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected)
                  ? AppColors.primary.withOpacity(0.4)
                  : const Color(0xFF3A3A3A)),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected) ? AppColors.primary : Colors.transparent),
          side: const BorderSide(color: AppColors.darkSecondaryText),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: AppColors.darkSurface,
          contentTextStyle: TextStyle(color: AppColors.darkText),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Cart',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _settings.themeMode,
      locale: _settings.locale,
      supportedLocales: AppSettings.supportedLanguages
          .map((l) => Locale(l['code']!))
          .toList(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // Wrap entire app so all Text widgets inherit the correct color for the theme
        final isDark = _settings.isDark;
        final textColor = isDark ? AppColors.darkText : const Color(0xFF212121);
        return DefaultTextStyle(
          style: TextStyle(
            color: textColor,
            fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
            fontSize: 14,
            decoration: TextDecoration.none,
          ),
          child: IconTheme(
            data: IconThemeData(color: textColor),
            child: child!,
          ),
        );
      },
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
