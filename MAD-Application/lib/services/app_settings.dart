import 'package:flutter/material.dart';
import 'preferences_service.dart';

class AppSettings extends ChangeNotifier {
  static final AppSettings _instance = AppSettings._internal();
  factory AppSettings() => _instance;
  AppSettings._internal();

  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isDark => _themeMode == ThemeMode.dark;

  /// Call once at startup after PreferencesService.init()
  void loadFromPrefs() {
    final saved = PreferencesService.themeMode;
    _themeMode = saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
    _locale = Locale(PreferencesService.language);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await PreferencesService.setThemeMode(mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    await setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> setLanguage(String langCode) async {
    _locale = Locale(langCode);
    await PreferencesService.setLanguage(langCode);
    notifyListeners();
  }

  // Supported languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'sw', 'name': 'Swahili'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'lg', 'name': 'Luganda'},
  ];
}
