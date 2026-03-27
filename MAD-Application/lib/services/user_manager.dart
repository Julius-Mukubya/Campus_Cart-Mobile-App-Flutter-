import 'package:flutter/foundation.dart';

class UserManager extends ChangeNotifier {
  static final UserManager _instance = UserManager._internal();
  
  factory UserManager() {
    return _instance;
  }
  
  UserManager._internal();

  // User data
  String? _userId; // Firebase user ID
  String _name = 'John Doe';
  String _email = 'johndoe@example.com';
  String _phone = '+256 700 123 456';
  String _profileImage = 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop';
  final bool _isPremium = true;
  String _role = 'customer'; // customer, seller, staff, admin
  String? _staffType; // support, delivery (only for staff role)
  String? _storeId; // Store ID for sellers
  
  // Getters
  String? get userId => _userId;
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get profileImage => _profileImage;
  bool get isPremium => _isPremium;
  String get role => _role;
  String? get staffType => _staffType;
  String? get storeId => _storeId;
  
  // Helper getters
  bool get isCustomerSupport => _role == 'staff' && _staffType == 'support';
  bool get isDeliveryPersonnel => _role == 'staff' && _staffType == 'delivery';
  
  // Update methods
  void updateProfile({
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? role,
    String? staffType,
    String? storeId,
  }) {
    if (userId != null) _userId = userId;
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
      // Clear storeId if not seller role
      if (role != 'seller') {
        _storeId = null;
      }
    }
    if (staffType != null && _role == 'staff') _staffType = staffType;
    if (storeId != null && _role == 'seller') _storeId = storeId;
    notifyListeners();
  }
  
  void logout() {
    // Reset to defaults
    _userId = null;
    _name = 'Guest User';
    _email = 'guest@example.com';
    _phone = '+256 700 000 000';
    _role = 'customer';
    _staffType = null;
    _storeId = null;
    notifyListeners();
  }
}
