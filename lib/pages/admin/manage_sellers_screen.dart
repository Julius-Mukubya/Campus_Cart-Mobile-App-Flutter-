import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/providers/seller_request_provider.dart';
import 'package:madpractical/providers/user_provider.dart';
import 'package:madpractical/models/seller_request_model.dart';

class ManageSellersScreen extends ConsumerStatefulWidget {
  const ManageSellersScreen({super.key});

  @override
  ConsumerState<ManageSellersScreen> createState() => _ManageSellersScreenState();
}

class _ManageSellersScreenState extends ConsumerState<ManageSellersScreen> {
  String _selectedFilter = 'pending';

  @override
  void initState() {
    super.initState();
    // Load pending requests after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sellerRequestNotifierProvider.notifier).loadPendingRequests();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.accent;
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  Widget _buildRequestCard(SellerRequestModel request) {
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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.userName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Email: ${request.userEmail}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      if (request.userPhone != null && request.userPhone!.isNotEmpty)
                        Text(
                          'Phone: ${request.userPhone}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(request.status),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Request date
            Text(
              'Requested: ${_formatDate(request.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),

            // Rejection reason if rejected
            if (request.status == 'rejected' && request.rejectionReason != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Rejection reason: ${request.rejectionReason}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],

            // Actions for pending requests
            if (request.status == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _approveRequest(request),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showRejectDialog(request),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Reject'),
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _approveRequest(SellerRequestModel request) async {
    final adminId = ref.read(userProvider).userId;
    if (adminId == null || adminId.isEmpty) {
      _showSnackBar('You must be logged in as admin', isError: true);
      return;
    }

    final result = await ref.read(sellerRequestNotifierProvider.notifier).approveSeller(request.id, adminId);
    if (mounted) {
      _showSnackBar(result['message'] as String? ?? 'Request processed', isError: !(result['success'] as bool));
    }
    // Pop back to dashboard so it can refresh
    if (mounted && result['success'] == true) {
      context.pop();
    }
  }

  void _showRejectDialog(SellerRequestModel request) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Seller Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reject ${request.userName}\'s seller request'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason for rejection',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                _showSnackBar('Please provide a reason for rejection', isError: true);
                return;
              }
              Navigator.pop(dialogContext);
              final adminId = ref.read(userProvider).userId;
              if (adminId == null || adminId.isEmpty) {
                _showSnackBar('You must be logged in as admin', isError: true);
                return;
              }
      final result = await ref.read(sellerRequestNotifierProvider.notifier).rejectSeller(request.id, adminId, reason);
              if (mounted) {
                _showSnackBar(result['message'] as String? ?? 'Request processed', isError: !(result['success'] as bool));
              }
              // Pop back to dashboard so it can refresh
              if (mounted && result['success'] == true) {
                context.pop();
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(sellerRequestNotifierProvider);
    final isLoading = ref.watch(pendingSellerRequestsProvider).isLoading;

    // Filter
    final filteredRequests = _selectedFilter == 'all'
        ? requests
        : requests.where((r) => r.status == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        title: const Text('Manage Sellers'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.text),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Chips
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['pending', 'approved', 'rejected', 'all'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Container(
                    margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                    child: FilterChip(
                      label: Text(filter[0].toUpperCase() + filter.substring(1)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedFilter = filter);
                      },
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

            // List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredRequests.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.store_outlined,
                                size: 64,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No ${_selectedFilter} seller requests',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => ref.read(sellerRequestNotifierProvider.notifier).loadPendingRequests(),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredRequests.length,
                            itemBuilder: (context, index) {
                              return _buildRequestCard(filteredRequests[index]);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}