import 'package:flutter/material.dart';

class AppColors {
  // Light Mode Theme
  static const Color primary = Color(0xFF1A73E8);
  static const Color background = Color(0xFFFFFFFF);
  static const Color cards = Color(0xFFF8F9FA);
  static const Color buttons = Color(0xFFFF9800);
  static const Color text = Color(0xFF212121);
  static const Color secondaryText = Color(0xFF616161);
  
  // Common Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color grey = Color(0xFF616161);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color secondary = Color(0xFFF5F7FA);
  static const Color accent = Color(0xFFFF9800);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF0D47A1)],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, cards],
  );
}