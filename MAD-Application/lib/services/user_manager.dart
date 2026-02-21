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
  final bool _isPremium = true;
  String _role = 'customer'; // customer, seller, staff, admin
  String? _staffType; // support, delivery (only for staff role)
  
  // Getters
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get profileImage => _profileImage;
  bool get isPremium => _isPremium;
  String get role => _role;
  String? get staffType => _staffType;
  
  // Helper getters
  bool get isCustomerSupport => _role == 'staff' && _staffType == 'support';
  bool get isDeliveryPersonnel => _role == 'staff' && _staffType == 'delivery';
  
  // Update methods
  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? role,
    String? staffType,
  }) {
    if (name != null) _name = name;
    if (email != null) _email = email;
    if (phone != null) _phone = phone;
    if (profileImage != null) _profileImage = profileImage;
    if (role != null) {
      _role = role;
      // Clear staffType if not staff role
      if (role != 'staff') {
        _staffType = null;
      }
    }
    if (staffType != null && _role == 'staff') _staffType = staffType;
    notifyListeners();
  }
  
  void logout() {
    // Reset to defaults
    _name = 'Guest User';
    _email = 'guest@example.com';
    _phone = '+256 700 000 000';
    _role = 'customer';
    _staffType = null;
    notifyListeners();
  }
}
