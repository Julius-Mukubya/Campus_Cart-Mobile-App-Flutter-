import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madpractical/services/order_service.dart';
import 'package:madpractical/services/notification_service.dart';
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
  final OrderService _orderService = OrderService();
  final NotificationService _notificationService;

  OrderNotifier(this._notificationService) : super(const OrderState());

  /// Add a new order locally and send notification to seller
  Future<void> addOrder(Map<String, dynamic> order) async {
    final updatedOrders = [order, ...state.orders];
    state = state.copyWith(orders: updatedOrders);
    await _notifySeller(order);
  }

  /// Send a notification to the seller about a new order
  Future<void> _notifySeller(Map<String, dynamic> order) async {
    try {
      final products = order['products'] as List<Map<String, dynamic>>? ?? [];
      final totalItems =
          products.fold<int>(0, (sum, product) => sum + (product['quantity'] as int? ?? 0));

      await _notificationService.sendNotification(
        userId: order['sellerId'] ?? '',
        title: 'New Order Received',
        message: 'Customer ${order['customerName']} placed an order for $totalItems item(s)',
        type: 'new_order',
        data: {
          'orderId': order['id'],
          'customerName': order['customerName'],
          'totalItems': totalItems.toString(),
        },
      );
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

  /// Cancel an order (customer — only when pending)
  void cancelOrder(String orderId) {
    final index = state.orders.indexWhere((order) => (order['orderId'] ?? order['id']) == orderId);
    if (index != -1) {
      final updatedOrders = List<Map<String, dynamic>>.from(state.orders);
      updatedOrders[index]['status'] = 'cancelled';
      state = state.copyWith(orders: updatedOrders);
    }
    // Firestore call
    _orderService.cancelOrder(orderId);
  }

  void updateOrderStatus(String orderId, String newStatus) {
    final index = state.orders.indexWhere((order) => (order['orderId'] ?? order['id']) == orderId);
    if (index != -1) {
      final updatedOrders = List<Map<String, dynamic>>.from(state.orders);
      updatedOrders[index]['status'] = newStatus;
      state = state.copyWith(orders: updatedOrders);
    }
  }

  /// Approve order - seller accepts the order
  Future<void> approveOrder({
    required String orderId,
    required String sellerId,
    String approvalMessage = 'Your order has been approved. I will contact you shortly!',
  }) async {
    try {
      await _orderService.acceptOrder(orderId);

      final updatedApprovals = Map<String, Map<String, dynamic>>.from(state.orderApprovals);
      updatedApprovals[orderId] = {
        'orderId': orderId,
        'sellerId': sellerId,
        'status': 'accepted',
        'message': approvalMessage,
        'approvedAt': DateTime.now().toIso8601String(),
      };

      final orderIndex = state.orders.indexWhere((order) => (order['orderId'] ?? order['id']) == orderId);
      if (orderIndex != -1) {
        final updatedOrders = List<Map<String, dynamic>>.from(state.orders);
        updatedOrders[orderIndex]['status'] = 'accepted';
        updatedOrders[orderIndex]['approvalMessage'] = approvalMessage;

        state = state.copyWith(orders: updatedOrders, orderApprovals: updatedApprovals);
      }

      await _notifyCustomerOfApproval(orderId, approvalMessage);
      AppLogger.info('Order approved: $orderId');
    } catch (e) {
      AppLogger.error('Error approving order', error: e);
    }
  }

  /// Reject order - seller rejects with required reason
  Future<void> rejectOrder({
    required String orderId,
    required String sellerId,
    required String rejectionReason,
  }) async {
    try {
      await _orderService.rejectOrder(orderId, rejectionReason);

      final updatedApprovals = Map<String, Map<String, dynamic>>.from(state.orderApprovals);
      updatedApprovals[orderId] = {
        'orderId': orderId,
        'sellerId': sellerId,
        'status': 'rejected',
        'reason': rejectionReason,
        'rejectedAt': DateTime.now().toIso8601String(),
      };

      final orderIndex = state.orders.indexWhere((order) => (order['orderId'] ?? order['id']) == orderId);
      if (orderIndex != -1) {
        final updatedOrders = List<Map<String, dynamic>>.from(state.orders);
        updatedOrders[orderIndex]['status'] = 'rejected';
        updatedOrders[orderIndex]['rejectionReason'] = rejectionReason;

        state = state.copyWith(orders: updatedOrders, orderApprovals: updatedApprovals);
      }

      await _notifyCustomerOfRejection(orderId, rejectionReason);
      AppLogger.info('Order rejected: $orderId');
    } catch (e) {
      AppLogger.error('Error rejecting order', error: e);
    }
  }

  /// Mark customer's completion confirmation
  Future<void> markCustomerComplete(String orderId) async {
    try {
      await _orderService.markCustomerComplete(orderId);

      final orderIndex = state.orders.indexWhere((order) => (order['orderId'] ?? order['id']) == orderId);
      if (orderIndex != -1) {
        final updatedOrders = List<Map<String, dynamic>>.from(state.orders);
        updatedOrders[orderIndex]['customerConfirmed'] = true;
        // Check if both confirmed
        if (updatedOrders[orderIndex]['sellerConfirmed'] == true) {
          updatedOrders[orderIndex]['status'] = 'completed';
        }
        state = state.copyWith(orders: updatedOrders);
      }

      AppLogger.info('Customer marked complete: $orderId');
    } catch (e) {
      AppLogger.error('Error marking customer complete', error: e);
    }
  }

  /// Mark seller's completion confirmation
  Future<void> markSellerComplete(String orderId) async {
    try {
      await _orderService.markSellerComplete(orderId);

      final orderIndex = state.orders.indexWhere((order) => (order['orderId'] ?? order['id']) == orderId);
      if (orderIndex != -1) {
        final updatedOrders = List<Map<String, dynamic>>.from(state.orders);
        updatedOrders[orderIndex]['sellerConfirmed'] = true;
        // Check if both confirmed
        if (updatedOrders[orderIndex]['customerConfirmed'] == true) {
          updatedOrders[orderIndex]['status'] = 'completed';
        }
        state = state.copyWith(orders: updatedOrders);
      }

      AppLogger.info('Seller marked complete: $orderId');
    } catch (e) {
      AppLogger.error('Error marking seller complete', error: e);
    }
  }

  /// Enable follow-up on a completed order (re-enables chat)
  Future<void> enableFollowUp(String orderId) async {
    try {
      await _orderService.enableFollowUp(orderId);
      final orderIndex = state.orders.indexWhere((order) => (order['orderId'] ?? order['id']) == orderId);
      if (orderIndex != -1) {
        final updatedOrders = List<Map<String, dynamic>>.from(state.orders);
        updatedOrders[orderIndex]['followUp'] = true;
        state = state.copyWith(orders: updatedOrders);
      }
      AppLogger.info('Follow-up enabled for order: $orderId');
    } catch (e) {
      AppLogger.error('Error enabling follow-up', error: e);
    }
  }

  /// Get approval status of an order
  String getApprovalStatus(String orderId) {
    return state.orderApprovals[orderId]?['status'] ?? 'pending';
  }

  /// Check if order is accepted
  bool isOrderAccepted(String orderId) {
    return getApprovalStatus(orderId) == 'accepted';
  }

  /// Notify customer that their order has been accepted
  Future<void> _notifyCustomerOfApproval(String orderId, String approvalMessage) async {
    try {
      final order = getOrderById(orderId);
      await _notificationService.sendNotification(
        userId: order?['customerId'] ?? '',
        title: 'Order Accepted!',
        message: approvalMessage,
        type: 'order_accepted',
        data: {'orderId': orderId},
      );
      AppLogger.info('Customer notified of acceptance for order: $orderId');
    } catch (e) {
      AppLogger.error('Error notifying customer of acceptance', error: e);
    }
  }

  /// Notify customer that their order has been rejected
  Future<void> _notifyCustomerOfRejection(String orderId, String rejectionReason) async {
    try {
      final order = getOrderById(orderId);
      await _notificationService.sendNotification(
        userId: order?['customerId'] ?? '',
        title: 'Order Rejected',
        message: 'Your order was rejected. Reason: $rejectionReason',
        type: 'order_rejected',
        data: {'orderId': orderId},
      );
      AppLogger.info('Customer notified of rejection for order: $orderId');
    } catch (e) {
      AppLogger.error('Error notifying customer of rejection', error: e);
    }
  }
}

/// Order provider - provides access to order state
final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier(NotificationService());
});