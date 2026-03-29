import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/cart_manager.dart';
import 'package:madpractical/services/order_manager.dart';
import 'package:madpractical/services/firebase_auth_service.dart';
import 'package:madpractical/services/user_manager.dart';
import 'package:madpractical/pages/order_success.dart';
import 'select_address_screen.dart';
import 'select_payment_screen.dart';

class PlaceOrderScreen extends StatefulWidget {
  const PlaceOrderScreen({super.key});

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  final CartManager _cart = CartManager();
  final OrderManager _orderManager = OrderManager();
  final FirebaseAuthService _authService = FirebaseAuthService();
  final UserManager _userManager = UserManager();
  final _promoCtrl = TextEditingController();

  static const double _deliveryFee = 5000;
  Map<String, dynamic>? _selectedAddress;
  String _paymentMethod = 'pod';
  Map<String, dynamic> _paymentDetails = {};

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  Future<void> _loadDefaultAddress() async {
    final uid = _userManager.userId ?? _authService.currentUser?.uid;
    if (uid == null) return;
    final addresses = await _authService.getUserAddresses(uid);
    final valid = addresses.where((a) {
      final line1 = (a['addressLine1'] ?? '').toString().trim();
      final name  = (a['fullName'] ?? '').toString().trim();
      return line1.isNotEmpty || name.isNotEmpty;
    }).toList();
    if (valid.isEmpty) return;
    final def = valid.firstWhere(
      (a) => a['isDefault'] == true,
      orElse: () => valid.first,
    );
    if (mounted) setState(() => _selectedAddress = def);
  }

  @override
  void dispose() { _promoCtrl.dispose(); super.dispose(); }

  String get _paymentLabel {
    switch (_paymentMethod) {
      case 'mtn':    return 'Pay now with MTN Money';
      case 'airtel': return 'Pay now with Airtel Money';
      case 'visa':   return 'Pay now with Bank cards';
      default:       return 'Pay on Delivery (Mobile Money and Bank Cards)';
    }
  }

  Future<void> _changeAddress() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context, MaterialPageRoute(builder: (_) => const SelectAddressScreen()));
    if (result != null) setState(() => _selectedAddress = result);
  }

  Future<void> _changePayment() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context, MaterialPageRoute(builder: (_) => const SelectPaymentScreen()));
    if (result != null) {
      setState(() {
        _paymentMethod = result['method'] as String;
        _paymentDetails = result['details'] as Map<String, dynamic>? ?? {};
      });
    }
  }

  void _confirmOrder() {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a delivery address'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    final subtotal = _cart.subtotal;
    final total = subtotal + _deliveryFee;
    final now = DateTime.now();
    final orderId = 'ORD-${now.year}-${now.millisecondsSinceEpoch.toString().substring(7)}';
    final address = '${_selectedAddress!['fullName']}, ${_selectedAddress!['addressLine1']}, ${_selectedAddress!['city']}';

    _orderManager.addOrder({
      'id': orderId,
      'date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      'status': 'Processing',
      'total': total,
      'items': _cart.itemCount,
      'products': List<Map<String, dynamic>>.from(_cart.cartItems.map((item) => {
        'name': item['name'], 'quantity': item['quantity'],
        'price': item['price'], 'image': item['image'] ?? '',
      })),
      'shippingAddress': address,
      'paymentMethod': _paymentLabel,
      'subtotal': subtotal,
      'deliveryFee': _deliveryFee,
    });

    _cart.clearCart();
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => OrderSuccess(
        subtotal: subtotal, deliveryFee: _deliveryFee, total: total,
        deliveryMethod: 'Standard (3–5 days)',
        shippingAddress: address, paymentMethod: _paymentLabel,
      ),
    ));
  }

  Widget _sectionHeader(String title, {String? action, VoidCallback? onAction}) => Container(
    color: AppColors.secondary,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(
        child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText, letterSpacing: 0.4)),
      ),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Text(action, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ),
    ]),
  );

  Widget _summaryRow(String l, String v, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: TextStyle(fontSize: 14, color: bold ? AppColors.text : AppColors.secondaryText, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      Text(v, style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.bold : FontWeight.w500, color: AppColors.text)),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final subtotal = _cart.subtotal;
    final total = subtotal + _deliveryFee;

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.white, elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.text, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Place your order', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: ListView(children: [
        // Terms
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: RichText(text: TextSpan(
            style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
            children: [
              const TextSpan(text: 'If you proceed, you are automatically accepting our '),
              TextSpan(text: 'Terms & Conditions', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
            ],
          )),
        ),
        const SizedBox(height: 8),

        // Order summary
        _sectionHeader('Order summary'),
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(children: [
            _summaryRow("Item's total (${_cart.itemCount})", 'UGX ${subtotal.toStringAsFixed(0)}'),
            _summaryRow('Delivery fees', 'UGX ${_deliveryFee.toStringAsFixed(0)}'),
            const Divider(height: 20, color: AppColors.lightGrey),
            _summaryRow('Total', 'UGX ${total.toStringAsFixed(0)}', bold: true),
          ]),
        ),

        // Promo
        Container(
          color: AppColors.white, margin: const EdgeInsets.only(top: 1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            Icon(Icons.confirmation_number_outlined, color: AppColors.primary.withValues(alpha: 0.7), size: 20),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: _promoCtrl, decoration: const InputDecoration(hintText: 'Enter promo code', hintStyle: TextStyle(color: AppColors.grey, fontSize: 14), border: InputBorder.none, isDense: true))),
            TextButton(onPressed: () {}, child: const Text('Apply', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
          ]),
        ),
        const SizedBox(height: 8),

        // Payment method
        _sectionHeader('Payment Method', action: 'Change', onAction: _changePayment),
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.payment, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_paymentLabel, style: const TextStyle(fontSize: 14, color: AppColors.text)),
                if (_paymentDetails['number'] != null && (_paymentDetails['number'] as String).isNotEmpty)
                  Text(_paymentDetails['number'], style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                if (_paymentDetails['cardNumber'] != null && (_paymentDetails['cardNumber'] as String).isNotEmpty)
                  Text('**** **** **** ${(_paymentDetails['cardNumber'] as String).replaceAll(' ', '').substring((_paymentDetails['cardNumber'] as String).replaceAll(' ', '').length.clamp(4, 999) - 4)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
              ],
            )),
          ]),
        ),
        const SizedBox(height: 8),

        // Address
        _sectionHeader('Address', action: 'Change Your Address', onAction: _changeAddress),
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: _selectedAddress == null
              ? GestureDetector(
                  onTap: _changeAddress,
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.add_location_alt_outlined, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Tap to select a delivery address',
                          style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w500)),
                    ),
                  ]),
                )
              : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_selectedAddress!['fullName'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                    const SizedBox(height: 2),
                    Text(_selectedAddress!['addressLine1'] ?? '', style: const TextStyle(fontSize: 13, color: AppColors.secondaryText)),
                    if ((_selectedAddress!['city'] ?? '').isNotEmpty)
                      Text(_selectedAddress!['city'], style: const TextStyle(fontSize: 13, color: AppColors.secondaryText)),
                  ])),
                ]),
        ),
        const SizedBox(height: 80),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(height: 52, child: ElevatedButton(
            onPressed: _confirmOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Confirm Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )),
        ),
      ),
    );
  }
}
