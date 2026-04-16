import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/seller_service.dart';
import 'package:madpractical/services/user_manager.dart';
import 'package:madpractical/services/firebase_auth_service.dart';
import 'package:madpractical/widgets/notification_icon.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  final SellerService _sellerService = SellerService();
  final UserManager _userManager = UserManager();
  final FirebaseAuthService _authService = FirebaseAuthService();

  String _searchQuery = '';
  String _selectedStatus = 'All';
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  final List<String> _statusFilters = ['All', 'pending', 'processing', 'shipped', 'delivered', 'cancelled'];
  final List<String> _statusLabels = ['All', 'Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final uid = _userManager.userId ?? _authService.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }
    final orders = await _sellerService.getSellerOrders(uid);
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredOrders {
    var orders = _orders;
    if (_searchQuery.isNotEmpty) {
      orders = orders.where((o) =>
        (o['orderId'] ?? o['id'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (o['customerName'] ?? o['customer'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    if (_selectedStatus != 'All') {
      orders = orders.where((o) =>
        (o['status'] ?? '').toString().toLowerCase() == _selectedStatus.toLowerCase()
      ).toList();
    }
    return orders;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':    return Colors.orange;
      case 'processing': return AppColors.primary;
      case 'shipped':    return Colors.blue;
      case 'delivered':  return AppColors.success;
      case 'cancelled':  return AppColors.error;
      default:           return AppColors.grey;
    }
  }

  String _formatStatus(String status) {
    if (status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
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

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = (order['status'] ?? 'pending').toString();
    final orderId = (order['orderId'] ?? order['id'] ?? '').toString();
    final customer = (order['customerName'] ?? order['customer'] ?? 'Customer').toString();
    final total = order['totalAmount'] ?? order['total'] ?? 0;
    final itemCount = (order['items'] as List?)?.length ?? order['itemCount'] ?? 0;
    final address = (order['deliveryAddress']?['addressLine1'] ?? order['address'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('#${orderId.length > 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase()}',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.text)),
                  const SizedBox(height: 2),
                  Text(customer, style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                  if (address.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(Icons.location_on, size: 12, color: AppColors.grey),
                      const SizedBox(width: 4),
                      Expanded(child: Text(address, style: TextStyle(fontSize: 10, color: AppColors.secondaryText), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                  ],
                  const SizedBox(height: 6),
                  Text('UGX $total', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: _getStatusColor(status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(_formatStatus(status), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _getStatusColor(status))),
                    ),
                    const SizedBox(width: 8),
                    Text('$itemCount items • ${_formatDate(order['createdAt'])}',
                        style: TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                  ]),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/seller/order-details', arguments: order),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.visibility_outlined, color: AppColors.primary, size: 18),
              ),
            ),
          ],
        ),
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
              color: AppColors.white, borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: const Icon(Icons.arrow_back_ios, color: AppColors.text, size: 16),
          ),
        ),
        title: const Text('My Orders', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          IconButton(onPressed: _loadOrders, icon: const Icon(Icons.refresh, color: AppColors.text)),
          const NotificationIcon(),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search orders...',
                  hintStyle: const TextStyle(color: AppColors.grey),
                  prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear, color: AppColors.grey), onPressed: () => setState(() => _searchQuery = ''))
                      : null,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _statusFilters.length,
              itemBuilder: (context, i) {
                final isSelected = _selectedStatus == _statusFilters[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedStatus = _statusFilters[i]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.lightGrey),
                      ),
                      child: Text(_statusLabels[i],
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                              color: isSelected ? AppColors.white : AppColors.text)),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primary)))
                : _filteredOrders.isEmpty
                    ? Center(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.grey),
                          const SizedBox(height: 16),
                          Text(_selectedStatus == 'All' ? 'No orders yet' : 'No $_selectedStatus orders',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
                          const SizedBox(height: 8),
                          const Text('Orders will appear here when customers place them',
                              style: TextStyle(fontSize: 14, color: AppColors.secondaryText), textAlign: TextAlign.center),
                        ]),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredOrders.length,
                          itemBuilder: (context, i) => _buildOrderCard(_filteredOrders[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
