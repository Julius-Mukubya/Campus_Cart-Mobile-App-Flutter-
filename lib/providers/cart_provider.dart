import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madpractical/services/preferences_service.dart';

/// Cart state model - represents cart data
class CartState {
  final List<Map<String, dynamic>> items;

  const CartState({
    this.items = const [],
  });

  int get itemCount => items.length;

  double get subtotal {
    return items.fold(0.0, (sum, item) {
      final price = _getDiscountedPrice(item);
      final quantity = item['quantity'] ?? 1;
      return sum + (price * quantity);
    });
  }

  double get deliveryFee => 5000.0;

  double get total => subtotal + deliveryFee;

  static double _extractPrice(dynamic priceString) {
    if (priceString is double) return priceString;
    if (priceString is int) return priceString.toDouble();
    final numericString = priceString.toString().replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(numericString) ?? 0.0;
  }

  static double _getDiscountedPrice(Map<String, dynamic> item) {
    final originalPrice = _extractPrice(item['price']);

    if (item['discount'] != null && item['discount'].toString().isNotEmpty) {
      final discountStr = item['discount'].toString().replaceAll(RegExp(r'[^0-9]'), '');
      final discountPercent = double.tryParse(discountStr) ?? 0.0;

      if (discountPercent > 0) {
        final discountAmount = originalPrice * (discountPercent / 100);
        return originalPrice - discountAmount;
      }
    }

    return originalPrice;
  }

  CartState copyWith({
    List<Map<String, dynamic>>? items,
  }) {
    return CartState(
      items: items ?? this.items,
    );
  }
}

/// CartNotifier - handles cart state updates
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  /// Load cart from preferences (call at startup)
  void loadFromPrefs() {
    final savedItems = PreferencesService.cartItems;
    state = state.copyWith(items: List<Map<String, dynamic>>.from(savedItems));
  }

  Future<void> _persist() async {
    await PreferencesService.saveCartItems(List<Map<String, dynamic>>.from(state.items));
  }

  void addToCart(Map<String, dynamic> product) {
    final existingIndex = state.items.indexWhere((item) => item['name'] == product['name']);

    final updatedItems = List<Map<String, dynamic>>.from(state.items);

    if (existingIndex != -1) {
      updatedItems[existingIndex]['quantity'] =
          (updatedItems[existingIndex]['quantity'] ?? 1) + 1;
    } else {
      final cartItem = Map<String, dynamic>.from(product);
      cartItem['quantity'] = 1;
      updatedItems.add(cartItem);
    }

    state = state.copyWith(items: updatedItems);
    _persist();
  }

  void removeFromCart(String productName) {
    final updatedItems = List<Map<String, dynamic>>.from(state.items);
    updatedItems.removeWhere((item) => item['name'] == productName);
    state = state.copyWith(items: updatedItems);
    _persist();
  }

  void updateQuantity(String productName, int quantity) {
    final index = state.items.indexWhere((item) => item['name'] == productName);
    if (index != -1) {
      final updatedItems = List<Map<String, dynamic>>.from(state.items);
      if (quantity <= 0) {
        updatedItems.removeAt(index);
      } else {
        updatedItems[index]['quantity'] = quantity;
      }
      state = state.copyWith(items: updatedItems);
      _persist();
    }
  }

  void clearCart() {
    state = const CartState(items: []);
    _persist();
  }

  bool isInCart(String productName) {
    return state.items.any((item) => item['name'] == productName);
  }
}

/// Cart provider - provides access to cart state
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
