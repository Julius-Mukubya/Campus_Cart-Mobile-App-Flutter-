import 'package:flutter/foundation.dart';

class UserManager extends ChangeNotifier {
  static final UserManager _instance = UserManager._internal();
  
  factory UserManager() {
    return _instance;
  }
  
  UserManager._internal();

  // User data
  String _name = 'John Doe';
  String _email = 'johndoe@example.com';
  String _phone = '+256 700 123 456';
  String _profileImage = 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop';
  bool _isPremium = true;
  
  // Getters
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get profileImage => _profileImage;
  bool get isPremium => _isPremium;
  
  // Update methods
  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? profileImage,
  }) {
    if (name != null) _name = name;
    if (email != null) _email = email;
    if (phone != null) _phone = phone;
    if (profileImage != null) _profileImage = profileImage;
    notifyListeners();
  }
  
  void logout() {
    // Reset to defaults or clear data
    notifyListeners();
  }
}
