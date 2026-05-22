import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/providers/seller_request_provider.dart';
import 'package:madpractical/providers/user_provider.dart';
import 'package:madpractical/models/seller_request_model.dart';

class SellerManagementScreen extends ConsumerStatefulWidget {
  const SellerManagementScreen({super.key});

  @override
  ConsumerState<SellerManagementScreen> createState() =>
      _SellerManagementScreenState();
}

class _SellerManagementScreenState extends ConsumerState<SellerManagementScreen> {
  String _filter = 'pending';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sellerRequestNotifierProvider.notifier).loadPendingRequests();
    });
  }

  Color _getStatusColor(String status) {
    if (status == 'approved') return AppColors.success;
    if (status == 'rejected') return AppColors.error;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(sellerRequestNotifierProvider);
    final isLoading = ref.watch(pendingSellerRequestsProvider).isLoading;

    final filteredRequests = _filter == 'all'
        ? requests
        : requests.where((r) => r.status == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Requests'),
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
                const SizedBox(width: 8),
                _filterButton('All', 'all'),
              ],
            ),
          ),
          // Requests list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRequests.isEmpty
                    ? Center(
                        child: Text(
                          'No $_filter seller requests',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredRequests.length,
                        itemBuilder: (context, index) =>
                            _buildRequestTile(filteredRequests[index]),
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

  Widget _buildRequestTile(SellerRequestModel req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(12),
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
                            req.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            req.userEmail,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          if (req.userPhone != null && req.userPhone!.isNotEmpty)
                            Text(
                              req.userPhone!,
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
                        color: _getStatusColor(req.status).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        req.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(req.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (req.status == 'pending')
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
            ),
        ],
      ),
    );
  }

  Future<void> _approveRequest(SellerRequestModel request) async {
    final adminId = ref.read(userProvider).userId;
    if (adminId == null || adminId.isEmpty) return;

    final result = await ref.read(sellerRequestNotifierProvider.notifier).approveSeller(
      request.id,
      adminId,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] as String? ?? 'Request approved'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _rejectRequest(SellerRequestModel request) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Request'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(hintText: 'Reason for rejection...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final reason = reasonCtrl.text.trim();
              if (reason.isEmpty) return;
              Navigator.pop(dialogContext);
              final adminId = ref.read(userProvider).userId;
              if (adminId == null || adminId.isEmpty) return;
              final result = await ref.read(sellerRequestNotifierProvider.notifier).rejectSeller(
                request.id,
                adminId,
                reason,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'] as String? ?? 'Request rejected'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}