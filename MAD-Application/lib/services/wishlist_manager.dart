import 'package:flutter/foundation.dart';
import 'package:madpractical/services/preferences_service.dart';

class WishlistManager extends ChangeNotifier {
  static final WishlistManager _instance = WishlistManager._internal();
  
  factory WishlistManager() {
    return _instance;
  }
  
  WishlistManager._internal();

  final List<Map<String, dynamic>> _wishlistItems = [];

  /// Call once at startup (after PreferencesService.init()) to restore wishlist.
  void loadFromPrefs() {
    _wishlistItems
      ..clear()
      ..addAll(PreferencesService.wishlistItems);
    notifyListeners();
  }

  Future<void> _persist() async {
    await PreferencesService.saveWishlistItems(
        List<Map<String, dynamic>>.from(_wishlistItems));
  }

  List<Map<String, dynamic>> get wishlistItems => List.unmodifiable(_wishlistItems);

  bool isInWishlist(String productName) {
    return _wishlistItems.any((item) => item['name'] == productName);
  }

  void addToWishlist(Map<String, dynamic> product) {
    if (!isInWishlist(product['name'])) {
      _wishlistItems.add(product);
      _persist();
      notifyListeners();
    }
  }

  void removeFromWishlist(String productName) {
    _wishlistItems.removeWhere((item) => item['name'] == productName);
    _persist();
    notifyListeners();
  }

  void toggleWishlist(Map<String, dynamic> product) {
    if (isInWishlist(product['name'])) {
      removeFromWishlist(product['name']);
    } else {
      addToWishlist(product);
    }
  }

  void clearWishlist() {
    _wishlistItems.clear();
    _persist();
    notifyListeners();
  }

  int get itemCount => _wishlistItems.length;
}
