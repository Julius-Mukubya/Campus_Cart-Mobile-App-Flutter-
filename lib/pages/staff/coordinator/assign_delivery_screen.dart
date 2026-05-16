import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/widgets/notification_icon.dart';
import 'package:madpractical/services/order_service.dart';

class AssignDeliveryScreen extends StatefulWidget {
  const AssignDeliveryScreen({super.key});

  @override
  State<AssignDeliveryScreen> createState() => _AssignDeliveryScreenState();
}

class _AssignDeliveryScreenState extends State<AssignDeliveryScreen> {
  final OrderService _orderService = OrderService();
  String? _selectedStaffId;
  String? _selectedStaffName;
  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 1));
  final Set<String> _selectedOrders = {};
  bool _isLoading = false;

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
          'Assign Final Delivery',
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
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${_selectedOrders.length} packaged orders selected',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Delivery Date: ', style: TextStyle(fontWeight: FontWeight.w600)),
                    TextButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _scheduledDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (date != null) {
                          setState(() => _scheduledDate = date);
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text('${_scheduledDate.day}/${_scheduledDate.month}/${_scheduledDate.year}'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildPackagedOrdersList(),
                ),
                Container(
                  width: 1,
                  color: AppColors.lightGrey,
                ),
                Expanded(
                  flex: 1,
                  child: _buildStaffList(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _selectedStaffId == null || _selectedOrders.isEmpty || _isLoading
              ? null
              : () async {
                  setState(() => _isLoading = true);
                  
                  try {
                    for (final orderId in _selectedOrders) {
                      await _orderService.assignFinalDelivery(
                        orderId,
                        _selectedStaffId!,
                        _selectedStaffName!,
                        _scheduledDate,
                      );
                    }
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${_selectedOrders.length} orders assigned to $_selectedStaffName'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
              : const Text('Assign Delivery', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildPackagedOrdersList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _orderService.getPackagedOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final orders = snapshot.data ?? [];
        
        if (orders.isEmpty) {
          return const Center(child: Text('No packaged orders'));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final orderId = order['orderId'];
            final isSelected = _selectedOrders.contains(orderId);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
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
                title: Text(order['orderNumber'] ?? orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('${order['customerName']} - UGX ${order['total']}', style: const TextStyle(fontSize: 12)),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStaffList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'staff')
          .where('staffType', isEqualTo: 'final_delivery')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final staff = snapshot.data?.docs ?? [];
        
        if (staff.isEmpty) {
          return const Center(child: Text('No delivery staff'));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: staff.length,
          itemBuilder: (context, index) {
            final staffData = staff[index].data() as Map<String, dynamic>;
            final staffId = staff[index].id;
            final isSelected = _selectedStaffId == staffId;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.person, color: AppColors.primary, size: 20),
                ),
                title: Text(staffData['name'] ?? 'Unknown', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text('${staffData['completedDeliveries'] ?? 0} deliveries', style: const TextStyle(fontSize: 12)),
                trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                onTap: () {
                  setState(() {
                    _selectedStaffId = staffId;
                    _selectedStaffName = staffData['name'];
                  });
                },
              ),
            );
          },
        );
      },
    );
  }
}
