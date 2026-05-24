import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/providers/user_provider.dart';
import 'package:madpractical/widgets/common/notification_icon.dart';

class MyOrdersScreen extends ConsumerStatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  ConsumerState<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends ConsumerState<MyOrdersScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Accepted', 'Cancelled', 'Completed'];

  List<Map<String, dynamic>> _cachedOrders = [];
  bool _loadingCache = true;

  @override
  void initState() {
    super.initState();
    _loadCachedOrders();
  }

  Future<void> _loadCachedOrders() async {
    final uid = ref.read(userProvider).userId;
    if (uid == null || uid.isEmpty) { setState(() => _loadingCache = false); return; }
    final List<Map<String, dynamic>> cached = [];
    if (mounted) {
      setState(() { _cachedOrders = cached; _loadingCache = false; });
    }
  }

  // ── Actions ────────────────────────────────────────────────────────────
  Future<void> _markComplete() async {
    // Stub: will be wired to order provider in Phase C
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mark as complete — will be available from order details'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _cancelOrder(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this pending order?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Order cancelled'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  // ── status helpers ────────────────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':    return Colors.orange;
      case 'accepted':   return AppColors.primary;
      case 'rejected':   return AppColors.error;
      case 'cancelled':  return Colors.grey;
      case 'completed':  return AppColors.success;
      default:           return AppColors.grey;
    }
  }

  bool _isActive(String status) =>
      status != 'completed' &&
      status != 'Completed' &&
      status != 'cancelled' &&
      status != 'Cancelled' &&
      status != 'rejected' &&
      status != 'Rejected';

  bool _matchesFilter(String status) {
    if (_selectedFilter == 'All') return true;
    if (_selectedFilter == 'Active') return _isActive(status);
    return status.toLowerCase() == _selectedFilter.toLowerCase();
  }

  // ── Firestore stream ──────────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> _ordersStream() {
    final uid = ref.read(userProvider).userId;
    if (uid == null || uid.isEmpty) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('orders')
        .where('customerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snap) async {
          final orders = snap.docs.map((doc) {
            final d = doc.data();
            return {
              'id': doc.id,
              'date': d['date'] ?? '',
              'status': d['status'] ?? 'pending',
              'items': d['itemCount'] ?? 0,
              'total': 'UGX ${(d['total'] ?? 0).toStringAsFixed(0)}',
              'products': d['products'] ?? [],
              'subtotal': d['subtotal'] ?? 0,
            };
          }).toList();
          // Write-through cache
          return orders;
        });
  }

  // ── Order card ────────────────────────────────────────────────────────────
  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final color  = _statusColor(status);
    final active = _isActive(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            // Header row
            Row(
              children: [
                Expanded(
                  child: Text(
                    '#${order['id'].toString().substring(0, 8).toUpperCase()}',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(status,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color)),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Meta row
            Row(
              children: [
                const Icon(Icons.shopping_bag_outlined,
                    size: 15, color: AppColors.grey),
                const SizedBox(width: 6),
                Text('${order['items']} item(s)',
                    style: TextStyle(
                        fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color)),
                const SizedBox(width: 16),
                const Icon(Icons.calendar_today_outlined,
                    size: 15, color: AppColors.grey),
                const SizedBox(width: 6),
                Text(order['date'],
                    style: TextStyle(
                        fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color)),
              ],
            ),

            const SizedBox(height: 6),

            // Address
            if ((order['shippingAddress'] as String).isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 15, color: AppColors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(order['shippingAddress'],
                        style: TextStyle(
                            fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),

            const SizedBox(height: 10),

            // Total
            Text(order['total'],
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),

            const SizedBox(height: 14),

            // Actions
            Row(
              children: [
          if (active && status.toLowerCase() == 'accepted')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _markComplete,
                      icon: const Icon(Icons.check_circle_outline, size: 15),
                      label: const Text('Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                if (active && status.toLowerCase() == 'accepted') const SizedBox(width: 8),
                if (status.toLowerCase() == 'pending')
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelOrder(order),
                      icon: const Icon(Icons.cancel_outlined, size: 15),
                      label: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                if (status.toLowerCase() == 'pending') const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDetails(order),
                    icon: const Icon(Icons.receipt_outlined, size: 15),
                    label: const Text('Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Order details sheet ───────────────────────────────────────────────────
  void _showDetails(Map<String, dynamic> order) {
    final products = order['products'] as List;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          color: AppColors.getSurface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Order #${order['id'].toString().substring(0, 8).toUpperCase()}',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow('Status', order['status']),
                    _detailRow('Date', order['date']),
                    _detailRow('Payment', order['paymentMethod']),
                    _detailRow('Address', order['shippingAddress']),
                    _detailRow('Subtotal',
                        'UGX ${(order['subtotal'] ?? 0).toStringAsFixed(0)}'),
                    _detailRow('Delivery Fee',
                        'UGX ${(order['deliveryFee'] ?? 0).toStringAsFixed(0)}'),
                    _detailRow('Total', order['total']),
                    if (products.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('Items',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.text)),
                      const SizedBox(height: 10),
                      ...products.map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                if ((p['image'] ?? '').isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      p['image'],
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          Container(
                                              width: 40,
                                              height: 40,
                                              color: AppColors.lightGrey),
                                    ),
                                  ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${p['name']} × ${p['quantity']}',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.text),
                                  ),
                                ),
                                Text(
                                  p['price'].toString().contains('UGX')
                                      ? p['price']
                                      : 'UGX ${p['price']}',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color)),
            ),
            Expanded(
              child: Text(value,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color)),
            ),
          ],
        ),
      );

  Widget _buildOrdersList(List<Map<String, dynamic>> orders,
      List<Map<String, dynamic>> all, {bool isFromCache = false}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined,
                size: 72, color: AppColors.grey.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              all.isEmpty ? 'No orders yet' : 'No $_selectedFilter orders',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
            if (all.isEmpty) ...[
              const SizedBox(height: 8),
              Text('Your orders will appear here',
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color)),
            ],
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (_, i) => _buildOrderCard(orders[i]),
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
              color: AppColors.getSurface(context),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2))
              ],
            ),
            child: const Icon(Icons.arrow_back_ios,
                color: AppColors.text, size: 16),
          ),
        ),
        title: const Text('My Orders',
            style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        actions: const [NotificationIcon()],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (_, i) {
                final f = _filters[i];
                final sel = _selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 10, top: 8, bottom: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: sel,
                    onSelected: (_) => setState(() => _selectedFilter = f),
                    backgroundColor: AppColors.getCards(context),
                    selectedColor: AppColors.primary.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                        color: sel ? AppColors.primary : Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.normal),
                    side: BorderSide(
                        color: sel ? AppColors.primary : Theme.of(context).dividerColor),
                  ),
                );
              },
            ),
          ),

          // Orders
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _ordersStream(),
              builder: (context, snapshot) {
                // Show SQLite cache immediately while stream is loading
                if (snapshot.connectionState == ConnectionState.waiting &&
                    _loadingCache == false && _cachedOrders.isNotEmpty) {
                  final orders = _cachedOrders
                      .where((o) => _matchesFilter(o['status'] as String))
                      .toList();
                  return _buildOrdersList(orders, _cachedOrders, isFromCache: true);
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                }

                final all = snapshot.data ?? [];
                final orders = all
                    .where((o) => _matchesFilter(o['status'] as String))
                    .toList();
                return _buildOrdersList(orders, all);
              },
            ),
          ),
        ],
      ),
    );
  }
}


