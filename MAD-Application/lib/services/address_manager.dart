import 'package:flutter/foundation.dart';

class AddressManager extends ChangeNotifier {
  static final AddressManager _instance = AddressManager._internal();
  
  factory AddressManager() {
    return _instance;
  }
  
  AddressManager._internal();

  final List<Map<String, dynamic>> _addresses = [
    {
      'id': '1',
      'label': 'Home',
      'name': 'John Doe',
      'phone': '+256 700 123 456',
      'address': '123 Main Street, Kampala',
      'city': 'Kampala',
      'isDefault': true,
    },
    {
      'id': '2',
      'label': 'Office',
      'name': 'John Doe',
      'phone': '+256 700 123 456',
      'address': '456 Work Avenue, Kampala',
      'city': 'Kampala',
      'isDefault': false,
    },
  ];

  List<Map<String, dynamic>> get addresses => List.unmodifiable(_addresses);
  
  int get addressCount => _addresses.length;
  
  Map<String, dynamic>? get defaultAddress {
    try {
      return _addresses.firstWhere((addr) => addr['isDefault'] == true);
    } catch (e) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }
  
  void addAddress(Map<String, dynamic> address) {
    _addresses.add(address);
    notifyListeners();
  }
  
  void updateAddress(String id, Map<String, dynamic> updatedAddress) {
    final index = _addresses.indexWhere((addr) => addr['id'] == id);
    if (index != -1) {
      _addresses[index] = {..._addresses[index], ...updatedAddress};
      notifyListeners();
    }
  }
  
  void deleteAddress(String id) {
    _addresses.removeWhere((addr) => addr['id'] == id);
    notifyListeners();
  }
  
  void setDefaultAddress(String id) {
    for (var addr in _addresses) {
      addr['isDefault'] = addr['id'] == id;
    }
    notifyListeners();
  }
}
