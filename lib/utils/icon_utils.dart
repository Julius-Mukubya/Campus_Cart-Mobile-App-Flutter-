import 'package:flutter/material.dart';

/// Centralized mapping of icon name strings (stored in Firestore) to Flutter IconData.
///
/// Storing the actual icon identifier (e.g. 'devices', 'checkroom') in Firestore
/// allows changing icons without code changes — just update the Firestore field.
class AppIcons {
  AppIcons._();

  /// Map of icon name → IconData for all supported category icons.
  static const Map<String, IconData> all = {
    'devices': Icons.devices,
    'checkroom': Icons.checkroom,
    'menu_book': Icons.menu_book,
    'restaurant': Icons.restaurant,
    'edit': Icons.edit,
    'sports_soccer': Icons.sports_soccer,
    'home': Icons.home,
    'face': Icons.face,
    'music_note': Icons.music_note,
    'pets': Icons.pets,
    'toys': Icons.toys,
    'local_hospital': Icons.local_hospital,
    'watch': Icons.watch,
    'category': Icons.category,
  };

  /// List of available icon entries for dropdown pickers.
  static const List<Map<String, dynamic>> pickerItems = [
    {'name': 'devices', 'label': 'Electronics', 'icon': Icons.devices},
    {'name': 'checkroom', 'label': 'Fashion', 'icon': Icons.checkroom},
    {'name': 'menu_book', 'label': 'Books', 'icon': Icons.menu_book},
    {'name': 'restaurant', 'label': 'Food', 'icon': Icons.restaurant},
    {'name': 'edit', 'label': 'Stationery', 'icon': Icons.edit},
    {'name': 'sports_soccer', 'label': 'Sports', 'icon': Icons.sports_soccer},
    {'name': 'home', 'label': 'Home', 'icon': Icons.home},
    {'name': 'face', 'label': 'Beauty', 'icon': Icons.face},
    {'name': 'music_note', 'label': 'Music', 'icon': Icons.music_note},
    {'name': 'pets', 'label': 'Pets', 'icon': Icons.pets},
    {'name': 'toys', 'label': 'Toys', 'icon': Icons.toys},
    {'name': 'local_hospital', 'label': 'Health', 'icon': Icons.local_hospital},
    {'name': 'watch', 'label': 'Accessories', 'icon': Icons.watch},
    {'name': 'category', 'label': 'General', 'icon': Icons.category},
  ];

  /// Resolve an icon name string to an IconData.
  ///
  /// [iconName] should be a string like 'devices' or 'checkroom' stored in Firestore.
  /// Returns [Icons.category] as fallback if [iconName] is null or unknown.
  static IconData resolve(String? iconName) {
    if (iconName == null || iconName.isEmpty) return Icons.category;
    // Try direct lookup first (fast path for identifier-based names)
    final directMatch = all[iconName];
    if (directMatch != null) return directMatch;
    // Try interpreting the name as a Material icon string (e.g. 'Icons.devices' → Icons.devices)
    // This is a fallback for any legacy or custom icon names.
    try {
      final icon = IconData(int.parse(iconName));
      if (icon != Icons.category) return icon;
    } catch (_) {
      // Not an IconData code point, continue
    }
    return Icons.category;
  }

  /// Legacy: map from category title name (backward compatibility).
  /// This supports old data where icon was stored as 'Electronics' instead of 'devices'.
  static IconData resolveLegacy(String? iconName) {
    // Map old category title names to icon identifiers
    const legacyMap = {
      'Electronics': 'devices',
      'Fashion': 'checkroom',
      'Books': 'menu_book',
      'Stationery': 'edit',
      'Sports': 'sports_soccer',
      'Home': 'home',
      'Beauty': 'face',
      'Music': 'music_note',
      'Pets': 'pets',
      'Toys': 'toys',
      'Health': 'local_hospital',
      'Accessories': 'watch',
      'General': 'category',
    };
    if (iconName != null && legacyMap.containsKey(iconName)) {
      return all[legacyMap[iconName]!]!;
    }
    return resolve(iconName);
  }
}