import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/managers/cart_manager.dart';
import 'package:madpractical/services/managers/order_manager.dart';
import 'package:madpractical/services/auth/firebase_auth_service.dart';
import 'package:madpractical/services/managers/user_manager.dart';
import 'package:madpractical/pages/customer/order_success.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CartManager _cartManager = CartManager();
  final OrderManager _orderManager = OrderManager();
  final PageController _pageController = PageController();

  int _currentStep = 0; // 0=Address, 1=Review

  // Step 1 – Address
  final _nameController    = TextEditingController();
  final _phoneController   = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController    = TextEditingController();

  // Saved addresses from Firebase
  List<Map<String, dynamic>> _savedAddresses = [];
  String? _selectedAddressId;
  bool _loadingAddresses = true;

  final FirebaseAuthService _authService = FirebaseAuthService();
  final UserManager _userManager = UserManager();

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
  }

  Future<void> _loadSavedAddresses() async {
    final uid = _userManager.userId ?? _authService.currentUser?.uid;
    if (uid == null) {
      setState(() => _loadingAddresses = false);
      return;
    }
    final addresses = await _authService.getUserAddresses(uid);
    setState(() {
      _savedAddresses = addresses;
      _loadingAddresses = false;
    });
    // Auto-select default address and prefill
    final defaultAddr = addresses.firstWhere(
      (a) => a['isDefault'] == true,
      orElse: () => addresses.isNotEmpty ? addresses.first : <String, dynamic>{},
    );
    if (defaultAddr.isNotEmpty) {
      _selectAddress(defaultAddr);
    }
  }

  void _selectAddress(Map<String, dynamic> addr) {
    setState(() => _selectedAddressId = addr['addressId']);
    _nameController.text    = addr['fullName'] ?? '';
    _phoneController.text   = addr['phone'] ?? '';
    _addressController.text = addr['addressLine1'] ?? '';
    _cityController.text    = addr['city'] ?? '';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  double get _total => _cartManager.subtotal;

  void _goTo(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(step,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_selectedAddressId == null) {
        setState(() {}); // triggers the hint text
        return;
      }
    }
    if (_currentStep < 1) _goTo(_currentStep + 1);
  }

  void _placeOrder() async {
    final subtotal = _cartManager.subtotal;
    final now = DateTime.now();
    final orderId = 'ORD-${now.year}-${now.millisecondsSinceEpoch.toString().substring(7)}';

    final order = {
      'id': orderId,
      'date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      'status': 'Pending',
      'total': subtotal,
      'items': _cartManager.itemCount,
      'products': List<Map<String, dynamic>>.from(
        _cartManager.cartItems.map((item) => {
          'name': item['name'],
          'quantity': item['quantity'],
          'price': item['price'],
          'image': item['image'] ?? '',
        }),
      ),
      'shippingAddress': '${_addressController.text}, ${_cityController.text}',
      'customerName': _nameController.text,
      'customerPhone': _phoneController.text,
      'subtotal': subtotal,
    };

    await _orderManager.addOrder(order);
    _cartManager.clearCart();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccess(
            subtotal: subtotal,
            deliveryFee: 0,
            total: subtotal,
            deliveryMethod: 'Standard',
            shippingAddress: '${_addressController.text}, ${_cityController.text}',
            paymentMethod: 'To be arranged',
          ),
        ),
      );
    }
  }

  // ─── Stepper ─────────────────────────────────────────────────────────────────
  Widget _buildStepper() {
    const steps = ['Address', 'Review'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIndex = i ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                color: stepIndex < _currentStep ? AppColors.primary : AppColors.lightGrey,
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final done   = stepIndex < _currentStep;
          final active = stepIndex == _currentStep;
          return GestureDetector(
            onTap: () { if (done) _goTo(stepIndex); },
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done || active ? AppColors.primary : AppColors.white,
                    border: Border.all(
                      color: done || active ? AppColors.primary : AppColors.lightGrey,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: done
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text('${stepIndex + 1}',
                            style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold,
                              color: active ? Colors.white : AppColors.grey,
                            )),
                  ),
                ),
                const SizedBox(height: 4),
                Text(steps[stepIndex],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                      color: active ? AppColors.primary : AppColors.secondaryText,
                    )),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ─── Step 1: Address ─────────────────────────────────────────────────────────
  Widget _buildAddressStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Delivery Address', Icons.location_on_outlined),
          const SizedBox(height: 20),

          // Loading
          if (_loadingAddresses)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 2,
                ),
              ),
            )
          else ...[
            // Saved address cards
            if (_savedAddresses.isNotEmpty) ...[
              ..._savedAddresses.map((addr) => _buildAddressCard(addr)),
              const SizedBox(height: 4),
            ] else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('No saved addresses yet. Add one below.',
                        style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // Add new address button
            GestureDetector(
              onTap: _showAddAddressSheet,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      width: 1.5,
                      style: BorderStyle.solid),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3)),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_location_alt_outlined,
                        color: AppColors.primary, size: 20),
                    SizedBox(width: 10),
                    Text('Add New Address',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                  ],
                ),
              ),
            ),

            // Validation hint when nothing selected
            if (_selectedAddressId == null && !_loadingAddresses) ...[
              const SizedBox(height: 10),
              const Text('Please select or add a delivery address to continue.',
                  style: TextStyle(fontSize: 12, color: AppColors.error)),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> addr) {
    final isSelected = _selectedAddressId == addr['addressId'];
    final label     = addr['label']?.toString().isNotEmpty == true ? addr['label'] : 'Address';
    final line1     = addr['addressLine1'] ?? '';
    final city      = addr['city'] ?? '';
    final isDefault = addr['isDefault'] == true;

    return GestureDetector(
      onTap: () => _selectAddress(addr),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGrey,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isSelected ? AppColors.primary : AppColors.grey)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.location_on,
                  size: 18,
                  color: isSelected ? AppColors.primary : AppColors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(label,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isSelected ? AppColors.primary : AppColors.text)),
                      if (isDefault) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Default',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                  if (line1.isNotEmpty || city.isNotEmpty)
                    Text(
                      [line1, city].where((s) => s.isNotEmpty).join(', '),
                      style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.grey, width: 2),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Add address bottom sheet ─────────────────────────────────────────────────
  void _showAddAddressSheet() {
    final labelCtrl   = TextEditingController();
    final nameCtrl    = TextEditingController();
    final phoneCtrl   = TextEditingController();
    final line1Ctrl   = TextEditingController();
    final cityCtrl    = TextEditingController();
    final formKey     = GlobalKey<FormState>();
    bool setAsDefault = _savedAddresses.isEmpty; // default if first address
    bool saving       = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text('New Address',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text)),
                    const SizedBox(height: 20),

                    _sheetField(labelCtrl, 'Label (e.g. Home, Office)', Icons.label_outline),
                    const SizedBox(height: 14),
                    _sheetField(nameCtrl, 'Full Name', Icons.person_outline,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                    const SizedBox(height: 14),
                    _sheetField(phoneCtrl, 'Phone Number', Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                    const SizedBox(height: 14),
                    _sheetField(line1Ctrl, 'Street Address', Icons.home_outlined,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                    const SizedBox(height: 14),
                    _sheetField(cityCtrl, 'City / District', Icons.location_city,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                    const SizedBox(height: 14),

                    // Set as default toggle
                    Row(
                      children: [
                        Switch(
                          value: setAsDefault,
                          onChanged: (v) => setSheet(() => setAsDefault = v),
                          activeColor: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text('Set as default address',
                            style: TextStyle(fontSize: 14, color: AppColors.text)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: saving
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setSheet(() => saving = true);

                                final uid = _userManager.userId ??
                                    _authService.currentUser?.uid;

                                if (uid != null) {
                                  await _authService.addUserAddress(
                                    userId: uid,
                                    label: labelCtrl.text.trim().isNotEmpty
                                        ? labelCtrl.text.trim()
                                        : 'Address',
                                    fullName: nameCtrl.text.trim(),
                                    phone: phoneCtrl.text.trim(),
                                    addressLine1: line1Ctrl.text.trim(),
                                    city: cityCtrl.text.trim(),
                                    state: '',
                                    postalCode: '',
                                    isDefault: setAsDefault,
                                  );
                                }

                                // Build the new address map locally so it
                                // appears instantly without a full reload
                                final newAddr = {
                                  'addressId': DateTime.now().millisecondsSinceEpoch.toString(),
                                  'label': labelCtrl.text.trim().isNotEmpty
                                      ? labelCtrl.text.trim()
                                      : 'Address',
                                  'fullName': nameCtrl.text.trim(),
                                  'phone': phoneCtrl.text.trim(),
                                  'addressLine1': line1Ctrl.text.trim(),
                                  'city': cityCtrl.text.trim(),
                                  'isDefault': setAsDefault,
                                };

                                setState(() {
                                  if (setAsDefault) {
                                    for (final a in _savedAddresses) {
                                      a['isDefault'] = false;
                                    }
                                  }
                                  _savedAddresses.add(newAddr);
                                });
                                _selectAddress(newAddr);

                                if (ctx.mounted) Navigator.pop(ctx);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: saving
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Save Address',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.lightGrey)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.lightGrey)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  // ─── Step 2: Payment ─────────────────────────────────────────────────────────
  // REMOVED: Payment step no longer needed for simplified checkout


  // ─── Step 3: Review ───────────────────────────────────────────────────────────
  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Order Review', Icons.receipt_long_outlined),
          const SizedBox(height: 20),

          // Items
          _reviewCard(
            title: 'Items (${_cartManager.itemCount})',
            icon: Icons.shopping_bag_outlined,
            child: Column(
              children: _cartManager.cartItems.map((item) {
                final price = double.tryParse(
                    item['price'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                final qty = item['quantity'] ?? 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(item['image'] ?? '',
                            width: 48, height: 48, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 48, height: 48, color: AppColors.lightGrey,
                              child: const Icon(Icons.image_outlined, color: AppColors.grey),
                            )),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['name'],
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text('Qty: $qty',
                                style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                          ],
                        ),
                      ),
                      Text('UGX ${(price * qty).toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Address
          _reviewCard(
            title: 'Delivery Address',
            icon: Icons.location_on_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_nameController.text,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(_phoneController.text,
                    style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
                const SizedBox(height: 4),
                Text('${_addressController.text}, ${_cityController.text}',
                    style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Price
          _reviewCard(
            title: 'Price Summary',
            icon: Icons.receipt_outlined,
            child: Column(
              children: [
                _reviewRow('Subtotal', 'UGX ${_cartManager.subtotal.toStringAsFixed(0)}'),
                const Divider(height: 20),
                _reviewRow('Total', 'UGX ${_cartManager.subtotal.toStringAsFixed(0)}', bold: true),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ─── Shared helpers ───────────────────────────────────────────────────────────
  Widget _reviewCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.text)),
          ]),
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: bold ? AppColors.text : AppColors.secondaryText,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                color: bold ? AppColors.primary : AppColors.text)),
      ],
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(title,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
      ],
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    const stepLabels = ['Address', 'Review'];
    final isLastStep = _currentStep == 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () => _currentStep > 0 ? _goTo(_currentStep - 1) : Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: AppColors.black.withValues(alpha: 0.08),
                    blurRadius: 6, offset: const Offset(0, 2))
              ],
            ),
            child: Icon(Icons.arrow_back_ios, color: AppColors.text, size: 16),
          ),
        ),
        title: Text(stepLabels[_currentStep],
            style: TextStyle(
                color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: Column(
        children: [
          _buildStepper(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildAddressStep(),
                _buildReviewStep(),
              ],
            ),
          ),
          // Bottom bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(color: AppColors.black.withValues(alpha: 0.06),
                    blurRadius: 12, offset: const Offset(0, -4))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total',
                        style: TextStyle(fontSize: 14, color: AppColors.secondaryText)),
                    Text('UGX ${_total.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLastStep ? _placeOrder : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isLastStep ? Icons.check_circle_outline : Icons.arrow_forward,
                            size: 20),
                        const SizedBox(width: 8),
                        Text(isLastStep ? 'Place Order' : 'Continue',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
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


