import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/widgets/notification_icon.dart';
import 'package:madpractical/services/user_manager.dart';
import 'package:madpractical/pages/qr/qr_scanner_screen.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  final userManager = UserManager();
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.secondaryText,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final staffType = userManager.staffType;
    final isSupport = staffType == 'support';
    final isPickupDelivery = staffType == 'pickup_delivery';
    final isFinalDelivery = staffType == 'final_delivery';
    final isCoordinator = staffType == 'coordinator' || staffType == null; // Default to coordinator
    
    // Dashboard title and icon based on staff type
    String dashboardTitle = 'Staff Dashboard';
    IconData dashboardIcon = Icons.support_agent;
    String welcomeSubtitle = 'Manage your tasks';
    
    if (isCoordinator) {
      dashboardTitle = 'Order Coordinator Dashboard';
      dashboardIcon = Icons.assignment_turned_in;
      welcomeSubtitle = 'Coordinate orders and deliveries';
    } else if (isSupport) {
      dashboardTitle = 'Customer Support Dashboard';
      dashboardIcon = Icons.headset_mic;
      welcomeSubtitle = 'Help customers and resolve issues';
    } else if (isPickupDelivery) {
      dashboardTitle = 'Pickup Delivery Dashboard';
      dashboardIcon = Icons.shopping_bag;
      welcomeSubtitle = 'Manage vendor pickups';
    } else if (isFinalDelivery) {
      dashboardTitle = 'Final Delivery Dashboard';
      dashboardIcon = Icons.local_shipping;
      welcomeSubtitle = 'Manage customer deliveries';
    }
    
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
          dashboardTitle,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: const [NotificationIcon()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                padding: const EdgeInsets.all(24),
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome back!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            welcomeSubtitle,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        dashboardIcon,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Summary Cards - Different for each staff type
              const Text(
                'Today\'s Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 16),
              
              if (isCoordinator) ...[
                // Order Coordinator Summary Cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildSummaryCard('Vendor Pending', '8', Icons.store, AppColors.accent),
                    _buildSummaryCard('Unassigned', '12', Icons.check_circle, AppColors.success),
                    _buildSummaryCard('At HQ', '5', Icons.warehouse, AppColors.primary),
                    _buildSummaryCard('Ready for Delivery', '15', Icons.local_shipping, Colors.blue),
                  ],
                ),
              ] else if (isSupport) ...[
                // Customer Support Summary Cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildSummaryCard('Open Tickets', '8', Icons.support, AppColors.accent),
                    _buildSummaryCard('In Progress', '5', Icons.pending, Colors.orange),
                    _buildSummaryCard('Resolved', '12', Icons.check_circle, AppColors.success),
                    _buildSummaryCard('Avg Response', '5 min', Icons.timer, AppColors.primary),
                  ],
                ),
              ] else if (isPickupDelivery) ...[
                // Pickup Delivery Summary Cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildSummaryCard('Assigned', '6', Icons.assignment, AppColors.accent),
                    _buildSummaryCard('Picked Up', '4', Icons.check_circle, AppColors.success),
                    _buildSummaryCard('At HQ', '10', Icons.warehouse, AppColors.primary),
                    _buildSummaryCard('Total Today', '20', Icons.shopping_bag, Colors.blue),
                  ],
                ),
              ] else if (isFinalDelivery) ...[
                // Final Delivery Summary Cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildSummaryCard('Assigned', '8', Icons.assignment, AppColors.accent),
                    _buildSummaryCard('Out for Delivery', '5', Icons.local_shipping, Colors.blue),
                    _buildSummaryCard('Delivered', '15', Icons.check_circle, AppColors.success),
                    _buildSummaryCard('Distance', '45 km', Icons.route, AppColors.primary),
                  ],
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Quick Actions - Different for each staff type
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 16),
              
              if (isCoordinator) ...[
                // Order Coordinator Quick Actions
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    _buildQuickAction('Approved Orders', Icons.check_circle, AppColors.primary, () {
                      Navigator.pushNamed(context, '/staff/unassigned-orders');
                    }),
                    _buildQuickAction('Assign Pickup', Icons.shopping_bag, Colors.orange, () {
                      Navigator.pushNamed(context, '/staff/assign-pickup');
                    }),
                    _buildQuickAction('HQ Management', Icons.warehouse, AppColors.success, () {
                      Navigator.pushNamed(context, '/staff/hq-management');
                    }),
                    _buildQuickAction('Assign Delivery', Icons.local_shipping, Colors.blue, () {
                      Navigator.pushNamed(context, '/staff/assign-delivery');
                    }),
                  ],
                ),
              ] else if (isSupport) ...[
                // Customer Support Quick Actions
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    _buildQuickAction('Support Tickets', Icons.headset_mic, AppColors.accent, () {
                      Navigator.pushNamed(context, '/staff/tickets');
                    }),
                    _buildQuickAction('Live Chat', Icons.chat, Colors.blue, () {
                      Navigator.pushNamed(context, '/staff/chat');
                    }),
                    _buildQuickAction('Help Center', Icons.library_books, AppColors.success, () {
                      Navigator.pushNamed(context, '/staff/help-center');
                    }),
                  ],
                ),
              ] else if (isPickupDelivery) ...[
                // Pickup Delivery Quick Actions
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    _buildQuickAction('My Pickups', Icons.shopping_bag, Colors.orange, () {
                      Navigator.pushNamed(context, '/delivery/pickup-orders');
                    }),
                    _buildQuickAction('Scan QR', Icons.qr_code_scanner, AppColors.primary, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QRScannerScreen(scanType: 'pickup'),
                        ),
                      );
                    }),
                    _buildQuickAction('History', Icons.history, AppColors.success, () {
                      Navigator.pushNamed(context, '/staff/delivery-history');
                    }),
                  ],
                ),
              ] else if (isFinalDelivery) ...[
                // Final Delivery Quick Actions
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    _buildQuickAction('My Deliveries', Icons.local_shipping, AppColors.primary, () {
                      Navigator.pushNamed(context, '/delivery/final-orders');
                    }),
                    _buildQuickAction('Route Planner', Icons.map, Colors.blue, () {
                      Navigator.pushNamed(context, '/staff/route-planner');
                    }),
                    _buildQuickAction('History', Icons.history, AppColors.success, () {
                      Navigator.pushNamed(context, '/staff/delivery-history');
                    }),
                  ],
                ),
              ],
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}