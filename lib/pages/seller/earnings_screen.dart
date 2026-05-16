import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/seller_service.dart';
import 'package:madpractical/services/user_manager.dart';
import 'package:madpractical/services/firebase_auth_service.dart';
import 'package:madpractical/widgets/notification_icon.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  final SellerService _sellerService = SellerService();
  final UserManager _userManager = UserManager();
  final FirebaseAuthService _authService = FirebaseAuthService();

  bool _isLoading = true;
  double _totalEarnings = 0;
  double _totalPayouts = 0;
  double _availableBalance = 0;
  List<Map<String, dynamic>> _payouts = [];

  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  Future<void> _loadEarnings() async {
    setState(() => _isLoading = true);
    final uid = _userManager.userId ?? _authService.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }
    final data = await _sellerService.getSellerEarnings(uid);
    setState(() {
      _totalEarnings = (data['totalEarnings'] ?? 0).toDouble();
      _totalPayouts = (data['totalPayouts'] ?? 0).toDouble();
      _availableBalance = (data['availableBalance'] ?? 0).toDouble();
      _payouts = List<Map<String, dynamic>>.from(data['payouts'] ?? []);
      _isLoading = false;
    });
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) return 'UGX ${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return 'UGX ${(amount / 1000).toStringAsFixed(0)}K';
    return 'UGX ${amount.toStringAsFixed(0)}';
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = timestamp.toDate();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return timestamp.toString();
    }
  }

  void _requestPayout() {
    final _amountCtrl = TextEditingController();
    final _accountCtrl = TextEditingController();
    final _nameCtrl = TextEditingController();
    String _method = 'Mobile Money';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4,
                    decoration: BoxDecoration(color: AppColors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                const Text('Request Payout', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text)),
                const SizedBox(height: 4),
                Text('Available: ${_formatAmount(_availableBalance)}',
                    style: TextStyle(fontSize: 14, color: AppColors.secondaryText)),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _method,
                  decoration: InputDecoration(labelText: 'Payout Method',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  items: ['Mobile Money', 'Bank Transfer']
                      .map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) => setModal(() => _method = v!),
                ),
                const SizedBox(height: 12),
                TextField(controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Amount (UGX)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 12),
                TextField(controller: _accountCtrl,
                    decoration: InputDecoration(labelText: 'Account Number / Phone',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 12),
                TextField(controller: _nameCtrl,
                    decoration: InputDecoration(labelText: 'Account Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
                      if (amount <= 0 || _accountCtrl.text.isEmpty || _nameCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill all fields'), backgroundColor: AppColors.error));
                        return;
                      }
                      final uid = _userManager.userId ?? _authService.currentUser?.uid ?? '';
                      Navigator.pop(ctx);
                      final result = await _sellerService.requestPayout(
                        sellerId: uid, amount: amount, method: _method,
                        accountNumber: _accountCtrl.text.trim(), accountName: _nameCtrl.text.trim(),
                      );
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(result['message']),
                        backgroundColor: result['success'] ? AppColors.success : AppColors.error,
                        behavior: SnackBarBehavior.floating,
                      ));
                      if (result['success']) _loadEarnings();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
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
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 2))]),
            child: const Icon(Icons.arrow_back_ios, color: AppColors.text, size: 16),
          ),
        ),
        title: const Text('Earnings & Payouts', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          IconButton(onPressed: _loadEarnings, icon: const Icon(Icons.refresh, color: AppColors.text)),
          const NotificationIcon(),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primary)))
          : RefreshIndicator(
              onRefresh: _loadEarnings,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text('Available Balance', style: TextStyle(fontSize: 16, color: AppColors.white, fontWeight: FontWeight.w500)),
                          Container(padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.account_balance_wallet, color: AppColors.white, size: 20)),
                        ]),
                        const SizedBox(height: 16),
                        Text(_formatAmount(_availableBalance),
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.white)),
                        const SizedBox(height: 4),
                        const Text('From delivered orders minus payouts',
                            style: TextStyle(fontSize: 12, color: AppColors.white)),
                      ]),
                    ),

                    const SizedBox(height: 20),

                    // Stats row
                    Row(children: [
                      Expanded(child: _statCard('Total Earnings', _formatAmount(_totalEarnings), Icons.trending_up, AppColors.success)),
                      const SizedBox(width: 16),
                      Expanded(child: _statCard('Total Payouts', _formatAmount(_totalPayouts), Icons.payment, AppColors.accent)),
                    ]),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _availableBalance > 0 ? _requestPayout : null,
                        icon: const Icon(Icons.payment),
                        label: const Text('Request Payout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary, foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Text('Payout History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text)),
                    const SizedBox(height: 16),

                    if (_payouts.isEmpty)
                      Center(child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(children: [
                          const Icon(Icons.history, size: 48, color: AppColors.grey),
                          const SizedBox(height: 12),
                          const Text('No payouts yet', style: TextStyle(fontSize: 16, color: AppColors.secondaryText)),
                        ]),
                      ))
                    else
                      ..._payouts.map((p) => _payoutItem(p)),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24)),
        const SizedBox(height: 12),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text)),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
      ]),
    );
  }

  Widget _payoutItem(Map<String, dynamic> payout) {
    final isCompleted = (payout['status'] ?? '').toString().toLowerCase() == 'completed';
    final isPending = (payout['status'] ?? '').toString().toLowerCase() == 'pending';
    final color = isCompleted ? AppColors.success : isPending ? AppColors.accent : AppColors.grey;
    final amount = (payout['amount'] ?? 0).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5))),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(isCompleted ? Icons.check_circle : Icons.schedule, color: color, size: 20)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_formatAmount(amount), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text)),
          const SizedBox(height: 4),
          Text('${payout['method'] ?? 'Mobile Money'} • ${_formatDate(payout['createdAt'])}',
              style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(
            (payout['status'] ?? 'pending').toString()[0].toUpperCase() +
                (payout['status'] ?? 'pending').toString().substring(1),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ),
      ]),
    );
  }
}
