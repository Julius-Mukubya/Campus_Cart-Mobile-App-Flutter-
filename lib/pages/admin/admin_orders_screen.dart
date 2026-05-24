import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/admin_service.dart';

/// Admin orders list using AdminService instead of FirebaseFirestore.instance directly.
class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  final AdminService _adminService = AdminService();
  String _filterStatus = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return AppColors.primary;
      case 'rejected':
        return AppColors.error;
      case 'cancelled':
        return AppColors.grey;
      case 'completed':
        return AppColors.success;
      default:
        return AppColors.grey;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    DateTime dt;
    if (date is Timestamp) {
      dt = date.toDate();
    } else {
      dt = DateTime.now();
    }
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        title: const Text('All Orders'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.text),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by customer, seller, or product...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.getSurface(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              ),
            ),

            // Filter Chips
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['all', 'pending', 'accepted', 'rejected', 'cancelled', 'completed'].map((filter) {
                  final isSelected = _filterStatus == filter;
                  final label = filter == 'all' ? 'All' : '${filter[0].toUpperCase()}${filter.substring(1)}';
                  return Container(
                    margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                    child: FilterChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (selected) => setState(() => _filterStatus = filter),
                      backgroundColor: AppColors.getSurface(context),
                      selectedColor: AppColors.primary.withValues(alpha: 0.1),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.lightGrey,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Orders List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _adminService.ordersStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: const TextStyle(color: AppColors.error)),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var orders = snapshot.data!.docs.toList();

                  if (orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No orders found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {},
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final doc = orders[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final orderId = doc.id;
                        final status = data['status'] as String? ?? 'pending';
                        final total = (data['total'] as num?)?.toDouble() ?? 0.0;
                        final items = data['items'] as List? ?? [];
                        final customerName = data['customerName'] as String? ?? 'Unknown Customer';
                        final sellerName = data['sellerName'] as String? ?? 'Unknown Seller';
                        final createdAt = data['createdAt'];

                        // Filter by status
                        if (_filterStatus != 'all' && status != _filterStatus) return const SizedBox.shrink();

                        // Filter by search query
                        if (_searchQuery.isNotEmpty) {
                          final query = _searchQuery;
                          final matchesCustomer = customerName.toLowerCase().contains(query);
                          final matchesSeller = sellerName.toLowerCase().contains(query);
                          final matchesProduct = items.any((item) {
                            final name = (item['name'] as String? ?? '').toLowerCase();
                            return name.contains(query);
                          });
                          if (!matchesCustomer && !matchesSeller && !matchesProduct) {
                            return const SizedBox.shrink();
                          }
                        }

                        return GestureDetector(
                          onTap: () => context.push('/order-details', extra: data),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
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
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Order #${orderId.substring(0, 8)}...',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(status).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          status.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: _getStatusColor(status),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.person, size: 14, color: AppColors.grey),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Customer: $customerName',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Theme.of(context).textTheme.bodyMedium?.color,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.store, size: 14, color: AppColors.grey),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Seller: $sellerName',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Theme.of(context).textTheme.bodyMedium?.color,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (items.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.inventory_2, size: 14, color: AppColors.grey),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Items: ${items.map((i) => i['name'] ?? 'Product').join(', ')}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context).textTheme.bodyMedium?.color,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDate(createdAt),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                      Text(
                                        'UGX ${total.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}