import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/order_service.dart';
import '../utils/app_logger.dart';

/// Checkout state model (simplified — no address, no payment)
class CheckoutState {
  final bool isProcessing;
  final String? error;
  final String? orderConfirmationId;
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double total;

  const CheckoutState({
    this.isProcessing = false,
    this.error,
    this.orderConfirmationId,
    this.cartItems = const [],
    this.subtotal = 0.0,
    this.total = 0.0,
  });

  CheckoutState copyWith({
    bool? isProcessing,
    String? error,
    String? orderConfirmationId,
    List<Map<String, dynamic>>? cartItems,
    double? subtotal,
    double? total,
  }) {
    return CheckoutState(
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      orderConfirmationId: orderConfirmationId ?? this.orderConfirmationId,
      cartItems: cartItems ?? this.cartItems,
      subtotal: subtotal ?? this.subtotal,
      total: total ?? this.total,
    );
  }
}

/// Checkout notifier for managing checkout state
class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final OrderService _orderService = OrderService();

  CheckoutNotifier() : super(const CheckoutState());

  /// Update cart items and totals
  void updateCart({
    required List<Map<String, dynamic>> items,
    required double subtotal,
  }) {
    state = state.copyWith(
      cartItems: items,
      subtotal: subtotal,
      total: subtotal, // No delivery fee
    );
  }

  /// Create order directly (simplified — no address, no payment)
  Future<String?> createOrder({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String sellerId,
    required bool showContactToSeller,
  }) async {
    if (state.cartItems.isEmpty) {
      state = state.copyWith(error: 'Cart is empty');
      return null;
    }

    state = state.copyWith(isProcessing: true, error: null);
    try {
      final orderId = await _orderService.createOrder(
        items: state.cartItems,
        total: state.total,
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
        sellerId: sellerId,
        showContactToSeller: showContactToSeller,
      );

      state = state.copyWith(
        isProcessing: false,
        orderConfirmationId: orderId,
      );
      AppLogger.info('Order created: $orderId');
      return orderId;
    } catch (e) {
      AppLogger.error('Order creation error', error: e);
      state = state.copyWith(
        isProcessing: false,
        error: 'Failed to create order: $e',
      );
      return null;
    }
  }

  /// Reset checkout
  void reset() {
    state = const CheckoutState();
    AppLogger.info('Checkout reset');
  }
}

/// Checkout provider
final checkoutProvider =
    StateNotifierProvider<CheckoutNotifier, CheckoutState>(
  (ref) => CheckoutNotifier(),
);