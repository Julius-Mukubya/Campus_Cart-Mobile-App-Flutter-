import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/seller_service.dart';
import '../services/order_service.dart';
import '../utils/app_logger.dart';

/// Seller state model
class SellerState {
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> orders;
  final double earnings;
  final int totalOrders;
  final double rating;
  final bool isLoading;
  final String? error;

  const SellerState({
    this.products = const [],
    this.orders = const [],
    this.earnings = 0.0,
    this.totalOrders = 0,
    this.rating = 0.0,
    this.isLoading = false,
    this.error,
  });

  SellerState copyWith({
    List<Map<String, dynamic>>? products,
    List<Map<String, dynamic>>? orders,
    double? earnings,
    int? totalOrders,
    double? rating,
    bool? isLoading,
    String? error,
  }) {
    return SellerState(
      products: products ?? this.products,
      orders: orders ?? this.orders,
      earnings: earnings ?? this.earnings,
      totalOrders: totalOrders ?? this.totalOrders,
      rating: rating ?? this.rating,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Seller notifier for managing seller state
class SellerNotifier extends StateNotifier<SellerState> {
  final SellerService _sellerService = SellerService();
  final OrderService _orderService = OrderService();

  SellerNotifier() : super(const SellerState());

  /// Load seller dashboard
  Future<void> loadDashboard(String sellerId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.wait([
        loadProducts(sellerId),
        loadOrders(sellerId),
      ]);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      AppLogger.error('Failed to load dashboard', error: e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load dashboard: $e',
      );
    }
  }

  /// Load seller products
  Future<void> loadProducts(String sellerId) async {
    try {
      final products = await _sellerService.getSellerProducts(sellerId);
      state = state.copyWith(products: products);
      AppLogger.info('Seller products loaded: ${products.length}');
    } catch (e) {
      AppLogger.error('Failed to load products', error: e);
    }
  }

  /// Load seller orders
  Future<void> loadOrders(String sellerId) async {
    try {
      final orders = await _sellerService.getSellerOrders(sellerId);
      state = state.copyWith(
        orders: orders,
        totalOrders: orders.length,
      );
      AppLogger.info('Seller orders loaded: ${orders.length}');
    } catch (e) {
      AppLogger.error('Failed to load orders', error: e);
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _orderService.updateOrderStatus(orderId, status);
      // Update local orders
      final updatedOrders = state.orders.map((order) {
        if (order['id'] == orderId) {
          return {...order, 'status': status};
        }
        return order;
      }).toList();
      state = state.copyWith(orders: updatedOrders, isLoading: false);
      AppLogger.info('Order status updated: $orderId -> $status');
    } catch (e) {
      AppLogger.error('Failed to update order status', error: e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update order: $e',
      );
    }
  }

  /// Add new product
  Future<void> addProduct(Map<String, dynamic> productData) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _sellerService.addProduct(
        sellerId: productData['sellerId'] ?? '',
        storeId: productData['storeId'] ?? '',
        productName: productData['productName'] ?? '',
        productDescription: productData['productDescription'] ?? '',
        category: productData['category'] ?? '',
        price: (productData['price'] ?? 0).toDouble(),
        stockQuantity: productData['stockQuantity'] ?? 0,
        productImage: productData['productImage'] ?? '',
        discount: (productData['discount'] ?? 0).toDouble(),
        tags: productData['tags'] is List ? List<String>.from(productData['tags']) : [],
      );
      final productId = result['productId'] as String?;
      final newProduct = {...productData, 'id': productId};
      state = state.copyWith(
        products: [...state.products, newProduct],
        isLoading: false,
      );
      AppLogger.info('Product added: $productId');
    } catch (e) {
      AppLogger.error('Failed to add product', error: e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add product: $e',
      );
    }
  }

  /// Update product
  Future<void> updateProduct(String productId, Map<String, dynamic> updates) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _sellerService.updateProduct(
        productId: productId,
        productName: updates['productName'] ?? '',
        productDescription: updates['productDescription'] ?? '',
        category: updates['category'] ?? '',
        price: (updates['price'] ?? 0).toDouble(),
        stockQuantity: updates['stockQuantity'] ?? 0,
        productImage: updates['productImage'] ?? '',
        discount: (updates['discount'] ?? 0).toDouble(),
        tags: updates['tags'] is List ? List<String>.from(updates['tags']) : [],
      );
      final updatedProducts = state.products.map((product) {
        if (product['id'] == productId) {
          return {...product, ...updates};
        }
        return product;
      }).toList();
      state = state.copyWith(products: updatedProducts, isLoading: false);
      AppLogger.info('Product updated: $productId');
    } catch (e) {
      AppLogger.error('Failed to update product', error: e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update product: $e',
      );
    }
  }

  /// Delete product
  Future<void> deleteProduct(String productId, String storeId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _sellerService.deleteProduct(
        productId: productId,
        storeId: storeId,
      );
      final filteredProducts =
          state.products.where((p) => p['id'] != productId).toList();
      state = state.copyWith(products: filteredProducts, isLoading: false);
      AppLogger.info('Product deleted: $productId');
    } catch (e) {
      AppLogger.error('Failed to delete product', error: e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete product: $e',
      );
    }
  }
}

/// Seller provider
final sellerProvider =
    StateNotifierProvider<SellerNotifier, SellerState>(
  (ref) => SellerNotifier(),
);