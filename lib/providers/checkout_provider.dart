import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/order_service.dart';
import '../utils/app_logger.dart';

/// Checkout state model
class CheckoutState {
  final int currentStep; // 0: address, 1: payment, 2: review, 3: confirm
  final Map<String, dynamic>? selectedAddress;
  final String? selectedPaymentMethod; // 'MTN', 'Airtel', etc.
  final bool isProcessing;
  final String? error;
  final String? orderConfirmationId;
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double deliveryFee;
  final double total;

  const CheckoutState({
    this.currentStep = 0,
    this.selectedAddress,
    this.selectedPaymentMethod,
    this.isProcessing = false,
    this.error,
    this.orderConfirmationId,
    this.cartItems = const [],
    this.subtotal = 0.0,
    this.deliveryFee = 0.0,
    this.total = 0.0,
  });

  CheckoutState copyWith({
    int? currentStep,
    Map<String, dynamic>? selectedAddress,
    String? selectedPaymentMethod,
    bool? isProcessing,
    String? error,
    String? orderConfirmationId,
    List<Map<String, dynamic>>? cartItems,
    double? subtotal,
    double? deliveryFee,
    double? total,
  }) {
    return CheckoutState(
      currentStep: currentStep ?? this.currentStep,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      orderConfirmationId: orderConfirmationId ?? this.orderConfirmationId,
      cartItems: cartItems ?? this.cartItems,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
    );
  }
}

/// Checkout notifier for managing checkout state
class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final OrderService _orderService = OrderService();

  CheckoutNotifier() : super(const CheckoutState());

  /// Go to next step
  void nextStep() {
    if (state.currentStep < 3) {
      state = state.copyWith(currentStep: state.currentStep + 1);
      AppLogger.info('Checkout step: ${state.currentStep}');
    }
  }

  /// Go to previous step
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
      AppLogger.info('Checkout step: ${state.currentStep}');
    }
  }

  /// Select delivery address
  void selectAddress(Map<String, dynamic> address) {
    state = state.copyWith(selectedAddress: address);
    AppLogger.info('Address selected: ${address['label']}');
  }

  /// Select payment method
  void selectPaymentMethod(String method) {
    state = state.copyWith(selectedPaymentMethod: method);
    AppLogger.info('Payment method selected: $method');
  }

  /// Update cart items and totals
  void updateCart({
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double deliveryFee,
  }) {
    final total = subtotal + deliveryFee;
    state = state.copyWith(
      cartItems: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
    );
  }

  /// Process payment and create order
  Future<void> processPayment() async {
    if (state.selectedAddress == null) {
      state = state.copyWith(error: 'Please select a delivery address');
      return;
    }

    if (state.selectedPaymentMethod == null) {
      state = state.copyWith(error: 'Please select a payment method');
      return;
    }

    if (state.cartItems.isEmpty) {
      state = state.copyWith(error: 'Cart is empty');
      return;
    }

    state = state.copyWith(isProcessing: true, error: null);
    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Create order
      final orderId = await _orderService.createOrder(
        items: state.cartItems,
        deliveryAddress: state.selectedAddress!,
        paymentMethod: state.selectedPaymentMethod!,
        total: state.total,
      );

      state = state.copyWith(
        isProcessing: false,
        orderConfirmationId: orderId,
      );
      AppLogger.info('Order created: $orderId');
    } catch (e) {
      AppLogger.error('Payment processing error', error: e);
      state = state.copyWith(
        isProcessing: false,
        error: 'Payment failed: $e',
      );
    }
  }

  /// Place order
  Future<void> placeOrder() async {
    if (state.orderConfirmationId == null) {
      state = state.copyWith(error: 'No order to place');
      return;
    }

    state = state.copyWith(isProcessing: true, error: null);
    try {
      await _orderService.confirmOrder(state.orderConfirmationId!);
      state = state.copyWith(isProcessing: false);
      AppLogger.info('Order placed: ${state.orderConfirmationId}');
    } catch (e) {
      AppLogger.error('Order placement error', error: e);
      state = state.copyWith(
        isProcessing: false,
        error: 'Failed to place order: $e',
      );
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
