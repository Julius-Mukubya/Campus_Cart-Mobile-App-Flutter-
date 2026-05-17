import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madpractical/services/managers/preferences_service.dart';

/// Wishlist state model - represents wishlist data
class WishlistState {
  final List<Map<String, dynamic>> items;

  const WishlistState({
    this.items = const [],
  });

  int get itemCount => items.length;

  WishlistState copyWith({
    List<Map<String, dynamic>>? items,
  }) {
    return WishlistState(
      items: items ?? this.items,
    );
  }
}

/// WishlistNotifier - handles wishlist state updates
class WishlistNotifier extends StateNotifier<WishlistState> {
  WishlistNotifier() : super(const WishlistState());

  /// Load wishlist from preferences (call at startup)
  void loadFromPrefs() {
    final savedItems = PreferencesService.wishlistItems;
    state = state.copyWith(items: List<Map<String, dynamic>>.from(savedItems));
  }

  Future<void> _persist() async {
    await PreferencesService.saveWishlistItems(List<Map<String, dynamic>>.from(state.items));
  }

  bool isInWishlist(String productName) {
    return state.items.any((item) => item['name'] == productName);
  }

  void addToWishlist(Map<String, dynamic> product) {
    if (!isInWishlist(product['name'])) {
      final updatedItems = List<Map<String, dynamic>>.from(state.items);
      updatedItems.add(product);
      state = state.copyWith(items: updatedItems);
      _persist();
    }
  }

  void removeFromWishlist(String productName) {
    final updatedItems = List<Map<String, dynamic>>.from(state.items);
    updatedItems.removeWhere((item) => item['name'] == productName);
    state = state.copyWith(items: updatedItems);
    _persist();
  }

  void toggleWishlist(Map<String, dynamic> product) {
    if (isInWishlist(product['name'])) {
      removeFromWishlist(product['name']);
    } else {
      addToWishlist(product);
    }
  }

  void clearWishlist() {
    state = const WishlistState(items: []);
    _persist();
  }
}

/// Wishlist provider - provides access to wishlist state
final wishlistProvider = StateNotifierProvider<WishlistNotifier, WishlistState>((ref) {
  return WishlistNotifier();
});
