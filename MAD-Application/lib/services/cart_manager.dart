import 'package:flutter/foundation.dart';

class CartManager extends ChangeNotifier {
  static final CartManager _instance = CartManager._internal();
  
  factory CartManager() {
    return _instance;
  }
  
  CartManager._internal();

  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => List.unmodifiable(_cartItems);
  
  int get itemCount => _cartItems.length;
  
  double get subtotal {
    return _cartItems.fold(0.0, (sum, item) {
      final price = _extractPrice(item['price']);
      final quantity = item['quantity'] ?? 1;
      return sum + (price * quantity);
    });
  }
  
  double get deliveryFee => 5000.0;
  
  double get total => subtotal + deliveryFee;

  double _extractPrice(String priceString) {
    // Extract numeric value from price string like "UGX 85,000"
    final numericString = priceString.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(numericString) ?? 0.0;
  }

  void addToCart(Map<String, dynamic> product) {
    // Check if product already exists in cart
    final existingIndex = _cartItems.indexWhere(
      (item) => item['name'] == product['name']
    );
    
    if (existingIndex != -1) {
      // Increase quantity if already in cart
      _cartItems[existingIndex]['quantity'] = 
          (_cartItems[existingIndex]['quantity'] ?? 1) + 1;
    } else {
      // Add new item with quantity 1
      final cartItem = Map<String, dynamic>.from(product);
      cartItem['quantity'] = 1;
      _cartItems.add(cartItem);
    }
    
    notifyListeners();
  }

  void removeFromCart(String productName) {
    _cartItems.removeWhere((item) => item['name'] == productName);
    notifyListeners();
  }

  void updateQuantity(String productName, int quantity) {
    final index = _cartItems.indexWhere((item) => item['name'] == productName);
    if (index != -1) {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index]['quantity'] = quantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  bool isInCart(String productName) {
    return _cartItems.any((item) => item['name'] == productName);
  }
}
