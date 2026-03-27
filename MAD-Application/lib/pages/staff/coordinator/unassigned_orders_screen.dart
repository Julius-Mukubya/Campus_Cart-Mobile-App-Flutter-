import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/widgets/notification_icon.dart';
import 'package:madpractical/services/order_service.dart';

class UnassignedOrdersScreen extends StatefulWidget {
  const UnassignedOrdersScreen({super.key});

  @override
  State<UnassignedOrdersScreen> createState() => _UnassignedOrdersScreenState();
}

class _UnassignedOrdersScreenState extends State<UnassignedOrdersScreen> {
  final OrderService _orderService = OrderService();
  final Set<String> _selectedOrders = {};

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
            child: const Icon(Icons.arrow_back_ios, color: AppColors.text, size: 16),
          ),
        ),
        title: const Text(
          'Approved Orders (Unassigned)',
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
          if (_selectedOrders.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.primary.withValues(alpha: 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selectedOrders.length} orders selected',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/staff/assign-pickup', arguments: _selectedOrders.toList());
                    },
                    icon: const Icon(Icons.local_shipping, size: 16),
                    label: const Text('Assign Pickup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _orderService.getUnassignedApprovedOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final orders = snapshot.data ?? [];
                
                if (orders.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 64, color: AppColors.secondaryText),
                        SizedBox(height: 16),
                        Text(
                          'No unassigned approved orders',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Vendor-approved orders will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final orderId = order['orderId'];
                    final isSelected = _selectedOrders.contains(orderId);
                    
                    return _buildOrderCard(order, isSelected, orderId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, bool isSelected, String orderId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (value) {
          setState(() {
            if (value == true) {
              _selectedOrders.add(orderId);
            } else {
              _selectedOrders.remove(orderId);
            }
          });
        },
        title: Text(
          order['orderNumber'] ?? orderId,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Customer: ${order['customerName']}'),
            Text('Items: ${order['items']?.length ?? 0}'),
            Text('Total: UGX ${order['total']}'),
          ],
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
