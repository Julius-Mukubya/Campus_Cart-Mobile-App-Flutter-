import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madpractical/providers/order_provider.dart';
import 'package:madpractical/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';

/// Seller order details for the simplified order flow.
/// Statuses: pending → accepted/rejected → completed
class OrderDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {

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

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = timestamp.toDate();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return timestamp.toString();
    }
  }

  String _formatPrice(dynamic price) {
    if (price is double || price is int) return price.toStringAsFixed(0);
    if (price is String) {
      if (price.contains('UGX')) return price.replaceAll('UGX ', '').trim();
      final numericString = price.replaceAll(RegExp(r'[^0-9]'), '');
      return (double.tryParse(numericString) ?? 0).toStringAsFixed(0);
    }
    return '0';
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.getBackground(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? 'Product',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantity: ${product['quantity']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'UGX ${_formatPrice(product['price'])}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final orderId = (widget.order['orderId'] ?? widget.order['id'] ?? '').toString();
    // Derive status from provider state so accept/reject triggers rebuild
    final providerOrder = orderState.orders.firstWhere(
      (o) => (o['orderId'] ?? o['id']) == orderId,
      orElse: () => widget.order,
    );
    final order = providerOrder;
    final status = (order['status'] ?? 'pending').toString();
    final products = (order['products'] as List?) ?? (order['items'] as List?) ?? [];
    final customerName = (order['customerName'] ?? order['customer'] ?? 'Customer').toString();
    final customerPhone = order['customerPhone'] as String? ?? '';
    final total = order['totalAmount'] ?? order['total'] ?? 0;
    final showContact = order['showContactToSeller'] == true;
    final sellerConfirmed = order['sellerConfirmed'] == true;
    final customerConfirmed = order['customerConfirmed'] == true;
    final rejectionReason = order['rejectionReason'] as String?;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.getBackground(context),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.getSurface(context),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios, color: AppColors.text, size: 16),
          ),
        ),
        title: Text(
          'Order #${orderId.length > 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase()}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status Card ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.getSurface(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '#${orderId.length > 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Icon(Icons.calendar_today, color: AppColors.primary, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              'Order Date',
                              style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(order['createdAt']),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 60, color: AppColors.lightGrey),
                      Expanded(
                        child: Column(
                          children: [
                            const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              'Total Items',
                              style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${products.length}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 60, color: AppColors.lightGrey),
                      Expanded(
                        child: Column(
                          children: [
                            const Icon(Icons.payments_outlined, color: AppColors.primary, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              'Total',
                              style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'UGX ${_formatPrice(total)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Rejection Reason (if rejected) ─────────────────────
            if (status == 'rejected' && rejectionReason != null)
              _buildInfoCard('Rejection Reason', [
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rejectionReason,
                        style: const TextStyle(fontSize: 14, color: AppColors.text),
                      ),
                    ),
                  ],
                ),
              ]),

            // ── Customer Information ───────────────────────────────
            _buildInfoCard(
              'Customer Information',
              [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customerName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          if (showContact && customerPhone.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 14, color: AppColors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  customerPhone,
                                  style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
                                ),
                              ],
                            ),
                          ],
                          if (!showContact)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Contact hidden by customer',
                                  style: TextStyle(fontSize: 11, color: Colors.orange),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ── Order Items ────────────────────────────────────────
            _buildInfoCard(
              'Order Items',
              products.map((p) => _buildProductItem(p)).toList(),
            ),

            const SizedBox(height: 16),

            // ── Dual Confirmation Status ───────────────────────────
            if (status == 'accepted' || status == 'completed')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.getSurface(context),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Completion Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
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
                          label: 'Customer confirmed',
                          confirmed: customerConfirmed,
                        ),
                      ],
                    ),
                    if (status == 'accepted' && !sellerConfirmed) ...[
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
                    if (status == 'completed')
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
                              'Order completed by both parties',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // ── Go to Chat Button ──────────────────────────────────
            if (status != 'rejected' && status != 'cancelled')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push(
                    '/chat/order_$orderId',
                    extra: {
                      'name': customerName,
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

            // ── Action Buttons (only when pending) ─────────────────
            if (status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showAcceptDialog,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showRejectDialog,
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Decline'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
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

  void _showAcceptDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Accept Order'),
        content: const Text('Accept this order? The customer will be notified.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final uid = ref.read(userProvider).userId ?? '';
              await ref.read(orderProvider.notifier).approveOrder(
                orderId: widget.order['orderId'] ?? widget.order['id'],
                sellerId: uid,
              );
              if (mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order accepted!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog() {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Decline Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please provide a reason for declining:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Reason is required...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }
              final uid = ref.read(userProvider).userId ?? '';
              await ref.read(orderProvider.notifier).rejectOrder(
                orderId: widget.order['orderId'] ?? widget.order['id'],
                sellerId: uid,
                rejectionReason: reasonController.text.trim(),
              );
              if (mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order declined')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }

  void _markComplete() {
    final orderId = widget.order['orderId'] ?? widget.order['id'];
    ref.read(orderProvider.notifier).markSellerComplete(orderId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Marked as complete! Waiting for customer confirmation.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}