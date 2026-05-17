import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/managers/user_manager.dart';
import 'package:madpractical/services/business/seller_request_service.dart';

class BecomeSellersScreen extends StatefulWidget {
  const BecomeSellersScreen({super.key});

  @override
  State<BecomeSellersScreen> createState() => _BecomeSellersScreenState();
}

class _BecomeSellersScreenState extends State<BecomeSellersScreen> {
  final _userManager = UserManager();
  final _sellerRequestService = SellerRequestService();

  bool _isLoading = false;
  bool _hasActiveRequest = false;
  Map<String, dynamic>? _requestStatus;

  @override
  void initState() {
    super.initState();
    _checkExistingRequest();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkExistingRequest() async {
    final userId = _userManager.userId;
    if (userId == null) return;
    
    // Check for pending request
    final pending = _sellerRequestService.hasPendingSellerRequest(userId);
    if (pending) {
      setState(() {
        _hasActiveRequest = true;
        _requestStatus = {'status': 'pending', 'message': 'Your seller request is being reviewed by admin'};
      });
      return;
    }

    // Check for approved request
    final approved = _sellerRequestService.hasApprovedSellerRequest(userId);
    if (approved) {
      setState(() {
        _hasActiveRequest = true;
        _requestStatus = {'status': 'approved', 'message': 'Your seller request has been approved!'};
      });
      return;
    }
  }

  Future<void> _submitSellerRequest() async {
    setState(() => _isLoading = true);

    try {
      await _sellerRequestService.submitSellerRequest(
        userId: _userManager.userId ?? '',
        userName: _userManager.name,
        userEmail: _userManager.email,
        userPhone: _userManager.phone,
      );

      if (!mounted) return;

      setState(() {
        _hasActiveRequest = true;
        _requestStatus = {'status': 'pending', 'message': 'Your seller request has been submitted!'};
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seller request submitted successfully! Admin will review it shortly.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting request: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Become a Seller',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
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
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.store,
                      color: AppColors.primary,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Start Selling on Campus Cart',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reach thousands of students and earn money by selling your products',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.text.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Status Section (if has active request)
              if (_hasActiveRequest && _requestStatus != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _requestStatus!['status'] == 'pending'
                        ? Colors.orange.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _requestStatus!['status'] == 'pending'
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _requestStatus!['status'] == 'pending'
                            ? Icons.hourglass_empty
                            : Icons.check_circle,
                        color: _requestStatus!['status'] == 'pending'
                            ? Colors.orange
                            : Colors.green,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _requestStatus!['status'] == 'pending'
                                  ? 'Request Pending'
                                  : 'Request Approved',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _requestStatus!['status'] == 'pending'
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _requestStatus!['message'],
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.text.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Benefits Section
              const Text(
                'Why Become a Seller?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
              _buildBenefitItem(Icons.trending_up, 'Reach a Wide Audience', 'Connect with thousands of potential customers'),
              _buildBenefitItem(Icons.wallet, 'Earn Money', 'Keep a portion of every sale you make'),
              _buildBenefitItem(Icons.support_agent, 'Dedicated Support', 'Get help from our support team anytime'),
              _buildBenefitItem(Icons.analytics, 'Analytics Dashboard', 'Track sales, orders, and performance'),

              const SizedBox(height: 32),

              // Application Section (only if no active request)
              if (!_hasActiveRequest) ...[
                const Text(
                  'Ready to Get Started?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Once your application is approved by our admin team, you\'ll be able to create your store and add products. This typically takes 24-48 hours.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.text,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Terms and conditions
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'By clicking "Submit Application", you agree to our seller agreement and acknowledge that your application will be reviewed by our admin team.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.text,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitSellerRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                            ),
                          )
                        : const Text(
                            'Submit Application',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
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
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.text.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
