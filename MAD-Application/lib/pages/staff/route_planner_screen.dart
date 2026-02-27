import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/widgets/notification_icon.dart';

class RoutePlannerScreen extends StatefulWidget {
  const RoutePlannerScreen({super.key});

  @override
  State<RoutePlannerScreen> createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends State<RoutePlannerScreen> {
  final List<Map<String, dynamic>> _deliveryStops = [
    // Order 1: Pickup from seller
    {
      'id': 'STOP001-PICKUP',
      'orderId': '#ORD001',
      'type': 'pickup',
      'locationName': 'Tech Store',
      'address': 'Shop 45, Campus Mall',
      'phone': '+256 700 111 222',
      'distance': '1.2 km',
      'estimatedTime': '5 min',
      'status': 'pending', // pending, deliverer_confirmed, completed
      'priority': 1,
      'items': 2,
      'delivererConfirmed': false,
      'sellerConfirmed': false,
    },
    // Order 1: Delivery to customer
    {
      'id': 'STOP001-DELIVERY',
      'orderId': '#ORD001',
      'type': 'delivery',
      'locationName': 'John Doe',
      'address': '123 Main St, Kampala',
      'phone': '+256 700 123 456',
      'distance': '2.5 km',
      'estimatedTime': '10 min',
      'status': 'locked', // locked until pickup is completed
      'priority': 2,
      'items': 2,
      'delivererConfirmed': false,
      'customerConfirmed': false,
    },
    // Order 2: Pickup from seller
    {
      'id': 'STOP002-PICKUP',
      'orderId': '#ORD003',
      'type': 'pickup',
      'locationName': 'Book Corner',
      'address': 'Shop 8, Library Building',
      'phone': '+256 700 333 444',
      'distance': '3.8 km',
      'estimatedTime': '15 min',
      'status': 'pending',
      'priority': 3,
      'items': 3,
      'delivererConfirmed': false,
      'sellerConfirmed': false,
    },
    // Order 2: Delivery to customer
    {
      'id': 'STOP002-DELIVERY',
      'orderId': '#ORD003',
      'type': 'delivery',
      'locationName': 'Mike Johnson',
      'address': '789 Pine Rd, Jinja',
      'phone': '+256 700 789 012',
      'distance': '5.8 km',
      'estimatedTime': '20 min',
      'status': 'locked',
      'priority': 4,
      'items': 3,
      'delivererConfirmed': false,
      'customerConfirmed': false,
    },
  ];

  final String _totalDistance = '13.3 km';
  final String _totalTime = '50 min';

  Widget _buildStopCard(Map<String, dynamic> stop, int index) {
    final isCompleted = stop['status'] == 'completed';
    final isLocked = stop['status'] == 'locked';
    final isPickup = stop['type'] == 'pickup';
    final delivererConfirmed = stop['delivererConfirmed'] ?? false;
    final otherPartyConfirmed = isPickup 
        ? (stop['sellerConfirmed'] ?? false)
        : (stop['customerConfirmed'] ?? false);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isLocked ? AppColors.lightGrey : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCompleted ? Border.all(color: AppColors.success, width: 2) : null,
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
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? AppColors.success 
                        : isLocked
                            ? AppColors.grey.withValues(alpha: 0.3)
                            : AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: AppColors.white, size: 20)
                        : isLocked
                            ? const Icon(Icons.lock, color: AppColors.grey, size: 18)
                            : Text(
                                '${stop['priority']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPickup 
                                  ? Colors.orange.withValues(alpha: 0.1)
                                  : Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isPickup ? 'PICKUP' : 'DELIVERY',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isPickup ? Colors.orange : Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            stop['orderId'],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stop['locationName'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                if (isLocked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Locked',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppColors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    stop['address'],
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.text,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: AppColors.grey),
                const SizedBox(width: 8),
                Text(
                  stop['phone'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_car, size: 14, color: AppColors.accent),
                      const SizedBox(width: 6),
                      Text(
                        stop['distance'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        stop['estimatedTime'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_bag, size: 14, color: AppColors.success),
                      const SizedBox(width: 6),
                      Text(
                        '${stop['items']} items',
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
            ),
            
            // Confirmation Status
            if (!isCompleted && !isLocked) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confirmation Status:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          delivererConfirmed ? Icons.check_circle : Icons.radio_button_unchecked,
                          size: 16,
                          color: delivererConfirmed ? AppColors.success : AppColors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Deliverer confirmed',
                          style: TextStyle(
                            fontSize: 11,
                            color: delivererConfirmed ? AppColors.success : AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          otherPartyConfirmed ? Icons.check_circle : Icons.radio_button_unchecked,
                          size: 16,
                          color: otherPartyConfirmed ? AppColors.success : AppColors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isPickup ? 'Seller confirmed' : 'Customer confirmed',
                          style: TextStyle(
                            fontSize: 11,
                            color: otherPartyConfirmed ? AppColors.success : AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            
            if (!isCompleted && !isLocked) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openNavigation(stop),
                      icon: const Icon(Icons.navigation, size: 16),
                      label: const Text('Navigate'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: delivererConfirmed 
                          ? null 
                          : () => _confirmAction(stop),
                      icon: const Icon(Icons.check_circle, size: 16),
                      label: Text(isPickup ? 'Confirm Pickup' : 'Confirm Delivery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: delivererConfirmed ? AppColors.grey : AppColors.success,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
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
          ],
        ),
      ),
    );
  }

  void _openNavigation(Map<String, dynamic> stop) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening navigation to ${stop['address']}'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmAction(Map<String, dynamic> stop) {
    final isPickup = stop['type'] == 'pickup';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isPickup ? 'Confirm Pickup' : 'Confirm Delivery'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPickup 
                  ? 'Have you picked up the items from ${stop['locationName']}?'
                  : 'Have you delivered the items to ${stop['locationName']}?',
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
                  Expanded(
                    child: Text(
                      isPickup
                          ? 'Seller must also confirm handover'
                          : 'Customer must also confirm receipt',
                      style: const TextStyle(
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
                stop['delivererConfirmed'] = true;
                // Simulate seller/customer confirmation after a delay
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    setState(() {
                      if (isPickup) {
                        stop['sellerConfirmed'] = true;
                        // Unlock the corresponding delivery stop
                        final deliveryStop = _deliveryStops.firstWhere(
                          (s) => s['orderId'] == stop['orderId'] && s['type'] == 'delivery',
                          orElse: () => {},
                        );
                        if (deliveryStop.isNotEmpty) {
                          deliveryStop['status'] = 'pending';
                        }
                      } else {
                        stop['customerConfirmed'] = true;
                      }
                      
                      // Mark as completed when both parties confirm
                      if ((isPickup && stop['sellerConfirmed']) || 
                          (!isPickup && stop['customerConfirmed'])) {
                        stop['status'] = 'completed';
                      }
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isPickup 
                              ? 'Seller confirmed handover. Item picked up!'
                              : 'Customer confirmed receipt. Delivery complete!',
                        ),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                });
              });
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isPickup 
                        ? 'Pickup confirmed. Waiting for seller confirmation...'
                        : 'Delivery confirmed. Waiting for customer confirmation...',
                  ),
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

  void _optimizeRoute() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Route optimized for fastest delivery'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingStops = _deliveryStops.where((s) => s['status'] == 'pending').length;
    final completedStops = _deliveryStops.where((s) => s['status'] == 'completed').length;
    
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
          'Route Planner',
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
          // Route Summary
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.secondary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '$pendingStops',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const Text(
                            'Pending',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.grey.withValues(alpha: 0.3),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '$completedStops',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                          const Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.directions_car, size: 20, color: AppColors.accent),
                        const SizedBox(width: 8),
                        Text(
                          _totalDistance,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 20, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          _totalTime,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _optimizeRoute,
                    icon: const Icon(Icons.route, size: 18),
                    label: const Text('Optimize Route'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Delivery Stops List
          Expanded(
            child: _deliveryStops.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.map_outlined,
                            size: 64,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No deliveries scheduled',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Delivery stops will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _deliveryStops.length,
                    itemBuilder: (context, index) {
                      return _buildStopCard(_deliveryStops[index], index);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
