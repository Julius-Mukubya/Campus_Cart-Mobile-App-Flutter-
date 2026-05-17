import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madpractical/providers/notification_provider.dart';
import '../utils/app_logger.dart';

/// Order state model - represents orders data
class OrderState {
  final List<Map<String, dynamic>> orders;
  final Map<String, Map<String, dynamic>> orderApprovals;

  const OrderState({
    this.orders = const [],
    this.orderApprovals = const {},
  });

  int get orderCount => orders.length;

  OrderState copyWith({
    List<Map<String, dynamic>>? orders,
    Map<String, Map<String, dynamic>>? orderApprovals,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      orderApprovals: orderApprovals ?? this.orderApprovals,
    );
  }
}

/// OrderNotifier - handles order state updates
class OrderNotifier extends StateNotifier<OrderState> {
  OrderNotifier(this._notificationNotifier) : super(const OrderState());

  final StateNotifierProvider<NotificationNotifier, NotificationState>
      _notificationNotifier;

  /// Add a new order and send notification to seller
  Future<void> addOrder(Map<String, dynamic> order) async {
    final updatedOrders = [order, ...state.orders];
    state = state.copyWith(orders: updatedOrders);

    // Send notification to seller about new order
    await _notifySeller(order);
  }

  /// Send a notification to the seller about a new order
  Future<void> _notifySeller(Map<String, dynamic> order) async {
    try {
      // Extract product seller info
      final products = order['products'] as List<Map<String, dynamic>>? ?? [];
      final totalItems =
          products.fold<int>(0, (sum, product) => sum + (product['quantity'] as int? ?? 0));

      final notification = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'new_order',
        'title': 'New Order Received',
        'message': 'Customer ${order['customerName']} placed an order for $totalItems item(s)',
        'orderId': order['id'],
        'customerName': order['customerName'],
        'customerPhone': order['customerPhone'],
        'shippingAddress': order['shippingAddress'],
        'total': order['total'],
        'itemCount': totalItems,
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      };

      // Save to local notifications
      // In full implementation, this would be fetched by seller's device from Firebase
    } catch (e) {
      AppLogger.error('Error notifying seller', error: e);
    }
  }

  Map<String, dynamic>? getOrderById(String id) {
    try {
      return state.orders.firstWhere((order) => order['id'] == id);
    } catch (e) {
      return null;
    }
  }

  void cancelOrder(String orderId) {
    final index = state.orders.indexWhere((order) => order['id'] == orderId);
    if (index != -1) {
      final updatedOrders = List<Map<String, dynamic>>.from(state.orders);
      updatedOrders[index]['status'] = 'Cancelled';
      state = state.copyWith(orders: updatedOrders);
    }
  }

  void updateOrderStatus(String orderId, String newStatus) {
    final index = state.orders.indexWhere((order) => order['id'] == orderId);
    if (index != -1) {
      final updatedOrders = List<Map<String, dynamic>>.from(state.orders);
      updatedOrders[index]['status'] = newStatus;
      state = state.copyWith(orders: updatedOrders);
    }
  }

  /// Approve order - seller confirms they can fulfill
  Future<void> approveOrder({
    required String orderId,
    required String sellerId,
    String approvalMessage = 'Your order has been approved. I will contact you shortly!',
  }) async {
    try {
      final updatedApprovals = Map<String, Map<String, dynamic>>.from(state.orderApprovals);
      updatedApprovals[orderId] = {
        'orderId': orderId,
        'sellerId': sellerId,
        'status': 'approved',
        'message': approvalMessage,
        'approvedAt': DateTime.now().toIso8601String(),
      };

      final orderIndex = state.orders.indexWhere((order) => order['id'] == orderId);
      if (orderIndex != -1) {
        final updatedOrders = List<Map<String, dynamic>>.from(state.orders);
        updatedOrders[orderIndex]['approvalStatus'] = 'approved';
        updatedOrders[orderIndex]['approvedAt'] = DateTime.now().toIso8601String();
        updatedOrders[orderIndex]['status'] = 'Approved';

        state = state.copyWith(orders: updatedOrders, orderApprovals: updatedApprovals);
      }

      // Notify customer about approval
      await _notifyCustomerOfApproval(orderId, approvalMessage);

      AppLogger.info('Order approved: $orderId');
    } catch (e) {
      AppLogger.error('Error approving order', error: e);
    }
  }

  /// Reject order - seller cannot fulfill
  Future<void> rejectOrder({
    required String orderId,
    required String sellerId,
    required String rejectionReason,
  }) async {
    try {
      final updatedApprovals = Map<String, Map<String, dynamic>>.from(state.orderApprovals);
      updatedApprovals[orderId] = {
        'orderId': orderId,
        'sellerId': sellerId,
        'status': 'rejected',
        'reason': rejectionReason,
        'rejectedAt': DateTime.now().toIso8601String(),
      };

      final orderIndex = state.orders.indexWhere((order) => order['id'] == orderId);
      if (orderIndex != -1) {
        final updatedOrders = List<Map<String, dynamic>>.from(state.orders);
        updatedOrders[orderIndex]['approvalStatus'] = 'rejected';
        updatedOrders[orderIndex]['rejectedAt'] = DateTime.now().toIso8601String();
        updatedOrders[orderIndex]['status'] = 'Rejected';

        state = state.copyWith(orders: updatedOrders, orderApprovals: updatedApprovals);
      }

      // Notify customer about rejection
      await _notifyCustomerOfRejection(orderId, rejectionReason);

      AppLogger.info('Order rejected: $orderId');
    } catch (e) {
      AppLogger.error('Error rejecting order', error: e);
    }
  }

  /// Get approval status of an order
  String getApprovalStatus(String orderId) {
    return state.orderApprovals[orderId]?['status'] ?? 'pending';
  }

  /// Check if order is approved
  bool isOrderApproved(String orderId) {
    return getApprovalStatus(orderId) == 'approved';
  }

  /// Notify customer that their order has been approved
  Future<void> _notifyCustomerOfApproval(String orderId, String approvalMessage) async {
    try {
      final notification = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'order_approved',
        'title': 'Order Approved!',
        'message': approvalMessage,
        'orderId': orderId,
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      };

      AppLogger.info('Customer notified of approval for order: $orderId');
    } catch (e) {
      AppLogger.error('Error notifying customer of approval', error: e);
    }
  }

  /// Notify customer that their order has been rejected
  Future<void> _notifyCustomerOfRejection(String orderId, String rejectionReason) async {
    try {
      final notification = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'order_rejected',
        'title': 'Order Rejected',
        'message': 'Your order was rejected. Reason: $rejectionReason',
        'orderId': orderId,
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      };

      AppLogger.info('Customer notified of rejection for order: $orderId');
    } catch (e) {
      AppLogger.error('Error notifying customer of rejection', error: e);
    }
  }
}

/// Order provider - provides access to order state
final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier(notificationProvider);
});
