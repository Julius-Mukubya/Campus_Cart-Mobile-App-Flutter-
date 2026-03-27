import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/widgets/notification_icon.dart';
import 'package:madpractical/services/order_service.dart';
import 'package:madpractical/services/batch_service.dart';

class AssignPickupScreen extends StatefulWidget {
  const AssignPickupScreen({super.key});

  @override
  State<AssignPickupScreen> createState() => _AssignPickupScreenState();
}

class _AssignPickupScreenState extends State<AssignPickupScreen> {
  final OrderService _orderService = OrderService();
  final BatchService _batchService = BatchService(); // Will be used for batch operations
  String? _selectedStaffId;
  String? _selectedStaffName;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final orderIds = ModalRoute.of(context)?.settings.arguments as List<String>?;

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
          'Assign Pickup Staff',
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
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${orderIds?.length ?? 0} orders ready for pickup assignment',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'staff')
                  .where('staffType', isEqualTo: 'pickup_delivery')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final staff = snapshot.data?.docs ?? [];

                if (staff.isEmpty) {
                  return const Center(
                    child: Text('No pickup delivery staff available'),
                  );
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
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.person, color: AppColors.primary),
                        ),
                        title: Text(
                          staffData['name'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('Completed: ${staffData['completedDeliveries'] ?? 0}'),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: AppColors.primary)
                            : null,
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
          onPressed: _selectedStaffId == null || _isLoading
              ? null
              : () async {
                  setState(() => _isLoading = true);
                  
                  try {
                    // Assign each order to the selected staff
                    for (final orderId in orderIds ?? []) {
                      await _orderService.assignPickup(
                        orderId,
                        _selectedStaffId!,
                        _selectedStaffName!,
                      );
                    }
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${orderIds?.length ?? 0} orders assigned to $_selectedStaffName'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _isLoading = false);
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                )
              : const Text('Assign Pickup', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
