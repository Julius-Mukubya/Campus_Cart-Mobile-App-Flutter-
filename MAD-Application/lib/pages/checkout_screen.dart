import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/cart_manager.dart';
import 'package:madpractical/services/order_manager.dart';
import 'package:madpractical/services/firebase_auth_service.dart';
import 'package:madpractical/services/user_manager.dart';
import 'package:madpractical/pages/order_success.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CartManager _cartManager = CartManager();
  final OrderManager _orderManager = OrderManager();
  final PageController _pageController = PageController();

  int _currentStep = 0; // 0=Address, 1=Payment, 2=Review

  // Step 1 – Address
  final _nameController    = TextEditingController();
  final _phoneController   = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController    = TextEditingController();

  // Saved addresses from Firebase
  List<Map<String, dynamic>> _savedAddresses = [];
  String? _selectedAddressId;
  bool _loadingAddresses = true;
  // Step 2 – Payment
  String _paymentMethod = 'mtn';
  final _paymentFormKey = GlobalKey<FormState>();

  // Payment detail controllers
  final _momoPhoneController  = TextEditingController(); // MTN / Airtel
  final _cardNumberController = TextEditingController(); // Visa
  final _cardNameController   = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController    = TextEditingController();

  static const double _deliveryFee = 5000;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'mtn',
      'name': 'MTN Mobile Money',
      'subtitle': 'Pay with MTN MoMo',
      'logoUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/New-mtn-logo.jpg/320px-New-mtn-logo.jpg',
      'color': const Color(0xFFFFCC00),
    },
    {
      'id': 'airtel',
      'name': 'Airtel Money',
      'subtitle': 'Pay with Airtel Money',
      'logoUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/Airtel_logo_2010.svg/320px-Airtel_logo_2010.svg.png',
      'color': const Color(0xFFE40000),
    },
    {
      'id': 'visa',
      'name': 'Bank / Visa Card',
      'subtitle': 'Credit or Debit card',
      'logoUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Visa_Inc._logo.svg/320px-Visa_Inc._logo.svg.png',
      'color': const Color(0xFF1A1F71),
    },
  ];

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
    _momoPhoneController.dispose();
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  double get _total => _cartManager.subtotal + _deliveryFee;

  String get _paymentLabel =>
      _paymentMethods.firstWhere((m) => m['id'] == _paymentMethod)['name'];

  String get _paymentDetail {
    if (_paymentMethod == 'visa') {
      final num = _cardNumberController.text;
      return num.length >= 4 ? '**** **** **** ${num.substring(num.length - 4)}' : '';
    }
    return _momoPhoneController.text;
  }

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
    if (_currentStep == 1 && !_paymentFormKey.currentState!.validate()) return;
    if (_currentStep < 2) _goTo(_currentStep + 1);
  }

  void _placeOrder() {
    final subtotal = _cartManager.subtotal;
    final now = DateTime.now();
    final orderId = 'ORD-${now.year}-${now.millisecondsSinceEpoch.toString().substring(7)}';

    final order = {
      'id': orderId,
      'date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      'status': 'Processing',
      'total': _total,
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
      'paymentMethod': _paymentLabel,
      'subtotal': subtotal,
      'deliveryFee': _deliveryFee,
    };

    _orderManager.addOrder(order);
    _cartManager.clearCart();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderSuccess(
          subtotal: subtotal,
          deliveryFee: _deliveryFee,
          total: _total,
          deliveryMethod: 'Standard (3–5 days)',
          shippingAddress: '${_addressController.text}, ${_cityController.text}',
          paymentMethod: _paymentLabel,
        ),
      ),
    );
  }

  // ─── Stepper ─────────────────────────────────────────────────────────────────
  Widget _buildStepper() {
    const steps = ['Address', 'Payment', 'Review'];
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
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                    SizedBox(width: 8),
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
                      style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
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
                    const Text('New Address',
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
                        const Text('Set as default address',
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
  Widget _buildPaymentStep() {
    final isMomo = _paymentMethod == 'mtn' || _paymentMethod == 'airtel';
    final isVisa = _paymentMethod == 'visa';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _paymentFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Payment Method', Icons.payment_outlined),
            const SizedBox(height: 20),

            // Method selector cards
            ..._paymentMethods.map((method) {
              final selected = _paymentMethod == method['id'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _paymentMethod = method['id']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.lightGrey,
                        width: selected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: selected
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.black.withValues(alpha: 0.04),
                          blurRadius: 10, offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60, height: 40,
                          decoration: BoxDecoration(
                            color: (method['color'] as Color).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: (method['color'] as Color).withValues(alpha: 0.3)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Image.network(method['logoUrl'],
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    Icon(Icons.payment, color: method['color'] as Color)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(method['name'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14,
                                      color: selected ? AppColors.primary : AppColors.text)),
                              Text(method['subtitle'],
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.secondaryText)),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected ? AppColors.primary : Colors.transparent,
                            border: Border.all(
                                color: selected ? AppColors.primary : AppColors.grey,
                                width: 2),
                          ),
                          child: selected
                              ? const Icon(Icons.check, color: Colors.white, size: 13)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),

            // ── Payment detail fields ──────────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isMomo
                  ? _momoFields()
                  : isVisa
                      ? _visaFields()
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _momoFields() {
    final label = _paymentMethod == 'mtn' ? 'MTN MoMo Number' : 'Airtel Money Number';
    return Column(
      key: ValueKey(_paymentMethod),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Mobile Money Details', Icons.phone_android),
        const SizedBox(height: 16),
        _inputField(_momoPhoneController, label, Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter your mobile money number';
              if (v.length < 10) return 'Enter a valid phone number';
              return null;
            }),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You will receive a payment prompt on this number to confirm.',
                  style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _visaFields() {
    return Column(
      key: const ValueKey('visa'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Card Details', Icons.credit_card),
        const SizedBox(height: 16),
        _inputField(_cardNumberController, 'Card Number', Icons.credit_card,
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter card number';
              if (v.replaceAll(' ', '').length < 16) return 'Enter a valid 16-digit card number';
              return null;
            }),
        const SizedBox(height: 16),
        _inputField(_cardNameController, 'Cardholder Name', Icons.person_outline,
            validator: (v) => v == null || v.isEmpty ? 'Enter cardholder name' : null),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _inputField(_cardExpiryController, 'MM / YY', Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Enter expiry' : null),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _inputField(_cardCvvController, 'CVV', Icons.lock_outline,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter CVV';
                    if (v.length < 3) return 'Invalid CVV';
                    return null;
                  }),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_outline, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your card details are encrypted and secure.',
                  style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
                                style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
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
                    style: const TextStyle(fontSize: 13, color: AppColors.secondaryText)),
                const SizedBox(height: 4),
                Text('${_addressController.text}, ${_cityController.text}',
                    style: const TextStyle(fontSize: 13, color: AppColors.secondaryText)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Payment
          _reviewCard(
            title: 'Payment',
            icon: Icons.payment_outlined,
            child: Column(
              children: [
                _reviewRow('Method', _paymentLabel),
                if (_paymentDetail.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _reviewRow(
                    _paymentMethod == 'visa' ? 'Card' : 'Number',
                    _paymentDetail,
                  ),
                ],
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
                const SizedBox(height: 8),
                _reviewRow('Delivery Fee', 'UGX ${_deliveryFee.toStringAsFixed(0)}'),
                const Divider(height: 20),
                _reviewRow('Total', 'UGX ${_total.toStringAsFixed(0)}', bold: true),
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
                style: const TextStyle(
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
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
      ],
    );
  }

  Widget _inputField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
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
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    const stepLabels = ['Address', 'Payment', 'Review'];
    final isLastStep = _currentStep == 2;

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
            child: const Icon(Icons.arrow_back_ios, color: AppColors.text, size: 16),
          ),
        ),
        title: Text(stepLabels[_currentStep],
            style: const TextStyle(
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
                _buildPaymentStep(),
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
                    const Text('Total',
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
