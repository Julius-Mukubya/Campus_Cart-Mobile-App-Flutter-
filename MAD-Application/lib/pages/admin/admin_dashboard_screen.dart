import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/widgets/notification_icon.dart';
import 'package:madpractical/services/admin_service.dart';
import 'package:madpractical/services/user_manager.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  final UserManager _userManager = UserManager();
  
  Map<String, dynamic> _platformStats = {};
  List<Map<String, dynamic>> _pendingSellerRequests = [];
  List<Map<String, dynamic>> _pendingStoreRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final stats = await _adminService.getPlatformStats();
      final sellerRequests = await _adminService.getPendingSellerRequests();
      final storeRequests = await _adminService.getPendingStoreRequests();
      
      setState(() {
        _platformStats = stats;
        _pendingSellerRequests = sellerRequests;
        _pendingStoreRequests = storeRequests;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
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
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(String title, String message, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.grey,
          ),
        ],
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
          'Admin Dashboard',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: const [NotificationIcon()],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : SafeArea(
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
                                  'Platform Overview',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Manage your e-commerce platform',
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
                            child: const Icon(
                              Icons.admin_panel_settings,
                              color: AppColors.primary,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Summary Cards
                    const Text(
                      'Platform Statistics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        _buildSummaryCard('Total Users', '${_platformStats['totalUsers'] ?? 0}', Icons.people, AppColors.primary),
                        _buildSummaryCard('Active Sellers', '${_platformStats['activeSellers'] ?? 0}', Icons.store, AppColors.success),
                        _buildSummaryCard('Total Orders', '${_platformStats['totalOrders'] ?? 0}', Icons.shopping_bag, AppColors.accent),
                        _buildSummaryCard('Pending Requests', '${(_platformStats['pendingSellerRequests'] ?? 0) + (_platformStats['pendingStoreRequests'] ?? 0)}', Icons.pending_actions, Colors.orange),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Alerts Section
                    const Text(
                      'Alerts & Notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (_pendingSellerRequests.isNotEmpty)
                      GestureDetector(
                        onTap: () => _showSellerApprovalDialog(),
                        child: _buildAlertCard(
                          'Pending Seller Approvals',
                          '${_pendingSellerRequests.length} sellers waiting for approval',
                          Icons.pending_actions,
                          AppColors.accent,
                        ),
                      ),
                    
                    if (_pendingStoreRequests.isNotEmpty)
                      GestureDetector(
                        onTap: () => _showStoreApprovalDialog(),
                        child: _buildAlertCard(
                          'Pending Store Approvals',
                          '${_pendingStoreRequests.length} stores waiting for approval',
                          Icons.store_mall_directory,
                          AppColors.primary,
                        ),
                      ),
                    
                    if (_pendingSellerRequests.isEmpty && _pendingStoreRequests.isEmpty)
                      _buildAlertCard(
                        'All Clear!',
                        'No pending approvals at this time',
                        Icons.check_circle,
                        AppColors.success,
                      ),
                    
                    const SizedBox(height: 32),
                    
                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.3,
                      children: [
                        _buildQuickAction('Seller Approvals', Icons.how_to_reg, AppColors.primary, () {
                          _showSellerApprovalDialog();
                        }),
                        _buildQuickAction('Store Approvals', Icons.store, AppColors.accent, () {
                          _showStoreApprovalDialog();
                        }),
                        _buildQuickAction('Manage Sellers', Icons.people, AppColors.success, () {
                          Navigator.pushNamed(context, '/admin/sellers');
                        }),
                        _buildQuickAction('Refresh Data', Icons.refresh, Colors.grey, () {
                          setState(() {
                            _isLoading = true;
                          });
                          _loadDashboardData();
                        }),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  void _showSellerApprovalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seller Approvals'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _pendingSellerRequests.isEmpty
              ? const Center(
                  child: Text('No pending seller requests'),
                )
              : ListView.builder(
                  itemCount: _pendingSellerRequests.length,
                  itemBuilder: (context, index) {
                    final request = _pendingSellerRequests[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.person, color: AppColors.primary),
                        ),
                        title: Text(request['name'] ?? 'Unknown'),
                        subtitle: Text(request['email'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: AppColors.success),
                              onPressed: () => _approveSeller(request),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: AppColors.error),
                              onPressed: () => _rejectSeller(request),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStoreApprovalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Store Approvals'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _pendingStoreRequests.isEmpty
              ? const Center(
                  child: Text('No pending store requests'),
                )
              : ListView.builder(
                  itemCount: _pendingStoreRequests.length,
                  itemBuilder: (context, index) {
                    final request = _pendingStoreRequests[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.accent.withValues(alpha: 0.1),
                          child: const Icon(Icons.store, color: AppColors.accent),
                        ),
                        title: Text(request['storeName'] ?? 'Unknown Store'),
                        subtitle: Text(request['storeCategory'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: AppColors.success),
                              onPressed: () => _approveStore(request),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: AppColors.error),
                              onPressed: () => _rejectStore(request),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _approveSeller(Map<String, dynamic> request) async {
    try {
      final adminId = _userManager.userId;
      if (adminId == null) return;

      final result = await _adminService.approveSellerRequest(
        requestId: request['requestId'],
        userId: request['userId'],
        adminId: adminId,
        adminNotes: 'Approved by admin',
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
        _loadDashboardData(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error approving seller'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _rejectSeller(Map<String, dynamic> request) async {
    try {
      final adminId = _userManager.userId;
      if (adminId == null) return;

      final result = await _adminService.rejectSellerRequest(
        requestId: request['requestId'],
        userId: request['userId'],
        adminId: adminId,
        rejectionReason: 'Application does not meet requirements',
        adminNotes: 'Rejected by admin',
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
        _loadDashboardData(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error rejecting seller'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _approveStore(Map<String, dynamic> request) async {
    try {
      final adminId = _userManager.userId;
      if (adminId == null) return;

      final result = await _adminService.approveStoreRequest(
        requestId: request['requestId'],
        storeId: request['storeId'],
        adminId: adminId,
        adminNotes: 'Store approved by admin',
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
        _loadDashboardData(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error approving store'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _rejectStore(Map<String, dynamic> request) async {
    try {
      final adminId = _userManager.userId;
      if (adminId == null) return;

      final result = await _adminService.rejectStoreRequest(
        requestId: request['requestId'],
        storeId: request['storeId'],
        adminId: adminId,
        rejectionReason: 'Store information incomplete or inappropriate',
        adminNotes: 'Store rejected by admin',
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
        _loadDashboardData(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error rejecting store'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}