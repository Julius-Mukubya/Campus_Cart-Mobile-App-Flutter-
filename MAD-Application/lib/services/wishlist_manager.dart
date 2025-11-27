import 'package:flutter/foundation.dart';

class WishlistManager extends ChangeNotifier {
  static final WishlistManager _instance = WishlistManager._internal();
  
  factory WishlistManager() {
    return _instance;
  }
  
  WishlistManager._internal();

  final List<Map<String, dynamic>> _wishlistItems = [];

  List<Map<String, dynamic>> get wishlistItems => List.unmodifiable(_wishlistItems);

  bool isInWishlist(String productName) {
    return _wishlistItems.any((item) => item['name'] == productName);
  }

  void addToWishlist(Map<String, dynamic> product) {
    if (!isInWishlist(product['name'])) {
      _wishlistItems.add(product);
      notifyListeners();
    }
  }

  void removeFromWishlist(String productName) {
    _wishlistItems.removeWhere((item) => item['name'] == productName);
    notifyListeners();
  }

  void toggleWishlist(Map<String, dynamic> product) {
    if (isInWishlist(product['name'])) {
      removeFromWishlist(product['name']);
    } else {
      addToWishlist(product);
    }
  }

  int get itemCount => _wishlistItems.length;
}
