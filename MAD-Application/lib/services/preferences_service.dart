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
}
