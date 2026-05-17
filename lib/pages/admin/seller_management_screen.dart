import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/business/seller_request_service.dart';
import 'package:madpractical/pages/admin/admin_seller_chat_screen.dart';

class SellerManagementScreen extends StatefulWidget {
  const SellerManagementScreen({super.key});

  @override
  State<SellerManagementScreen> createState() =>
      _SellerManagementScreenState();
}

class _SellerManagementScreenState extends State<SellerManagementScreen> {
  final SellerRequestService _requestService = SellerRequestService();
  String _filter = 'pending';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Sellers'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _filterButton('Pending', 'pending'),
                const SizedBox(width: 8),
                _filterButton('Approved', 'approved'),
                const SizedBox(width: 8),
                _filterButton('Rejected', 'rejected'),
              ],
            ),
          ),
          // Requests list
          Expanded(
            child: ListenableBuilder(
              listenable: _requestService,
              builder: (context, _) {
                final requests = _getRequests();
                if (requests.isEmpty) {
                  return Center(
                    child: Text(
                      'No $_filter seller requests',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  itemBuilder: (context, index) =>
                      _buildRequestTile(requests[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterButton(String label, String value) {
    final isActive = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRequestTile(Map<String, dynamic> req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            req['userName'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            req['storeName'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(req['status'])
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        req['status'].toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(req['status']),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Email: ${req['userEmail']}',
                  style: const TextStyle(fontSize: 11),
                ),
                Text(
                  'Phone: ${req['userPhone']}',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
          if (req['status'] == 'pending')
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _approveRequest(req),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rejectRequest(req),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              ),
            )
          else if (req['status'] == 'approved')
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _openChat(req),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Chat'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getRequests() {
    switch (_filter) {
      case 'pending':
        return _requestService.getPendingRequests();
      case 'approved':
        return _requestService.getApprovedRequests();
      case 'rejected':
        return _requestService.getRejectedRequests();
      default:
        return [];
    }
  }

  Color _getStatusColor(String status) {
    if (status == 'approved') return AppColors.success;
    if (status == 'rejected') return AppColors.error;
    return Colors.orange;
  }

  void _approveRequest(Map<String, dynamic> req) {
    _requestService.approveSellerRequest(
      requestId: req['id'],
      adminId: 'admin_1',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Seller approved!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _rejectRequest(Map<String, dynamic> req) {
    showDialog(
      context: context,
      builder: (context) {
        final reasonCtrl = TextEditingController();
        return AlertDialog(
          title: const Text('Reject Request'),
          content: TextField(
            controller: reasonCtrl,
            decoration: const InputDecoration(hintText: 'Reason...'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _requestService.rejectSellerRequest(
                  requestId: req['id'],
                  adminId: 'admin_1',
                  rejectionReason: reasonCtrl.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request rejected')),
                );
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  void _openChat(Map<String, dynamic> req) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminSellerChatScreen(
          sellerId: req['userId'],
          sellerName: req['userName'],
          sellerEmail: req['userEmail'],
          sellerPhone: req['userPhone'],
          storeName: req['storeName'],
        ),
      ),
    );
  }
}
