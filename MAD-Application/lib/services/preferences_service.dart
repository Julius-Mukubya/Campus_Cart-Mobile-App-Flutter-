import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _keyUserId = 'user_id';
  static const _keyUserName = 'user_name';
  static const _keyUserEmail = 'user_email';
  static const _keyUserPhone = 'user_phone';
  static const _keyUserRole = 'user_role';
  static const _keyStaffType = 'staff_type';
  static const _keyStoreId = 'store_id';
  static const _keyProfileImage = 'profile_image';
  static const _keyOnboardingSeen = 'onboarding_seen';
  static const _keyLastCategory = 'last_category';
  static const _keySortBy = 'sort_by';
  static const _keyNotificationsEnabled = 'notifications_enabled';
  static const _keyThemeMode = 'theme_mode';
  static const _keyLanguage = 'language';
  static const _keyCartItems = 'cart_items';
  static const _keyWishlistItems = 'wishlist_items';
  static const _keySearchHistory = 'search_history';
  static const _keyRecentlyViewed = 'recently_viewed';
  static const int _maxSearchHistory = 10;
  static const int _maxRecentlyViewed = 20;

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    assert(_prefs != null, 'PreferencesService.init() must be called first');
    return _prefs!;
  }

  // ── User session ──────────────────────────────────────────────────────────

  static Future<void> saveUser({
    required String userId,
    required String name,
    required String email,
    String phone = '',
    String role = 'customer',
    String? staffType,
    String? storeId,
    String profileImage = '',
  }) async {
    await _instance.setString(_keyUserId, userId);
    await _instance.setString(_keyUserName, name);
    await _instance.setString(_keyUserEmail, email);
    await _instance.setString(_keyUserPhone, phone);
    await _instance.setString(_keyUserRole, role);
    if (staffType != null) {
      await _instance.setString(_keyStaffType, staffType);
    } else {
      await _instance.remove(_keyStaffType);
    }
    if (storeId != null) {
      await _instance.setString(_keyStoreId, storeId);
    } else {
      await _instance.remove(_keyStoreId);
    }
    await _instance.setString(_keyProfileImage, profileImage);
  }

  static Future<void> clearUser() async {
    await _instance.remove(_keyUserId);
    await _instance.remove(_keyUserName);
    await _instance.remove(_keyUserEmail);
    await _instance.remove(_keyUserPhone);
    await _instance.remove(_keyUserRole);
    await _instance.remove(_keyStaffType);
    await _instance.remove(_keyStoreId);
    await _instance.remove(_keyProfileImage);
  }

  static String? get userId => _instance.getString(_keyUserId);
  static String get userName => _instance.getString(_keyUserName) ?? '';
  static String get userEmail => _instance.getString(_keyUserEmail) ?? '';
  static String get userPhone => _instance.getString(_keyUserPhone) ?? '';
  static String get userRole => _instance.getString(_keyUserRole) ?? 'customer';
  static String? get staffType => _instance.getString(_keyStaffType);
  static String? get storeId => _instance.getString(_keyStoreId);
  static String get profileImage => _instance.getString(_keyProfileImage) ?? '';
  static bool get isLoggedIn => userId != null && userId!.isNotEmpty;

  // ── App preferences ───────────────────────────────────────────────────────

  static Future<void> setOnboardingSeen() async =>
      _instance.setBool(_keyOnboardingSeen, true);
  static bool get onboardingSeen =>
      _instance.getBool(_keyOnboardingSeen) ?? false;

  static Future<void> setLastCategory(String category) async =>
      _instance.setString(_keyLastCategory, category);
  static String get lastCategory =>
      _instance.getString(_keyLastCategory) ?? 'All';

  static Future<void> setSortBy(String sortBy) async =>
      _instance.setString(_keySortBy, sortBy);
  static String get sortBy =>
      _instance.getString(_keySortBy) ?? 'Default';

  static Future<void> setNotificationsEnabled(bool enabled) async =>
      _instance.setBool(_keyNotificationsEnabled, enabled);
  static bool get notificationsEnabled =>
      _instance.getBool(_keyNotificationsEnabled) ?? true;

  static Future<void> setThemeMode(String mode) async =>
      _instance.setString(_keyThemeMode, mode);
  static String get themeMode =>
      _instance.getString(_keyThemeMode) ?? 'light';

  static Future<void> setLanguage(String langCode) async =>
      _instance.setString(_keyLanguage, langCode);
  static String get language =>
      _instance.getString(_keyLanguage) ?? 'en';

  // ── Cart persistence ──────────────────────────────────────────────────────

  static Future<void> saveCartItems(List<Map<String, dynamic>> items) async {
    final encoded = jsonEncode(items);
    await _instance.setString(_keyCartItems, encoded);
  }

  static List<Map<String, dynamic>> get cartItems {
    final raw = _instance.getString(_keyCartItems);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearCartItems() async =>
      _instance.remove(_keyCartItems);

  // ── Wishlist persistence ──────────────────────────────────────────────────

  static Future<void> saveWishlistItems(List<Map<String, dynamic>> items) async {
    final encoded = jsonEncode(items);
    await _instance.setString(_keyWishlistItems, encoded);
  }

  static List<Map<String, dynamic>> get wishlistItems {
    final raw = _instance.getString(_keyWishlistItems);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearWishlistItems() async =>
      _instance.remove(_keyWishlistItems);

  // ── Search history ────────────────────────────────────────────────────────

  static List<String> get searchHistory {
    return _instance.getStringList(_keySearchHistory) ?? [];
  }

  static Future<void> addSearchQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final history = searchHistory;
    history.remove(trimmed); // remove duplicate if exists
    history.insert(0, trimmed); // most recent first
    if (history.length > _maxSearchHistory) {
      history.removeRange(_maxSearchHistory, history.length);
    }
    await _instance.setStringList(_keySearchHistory, history);
  }

  static Future<void> removeSearchQuery(String query) async {
    final history = searchHistory;
    history.remove(query);
    await _instance.setStringList(_keySearchHistory, history);
  }

  static Future<void> clearSearchHistory() async =>
      _instance.remove(_keySearchHistory);

  // ── Recently viewed products ──────────────────────────────────────────────

  static List<Map<String, dynamic>> get recentlyViewed {
    final raw = _instance.getString(_keyRecentlyViewed);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addRecentlyViewed(Map<String, dynamic> product) async {
    final items = recentlyViewed;
    // Remove if already present (by name or id)
    final id = product['id'] ?? product['name'];
    items.removeWhere((p) => (p['id'] ?? p['name']) == id);
    items.insert(0, product);
    if (items.length > _maxRecentlyViewed) {
      items.removeRange(_maxRecentlyViewed, items.length);
    }
    await _instance.setString(_keyRecentlyViewed, jsonEncode(items));
  }

  static Future<void> clearRecentlyViewed() async =>
      _instance.remove(_keyRecentlyViewed);
}
