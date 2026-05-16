import 'package:flutter/material.dart';
import 'package:madpractical/services/app_settings.dart';

class AppColors {
  // Primary brand colors — same in both themes
  static const Color primary = Color(0xFF1A73E8);
  static const Color buttons = Color(0xFFFF9800);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color grey = Color(0xFF616161);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color accent = Color(0xFFFF9800);

  // Light mode values (kept as const for backward compat)
  static const Color _lightBackground = Color(0xFFFFFFFF);
  static const Color _lightCards = Color(0xFFF8F9FA);
  static const Color _lightSecondary = Color(0xFFF5F7FA);

  // Text colors — const, dark mode text handled via ThemeData and DefaultTextStyle
  static const Color text = Color(0xFF212121);
  static const Color secondaryText = Color(0xFF616161);

  // Dark mode values
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCards = Color(0xFF1E1E1E);
  static const Color darkText = Color(0xFFE0E0E0);
  static const Color darkSecondaryText = Color(0xFF9E9E9E);
  static const Color darkSurface = Color(0xFF2C2C2C);

  // Dynamic getters — read from AppSettings singleton (no context needed)
  static bool get _isDark => AppSettings().isDark;

  static Color get background => _isDark ? darkBackground : _lightBackground;
  static Color get cards => _isDark ? darkCards : _lightCards;
  static Color get secondary => _isDark ? darkSurface : _lightSecondary;

  // Context-based helpers (for when you have context)
  static Color getBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBackground : _lightBackground;
  static Color getCards(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCards : _lightCards;
  static Color getText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkText : text;
  static Color getSecondaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSecondaryText : secondaryText;
  static Color getSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurface : _lightBackground;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF0D47A1)],
  );

  static LinearGradient get backgroundGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, cards],
  );
}