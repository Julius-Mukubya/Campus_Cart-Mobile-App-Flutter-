import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/app_settings.dart';
import 'package:madpractical/services/preferences_service.dart';
import 'package:madpractical/providers/user_provider.dart';
import 'package:madpractical/providers/auth_provider.dart';
import 'package:madpractical/providers/cart_provider.dart';
import 'package:madpractical/providers/wishlist_provider.dart';
import 'package:madpractical/providers/notification_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:madpractical/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize SharedPreferences
  await PreferencesService.init();

  // Load saved theme and language
  AppSettings().loadFromPrefs();

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

  // Initialize router auth state
  routerAuthNotifier.update(RouterUserState(
    isLoggedIn: false,
    role: 'customer',
  ));

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final AppSettings _settings = AppSettings();
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = buildRouter();
    _settings.addListener(_onSettingsChanged);
    // Defer provider initialization to after the first frame is built,
    // preventing the ProviderScope element from being rebuilt mid-mount.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  void _initializeProviders() {
    // Initialize cart from preferences
    ref.read(cartProvider.notifier).loadFromPrefs();
    // Initialize wishlist from preferences
    ref.read(wishlistProvider.notifier).loadFromPrefs();
    // Initialize notifications (will be connected to Firestore in TASK 6)
    ref.read(notificationProvider.notifier).loadFromPrefs();

    // Restore user session from SharedPreferences into user provider
    if (PreferencesService.isLoggedIn) {
      ref.read(userProvider.notifier).updateProfile(
        userId: PreferencesService.userId,
        name: PreferencesService.userName,
        email: PreferencesService.userEmail,
        phone: PreferencesService.userPhone,
        role: PreferencesService.userRole,
        storeId: PreferencesService.storeId,
      );
    }
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
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.darkCards,
          error: AppColors.error,
          onSurface: AppColors.darkText,
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
                  ? AppColors.primary.withValues(alpha: 0.4)
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
        ), dialogTheme: DialogThemeData(backgroundColor: AppColors.darkCards),
      );

  Widget build(BuildContext context) {
    // Sync user provider changes to router auth notifier
    ref.listen(userProvider, (prev, next) {
      routerAuthNotifier.update(RouterUserState(
        isLoggedIn: next.userId != null && next.userId!.isNotEmpty,
        role: next.role,
      ));
    });

    // Sync auth provider changes to user provider (fix guest user after login)
    ref.listen<AuthState>(authProvider, (AuthState? prev, AuthState next) {
      final justLoggedIn = next.isLoggedIn && !(prev?.isLoggedIn ?? false);
      if (justLoggedIn) {
        ref.read(userProvider.notifier).updateProfile(
          userId: next.userId,
          email: next.email ?? PreferencesService.userEmail,
          name: PreferencesService.userName,
          phone: PreferencesService.userPhone,
          role: next.userRole ?? PreferencesService.userRole,
          storeId: PreferencesService.storeId,
          profileImage: PreferencesService.profileImage,
        );
      }
    });

    return MaterialApp.router(
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
      routerConfig: _router,
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
    );
  }
}
