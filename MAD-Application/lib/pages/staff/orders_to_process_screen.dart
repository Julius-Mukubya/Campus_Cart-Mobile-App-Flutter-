import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/widgets/notification_icon.dart';
import 'package:madpractical/services/user_manager.dart';

class OrdersToProcessScreen extends StatefulWidget {
  const OrdersToProcessScreen({super.key});

  @override
  State<OrdersToProcessScreen> createState() => _OrdersToProcessScreenState();
}

class _OrdersToProcessScreenState extends State<OrdersToProcessScreen> {
  final userManager = UserManager();
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending Accept', 'Accepted', 'Picked Up', 'Delivered'];
  
  final List<Map<String, dynamic>> _orders = [
    {
      'id': '#ORD001',
      'customer': 'John Doe',
      'seller': 'Tech Store',
      'items': 2,
      'total': 'UGX 125,000',
      'status': 'Assigned',
      'date': '2024-02-13',
      'priority': 'High',
      'address': '123 Main St, Kampala',
      'sellerAddress': 'Shop 45, Campus Mall',
      'sellerPhone': '+256 700 111 222',
      'customerPhone': '+256 700 123 456',
      'assignedTo': 'Tom Delivery',
      'delivererAccepted': false,
      'pickupConfirmedByDeliverer': false,
      'pickupConfirmedBySeller': false,
      'deliveryConfirmedByDeliverer': false,
      'deliveryConfirmedByCustomer': false,
    },
    {
      'id': '#ORD002',
      'customer': 'Jane Smith',
      'seller': 'Fashion Hub',
      'items': 1,
      'total': 'UGX 85,000',
      'status': 'Assigned',
      'date': '2024-02-12',
      'priority': 'Medium',
      'address': '456 Oak Ave, Entebbe',
      'sellerAddress': 'Shop 12, Student Center',
      'sellerPhone': '+256 700 222 333',
      'customerPhone': '+256 700 234 567',
      'assignedTo': 'Tom Delivery',
      'delivererAccepted': false,
      'pickupConfirmedByDeliverer': false,
      'pickupConfirmedBySeller': false,
      'deliveryConfirmedByDeliverer': false,
      'deliveryConfirmedByCustomer': false,
    },
    {
      'id': '#ORD003',
      'customer': 'Mike Johnson',
      'seller': 'Book Corner',
      'items': 3,
      'total': 'UGX 200,000',
      'status': 'Assigned',
      'date': '2024-02-11',
      'priority': 'Low',
      'address': '789 Pine Rd, Jinja',
      'sellerAddress': 'Shop 8, Library Building',
      'sellerPhone': '+256 700 333 444',
      'customerPhone': '+256 700 789 012',
      'assignedTo': 'Tom Delivery',
      'delivererAccepted': true,
      'pickupConfirmedByDeliverer': false,
      'pickupConfirmedBySeller': false,
      'deliveryConfirmedByDeliverer': false,
      'deliveryConfirmedByCustomer': false,
    },
  ];

  List<Map<String, dynamic>> get filteredOrders {
    final staffType = userManager.staffType;
    final isDelivery = staffType == 'delivery';
    final userName = userManager.name;
    
    // Filter orders based on staff type
    List<Map<String, dynamic>> orders = _orders;
    
    // Delivery staff only see orders assigned to them
    if (isDelivery) {
      orders = _orders.where((order) => 
        order['status'] == 'Assigned' && 
        order['assignedTo'] == userName
      ).toList();
    }
    
    // Apply status filter
    if (_selectedFilter == 'All') return orders;
    
    if (_selectedFilter == 'Pending Accept') {
      return orders.where((order) => 
        order['delivererAccepted'] == false
      ).toList();
    } else if (_selectedFilter == 'Accepted') {
      return orders.where((order) => 
        order['delivererAccepted'] == true &&
        order['pickupConfirmedByDeliverer'] == false
      ).toList();
    } else if (_selectedFilter == 'Picked Up') {
      return orders.where((order) => 
        order['pickupConfirmedByDeliverer'] == true &&
        order['pickupConfirmedBySeller'] == true &&
        order['deliveryConfirmedByDeliverer'] == false
      ).toList();
    } else if (_selectedFilter == 'Delivered') {
      return orders.where((order) => 
        order['deliveryConfirmedByDeliverer'] == true &&
        order['deliveryConfirmedByCustomer'] == true
      ).toList();
    }
    
    return orders.where((order) => order['status'] == _selectedFilter).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Accepted':
        return AppColors.primary;
      case 'Assigned':
        return AppColors.success;
      default:
        return AppColors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return AppColors.error;
      case 'Medium':
        return AppColors.accent;
      case 'Low':
        return AppColors.success;
      default:
        return AppColors.grey;
    }
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order['id'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(order['priority']).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order['priority'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getPriorityColor(order['priority']),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order['status']).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order['status'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(order['status']),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Customer and Seller Info
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: AppColors.grey),
                const SizedBox(width: 8),
                Text(
                  order['customer'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                const Icon(Icons.store, size: 16, color: AppColors.grey),
                const SizedBox(width: 8),
                Text(
                  order['seller'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Order Details
            Row(
              children: [
                const Icon(Icons.shopping_bag, size: 16, color: AppColors.grey),
                const SizedBox(width: 8),
                Text(
                  '${order['items']} items',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(width: 24),
                const Icon(Icons.calendar_today, size: 16, color: AppColors.grey),
                const SizedBox(width: 8),
                Text(
                  order['date'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Total
            Text(
              order['total'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Confirmation Status for Delivery Staff
            if (userManager.staffType == 'delivery' && order['delivererAccepted'] == true) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          order['pickupConfirmedByDeliverer'] && order['pickupConfirmedBySeller']
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 16,
                          color: order['pickupConfirmedByDeliverer'] && order['pickupConfirmedBySeller']
                              ? AppColors.success
                              : AppColors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Pickup confirmed',
                          style: TextStyle(
                            fontSize: 11,
                            color: order['pickupConfirmedByDeliverer'] && order['pickupConfirmedBySeller']
                                ? AppColors.success
                                : AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          order['deliveryConfirmedByDeliverer'] && order['deliveryConfirmedByCustomer']
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 16,
                          color: order['deliveryConfirmedByDeliverer'] && order['deliveryConfirmedByCustomer']
                              ? AppColors.success
                              : AppColors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Delivery confirmed',
                          style: TextStyle(
                            fontSize: 11,
                            color: order['deliveryConfirmedByDeliverer'] && order['deliveryConfirmedByCustomer']
                                ? AppColors.success
                                : AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            // Action Buttons
            if (userManager.staffType == 'delivery') ...[
              // Delivery staff buttons
              if (order['delivererAccepted'] == false) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _acceptOrder(order),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Accept Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: order['pickupConfirmedByDeliverer']
                            ? null
                            : () => _confirmPickup(order),
                        icon: const Icon(Icons.shopping_bag, size: 16),
                        label: const Text('Confirm Pickup'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: order['pickupConfirmedByDeliverer']
                              ? AppColors.grey
                              : Colors.orange,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: (!order['pickupConfirmedByDeliverer'] || 
                                   !order['pickupConfirmedBySeller'] ||
                                   order['deliveryConfirmedByDeliverer'])
                            ? null
                            : () => _confirmDelivery(order),
                        icon: const Icon(Icons.local_shipping, size: 16),
                        label: const Text('Confirm Delivery'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (!order['pickupConfirmedByDeliverer'] || 
                                           !order['pickupConfirmedBySeller'] ||
                                           order['deliveryConfirmedByDeliverer'])
                              ? AppColors.grey
                              : AppColors.success,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ] else ...[
              // Coordinator buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (order['status'] == 'Accepted') ...[
                    ElevatedButton(
                      onPressed: () {
                        _assignDelivery(order);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Assign Delivery',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ] else if (order['status'] == 'Assigned') ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_shipping, size: 14, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text(
                            order['assignedTo'],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      _viewOrderDetails(order);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'View',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _assignDelivery(Map<String, dynamic> order) {
    // List of available delivery personnel
    final deliveryPersonnel = [
      'Tom Delivery',
      'Sarah Driver',
      'Mike Courier',
      'Jane Express',
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Assign Delivery Personnel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order: ${order['id']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Customer: ${order['customer']}'),
            Text('Seller: ${order['seller']}'),
            const SizedBox(height: 16),
            const Text(
              'Select delivery personnel:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...deliveryPersonnel.map((person) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person, color: AppColors.primary),
              title: Text(person),
              onTap: () {
                setState(() {
                  order['status'] = 'Assigned';
                  order['assignedTo'] = person;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Order ${order['id']} assigned to $person'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _viewOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
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
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order['id'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            order['customer'],
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order['status']).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          order['status'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(order['status']),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Order Details
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Order Date', order['date']),
                    const SizedBox(height: 16),
                    _buildDetailRow('Customer', order['customer']),
                    const SizedBox(height: 16),
                    _buildDetailRow('Seller', order['seller']),
                    const SizedBox(height: 16),
                    _buildDetailRow('Items', '${order['items']} items'),
                    const SizedBox(height: 16),
                    _buildDetailRow('Total Amount', order['total']),
                    const SizedBox(height: 16),
                    _buildDetailRow('Priority', order['priority']),
                    const SizedBox(height: 16),
                    _buildDetailRow('Pickup Address', order['sellerAddress']),
                    const SizedBox(height: 16),
                    _buildDetailRow('Delivery Address', order['address']),
                    if (order['assignedTo'] != null) ...[
                      const SizedBox(height: 16),
                      _buildDetailRow('Assigned To', order['assignedTo']),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      'Order Items',
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
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Order items details would be displayed here',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.secondaryText,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Close Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }

  void _acceptOrder(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Accept Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order: ${order['id']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Customer: ${order['customer']}'),
            Text('Seller: ${order['seller']}'),
            Text('Items: ${order['items']}'),
            Text('Total: ${order['total']}'),
            const SizedBox(height: 12),
            const Text(
              'Do you want to accept this delivery assignment?',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                order['delivererAccepted'] = true;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order ${order['id']} accepted'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _confirmPickup(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Pickup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Have you picked up the items from ${order['seller']}?',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.accent),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Seller must also confirm handover',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                order['pickupConfirmedByDeliverer'] = true;
                // Simulate seller confirmation after a delay
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    setState(() {
                      order['pickupConfirmedBySeller'] = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Seller confirmed handover. Item picked up!'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                });
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pickup confirmed. Waiting for seller confirmation...'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _confirmDelivery(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Delivery'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Have you delivered the items to ${order['customer']}?',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.accent),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Customer must also confirm receipt',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                order['deliveryConfirmedByDeliverer'] = true;
                // Simulate customer confirmation after a delay
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    setState(() {
                      order['deliveryConfirmedByCustomer'] = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Customer confirmed receipt. Delivery complete!'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                });
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delivery confirmed. Waiting for customer confirmation...'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final staffType = userManager.staffType;
    final isDelivery = staffType == 'delivery';
    final screenTitle = isDelivery ? 'My Assigned Orders' : 'Orders to Process';
    
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
          screenTitle,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: const [NotificationIcon()],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Chips
            Container(
              height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;
                    
                    return Container(
                      margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        backgroundColor: AppColors.white,
                        selectedColor: AppColors.primary.withValues(alpha: 0.1),
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.text,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.lightGrey,
                        ),
                      ),
                  );
                },
              ),
            ),
            
            // Orders List
            Expanded(
              child: filteredOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: AppColors.secondaryText,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No ${_selectedFilter.toLowerCase()} orders',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Accepted orders from sellers will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(filteredOrders[index]);
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}