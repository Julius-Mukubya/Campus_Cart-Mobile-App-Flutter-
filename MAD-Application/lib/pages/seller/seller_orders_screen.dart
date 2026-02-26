import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/widgets/notification_icon.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'All';
  
  final List<String> _statusFilters = ['All', 'Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];
  
  final List<Map<String, dynamic>> _orders = [
    {
      'id': '#ORD001',
      'customer': 'John Doe',
      'customerAvatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
      'items': 2,
      'total': 'UGX 125,000',
      'status': 'Pending',
      'date': '2024-02-13',
      'time': '10:30 AM',
      'address': '123 Main St, Kampala',
      'products': [
        {'name': 'Wireless Headphones', 'quantity': 1, 'price': 'UGX 85,000'},
        {'name': 'Phone Case', 'quantity': 1, 'price': 'UGX 40,000'},
      ],
      'priority': 'high',
    },
    {
      'id': '#ORD002',
      'customer': 'Jane Smith',
      'customerAvatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100&h=100&fit=crop&crop=face',
      'items': 1,
      'total': 'UGX 85,000',
      'status': 'Processing',
      'date': '2024-02-12',
      'time': '2:15 PM',
      'address': '456 Oak Ave, Entebbe',
      'products': [
        {'name': 'Smart Watch', 'quantity': 1, 'price': 'UGX 85,000'},
      ],
      'priority': 'medium',
    },
    {
      'id': '#ORD003',
      'customer': 'Mike Johnson',
      'customerAvatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      'items': 3,
      'total': 'UGX 200,000',
      'status': 'Shipped',
      'date': '2024-02-11',
      'time': '9:45 AM',
      'address': '789 Pine Rd, Jinja',
      'products': [
        {'name': 'Bluetooth Speaker', 'quantity': 2, 'price': 'UGX 84,000'},
        {'name': 'USB Cable', 'quantity': 1, 'price': 'UGX 32,000'},
      ],
      'priority': 'low',
      'trackingNumber': 'TRK123456789',
    },
    {
      'id': '#ORD004',
      'customer': 'Sarah Wilson',
      'customerAvatar': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face',
      'items': 1,
      'total': 'UGX 75,000',
      'status': 'Delivered',
      'date': '2024-02-10',
      'time': '11:20 AM',
      'address': '321 Cedar St, Mbarara',
      'products': [
        {'name': 'Running Shoes', 'quantity': 1, 'price': 'UGX 75,000'},
      ],
      'priority': 'medium',
      'deliveredDate': '2024-02-14',
    },
    {
      'id': '#ORD005',
      'customer': 'David Brown',
      'customerAvatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop&crop=face',
      'items': 2,
      'total': 'UGX 95,000',
      'status': 'Cancelled',
      'date': '2024-02-09',
      'time': '4:30 PM',
      'address': '654 Birch Ave, Gulu',
      'products': [
        {'name': 'Coffee Maker', 'quantity': 1, 'price': 'UGX 95,000'},
      ],
      'priority': 'low',
      'cancelReason': 'Customer requested cancellation',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Map<String, dynamic>> _getOrdersByStatus(String status) {
    var orders = _orders;
    
    // Filter by search query first
    if (_searchQuery.isNotEmpty) {
      orders = orders.where((order) =>
        order['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
        order['customer'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Then filter by status
    if (status == 'All') return orders;
    return orders.where((order) => order['status'] == status).toList();
  }

  List<Map<String, dynamic>> get _filteredOrders {
    return _getOrdersByStatus(_selectedStatus);
  }

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

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final isUrgent = order['priority'] == 'high';
    
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Avatar
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(order['customerAvatar']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Order Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Order ID with urgent badge
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          order['id'],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUrgent) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'URGENT',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Customer name and address
                  Text(
                    order['customer'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: AppColors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          order['address'],
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.secondaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // Total price
                  Text(
                    order['total'],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // Status and items info in a Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order['status']).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order['status'],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(order['status']),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${order['items']} items • ${order['date']}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.secondaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Action Button
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/seller/order-details',
                  arguments: order,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.visibility_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildOrdersList(String status) {
    final orders = _filteredOrders;
    
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _selectedStatus == 'All' ? 'No orders yet' : 'No ${_selectedStatus.toLowerCase()} orders',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty 
                ? 'No orders match your search'
                : 'Orders will appear here when available',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
                child: const Text('Clear search'),
              ),
            ],
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(orders[index]);
      },
    );
  }

  Widget _buildStatusFilterChips() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _statusFilters.length,
        itemBuilder: (context, index) {
          final status = _statusFilters[index];
          final isSelected = _selectedStatus == status;
          final count = _getOrdersByStatus(status).length;
          
          Color chipColor;
          IconData chipIcon;
          
          switch (status) {
            case 'All':
              chipColor = AppColors.primary;
              chipIcon = Icons.list_alt;
              break;
            case 'Pending':
              chipColor = Colors.orange;
              chipIcon = Icons.schedule;
              break;
            case 'Processing':
              chipColor = AppColors.primary;
              chipIcon = Icons.sync;
              break;
            case 'Shipped':
              chipColor = Colors.blue;
              chipIcon = Icons.local_shipping;
              break;
            case 'Delivered':
              chipColor = AppColors.success;
              chipIcon = Icons.check_circle;
              break;
            case 'Cancelled':
              chipColor = AppColors.error;
              chipIcon = Icons.cancel;
              break;
            default:
              chipColor = AppColors.grey;
              chipIcon = Icons.help_outline;
          }
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedStatus = status;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? chipColor : AppColors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? chipColor : AppColors.lightGrey,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: chipColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ] : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      chipIcon,
                      size: 18,
                      color: isSelected ? AppColors.white : chipColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? AppColors.white : AppColors.text,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected 
                            ? AppColors.white.withValues(alpha: 0.3)
                            : chipColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.white : chipColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'My Orders',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: const [NotificationIcon()],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search orders by ID or customer...',
                  hintStyle: const TextStyle(color: AppColors.grey),
                  prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.grey),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                ),
              ),
            ),
          ),
          
          // Status Filter Chips
          _buildStatusFilterChips(),
          
          // Orders List
          Expanded(
            child: _buildOrdersList(_selectedStatus),
          ),
        ],
      ),
    );
  }
}