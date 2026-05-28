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
import 'package:madpractical/providers/cart_provider.dart';
import 'package:madpractical/providers/wishlist_provider.dart';
import 'package:madpractical/providers/notification_provider.dart';
import 'package:madpractical/providers/chat_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:madpractical/router.dart';
import 'package:madpractical/services/fcm_service.dart';
import 'package:madpractical/utils/app_logger.dart';

/// Top-level background message handler — must be outside main().
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FcmService.backgroundHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await PreferencesService.init();
  AppSettings().loadFromPrefs();

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FcmService().init();

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeProviders();
      }
    });
  }

  void _initializeProviders() {
    try {
      ref.read(cartProvider.notifier).loadFromPrefs();
    } catch (e) {
      AppLogger.error('Failed to load cart', error: e);
    }

    try {
      ref.read(wishlistProvider.notifier).loadFromPrefs();
    } catch (e) {
      AppLogger.error('Failed to load wishlist', error: e);
    }

    // Start notification listener if user is already logged in
    final savedUserId = PreferencesService.userId;
    if (savedUserId != null && savedUserId.isNotEmpty) {
      ref.read(notificationProvider.notifier).startListening(savedUserId);
    }

    // Restore user session
    if (PreferencesService.isLoggedIn) {
      final userId = PreferencesService.userId;
      if (userId != null && userId.isNotEmpty) {
        try {
          ref.read(userProvider.notifier).updateUser(
            userId: userId,
            name: PreferencesService.userName,
            email: PreferencesService.userEmail,
            phone: PreferencesService.userPhone,
            profileImage: PreferencesService.profileImage,
            role: PreferencesService.userRole,
            storeId: PreferencesService.storeId,
          );
          FcmService().setUserId(userId);
        } catch (e) {
          AppLogger.error('Failed to restore user session', error: e);
        }
      }
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
        ),
        dialogTheme: DialogThemeData(backgroundColor: AppColors.darkCards),
      );

  @override
  Widget build(BuildContext context) {
    ref.listen(userProvider, (prev, next) {
      routerAuthNotifier.update(RouterUserState(
        isLoggedIn: next.userId != null && next.userId!.isNotEmpty,
        role: next.role,
      ));
      if (next.userId != null && next.userId!.isNotEmpty) {
        FcmService().setUserId(next.userId!);
        ref.read(notificationProvider.notifier).startListening(next.userId!);
        ref.read(chatProvider.notifier).startChatListStream(next.userId!);
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