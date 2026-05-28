import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madpractical/providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';

/// Simplified order details screen for the new order flow.
/// Statuses: pending → accepted/rejected/cancelled → completed
class OrderDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  String _formatPrice(dynamic price) {
    if (price is double || price is int) return price.toStringAsFixed(0);
    if (price is String) {
      if (price.contains('UGX')) return price.replaceAll('UGX ', '').trim();
      final numericString = price.replaceAll(RegExp(r'[^0-9]'), '');
      return (double.tryParse(numericString) ?? 0).toStringAsFixed(0);
    }
    return '0';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return AppColors.primary;
      case 'rejected':
        return AppColors.error;
      case 'cancelled':
        return Colors.grey;
      case 'completed':
        return AppColors.success;
      default:
        return AppColors.grey;
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':    return '⏳';
      case 'accepted':   return '✅';
      case 'rejected':   return '❌';
      case 'cancelled':  return '🚫';
      case 'completed':  return '🎉';
      default:           return '❓';
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final orderId = (widget.order['orderId'] ?? widget.order['id'] ?? '').toString();
    // Derive status from provider state so markComplete triggers rebuild
    final providerOrder = orderState.orders.firstWhere(
      (o) => (o['orderId'] ?? o['id']) == orderId,
      orElse: () => widget.order,
    );
    final order = providerOrder;
    final status = (order['status'] ?? 'pending').toString();
    final products = (order['products'] as List?) ?? (order['items'] as List?) ?? [];
    final total = order['totalAmount'] ?? order['total'] ?? 0;
    final sellerConfirmed = order['sellerConfirmed'] == true;
    final customerConfirmed = order['customerConfirmed'] == true;
    final rejectionReason = order['rejectionReason'] as String?;
    final sellerName = order['sellerName'] as String? ?? 'Seller';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Order Status Card ──────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '#${orderId.length > 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase()}',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_getStatusIcon(status)} ${status.toUpperCase()}',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: AppColors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Ordered on ${order['date'] ?? ''}',
                          style: const TextStyle(color: AppColors.white, fontSize: 14),
                        ),
                      ],
                    ),
                    if (status == 'completed') ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.white, size: 16),
                          const SizedBox(width: 8),
                          const Text(
                            'Completed',
                            style: TextStyle(color: AppColors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Rejection Reason (if rejected) ─────────────────────
              if (status == 'rejected' && rejectionReason != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order Rejected',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              rejectionReason,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Dual Confirmation Status (for accepted orders) ─────
              if (status == 'accepted' || status == 'completed') ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.getSurface(context),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Completion Status',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildConfirmationBadge(
                            label: 'Seller confirmed',
                            confirmed: sellerConfirmed,
                          ),
                          const SizedBox(width: 8),
                          _buildConfirmationBadge(
                            label: 'You confirmed',
                            confirmed: customerConfirmed,
                          ),
                        ],
                      ),
                      if (status == 'accepted' && !customerConfirmed) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _markComplete,
                            icon: const Icon(Icons.check_circle_outline, size: 18),
                            label: const Text('Mark as Complete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (status == 'completed') ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, color: AppColors.success, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'This order is complete',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _enableFollowUp,
                            icon: const Icon(Icons.replay, size: 18),
                            label: const Text('Follow-up'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Products Section ───────────────────────────────────
              const Text(
                'Items',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
              ...products.map((product) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: product['image'] != null && product['image'].toString().isNotEmpty
                            ? Image.network(
                                product['image'],
                                width: 60, height: 60, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _placeholderImage(),
                              )
                            : _placeholderImage(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'] ?? 'Product',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Quantity: ${product['quantity']}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'UGX ${_formatPrice(product['price'])}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              // ── Price Summary ──────────────────────────────────────
              const Text(
                'Price Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildPriceRow(
                      'Total',
                      'UGX ${_formatPrice(total)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Order Chat Section ─────────────────────────────────
              if (status != 'rejected' && status != 'cancelled')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(
                      '/chat/order_$orderId',
                      extra: {
                        'name': sellerName,
                        'isOrderChat': true,
                      },
                    ),
                    icon: const Icon(Icons.chat_bubble_outline, size: 20),
                    label: const Text('Go to Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // ── Cancel Button (only when pending) ──────────────────
              if (status == 'pending')
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _cancelOrder,
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Cancel Order'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.error, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.shopping_bag, color: AppColors.primary, size: 30),
    );
  }

  Widget _buildConfirmationBadge({required String label, required bool confirmed}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: confirmed
              ? AppColors.success.withValues(alpha: 0.1)
              : AppColors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              confirmed ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 14,
              color: confirmed ? AppColors.success : AppColors.grey,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: confirmed ? AppColors.success : AppColors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? AppColors.text : AppColors.secondaryText,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppColors.primary : AppColors.text,
          ),
        ),
      ],
    );
  }

  void _cancelOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text(
          'Are you sure you want to cancel this order?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              ref.read(orderProvider.notifier).cancelOrder(
                widget.order['orderId'] ?? widget.order['id'],
              );
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Order cancelled'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _markComplete() {
    final orderId = widget.order['orderId'] ?? widget.order['id'];
    ref.read(orderProvider.notifier).markCustomerComplete(orderId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Marked as complete! Waiting for seller confirmation.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _enableFollowUp() {
    final orderId = widget.order['orderId'] ?? widget.order['id'];
    ref.read(orderProvider.notifier).enableFollowUp(orderId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Follow-up enabled! You can now chat with the seller.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}