import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/widgets/notification_icon.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  
  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Processing':
        return AppColors.primary;
      case 'Shipped':
        return Colors.blue;
      case 'Delivered':
        return AppColors.success;
      case 'Cancelled':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.schedule;
      case 'Processing':
        return Icons.sync;
      case 'Shipped':
        return Icons.local_shipping;
      case 'Delivered':
        return Icons.check_circle;
      case 'Cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantity: ${product['quantity']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            product['price'],
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
    final order = widget.order;
    final isUrgent = order['priority'] == 'high';
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.text,
              size: 16,
            ),
          ),
        ),
        title: Text(
          'Order ${order['id']}',
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: const [NotificationIcon()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
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
                      Row(
                        children: [
                          Text(
                            order['id'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          if (isUrgent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'URGENT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order['status']).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getStatusIcon(order['status']),
                              size: 16,
                              color: _getStatusColor(order['status']),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              order['status'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(order['status']),
                              ),
                            ),
                          ],
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
                            Icon(Icons.calendar_today, color: AppColors.primary, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              'Order Date',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order['date'],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                            Text(
                              order['time'],
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 60,
                        color: AppColors.lightGrey,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              'Total Items',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${order['items']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 60,
                        color: AppColors.lightGrey,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Icon(Icons.payments_outlined, color: AppColors.primary, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              'Total',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order['total'],
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
            
            // Customer Information
            _buildInfoCard(
              'Customer Information',
              [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(order['customerAvatar']),
                      backgroundColor: AppColors.lightGrey,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order['customer'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: AppColors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  order['address'],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Order Items
            _buildInfoCard(
              'Order Items',
              [
                ...List.generate(
                  order['products'].length,
                  (index) => _buildProductItem(order['products'][index]),
                ),
              ],
            ),
            
            // Additional Information
            if (order['status'] == 'Shipped' && order['trackingNumber'] != null)
              _buildInfoCard(
                'Shipping Information',
                [
                  _buildInfoRow(
                    Icons.local_shipping,
                    'Tracking Number',
                    order['trackingNumber'],
                  ),
                ],
              ),
            
            if (order['status'] == 'Delivered' && order['deliveredDate'] != null)
              _buildInfoCard(
                'Delivery Information',
                [
                  _buildInfoRow(
                    Icons.check_circle,
                    'Delivered On',
                    order['deliveredDate'],
                  ),
                ],
              ),
            
            if (order['status'] == 'Cancelled' && order['cancelReason'] != null)
              _buildInfoCard(
                'Cancellation Information',
                [
                  _buildInfoRow(
                    Icons.info_outline,
                    'Reason',
                    order['cancelReason'],
                  ),
                ],
              ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            if (order['status'] == 'Pending') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Accept order logic
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Accept Order'),
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
                      onPressed: () {
                        // Decline order logic
                      },
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
            
            if (order['status'] == 'Processing') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Mark as shipped logic
                  },
                  icon: const Icon(Icons.local_shipping_outlined, size: 18),
                  label: const Text('Mark as Shipped'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Contact Customer Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Contact customer logic
                },
                icon: const Icon(Icons.message_outlined, size: 18),
                label: const Text('Contact Customer'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
