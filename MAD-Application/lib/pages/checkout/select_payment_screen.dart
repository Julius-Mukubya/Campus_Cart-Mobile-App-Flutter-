import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/cart_manager.dart';

class SelectPaymentScreen extends StatefulWidget {
  const SelectPaymentScreen({super.key});

  @override
  State<SelectPaymentScreen> createState() => _SelectPaymentScreenState();
}

class _SelectPaymentScreenState extends State<SelectPaymentScreen> {
  final CartManager _cart = CartManager();
  final _promoCtrl = TextEditingController();
  static const double _deliveryFee = 5000;

  String _selected = 'pod';

  // Mobile money details
  final _momoNumberCtrl = TextEditingController();
  final _momoNameCtrl   = TextEditingController();

  // Card details
  final _cardNumberCtrl  = TextEditingController();
  final _cardNameCtrl    = TextEditingController();
  final _cardExpiryCtrl  = TextEditingController();
  final _cardCvvCtrl     = TextEditingController();

  final _detailsFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _promoCtrl.dispose();
    _momoNumberCtrl.dispose();
    _momoNameCtrl.dispose();
    _cardNumberCtrl.dispose();
    _cardNameCtrl.dispose();
    _cardExpiryCtrl.dispose();
    _cardCvvCtrl.dispose();
    super.dispose();
  }

  // ── helpers ──────────────────────────────────────────────────────────────────
  bool get _isMomo => _selected == 'mtn' || _selected == 'airtel';
  bool get _isCard => _selected == 'visa';
  bool get _isPod  => _selected == 'pod';

  String get _momoProviderName =>
      _selected == 'mtn' ? 'MTN MoMo' : 'Airtel Money';

  Widget _sectionLabel(String t) => Container(
        color: AppColors.secondary,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(t,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryText)),
      );

  Widget _summaryRow(String l, String v, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l,
                style: TextStyle(
                    fontSize: 14,
                    color: bold ? AppColors.text : AppColors.secondaryText,
                    fontWeight:
                        bold ? FontWeight.bold : FontWeight.normal)),
            Text(v,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                    color: AppColors.text)),
          ],
        ),
      );

  Widget _inputField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
    bool obscure = false,
    int? maxLength,
  }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        validator: validator,
        obscureText: obscure,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(fontSize: 13, color: AppColors.secondaryText),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.lightGrey)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.lightGrey)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error)),
          filled: true,
          fillColor: AppColors.white,
          counterText: '',
        ),
      );

  // ── Payment tile ──────────────────────────────────────────────────────────────
  Widget _paymentTile(String id, String label, String logoUrl) {
    final sel = _selected == id;
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _selected = id),
          child: Container(
            color: AppColors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              _radio(id),
              const SizedBox(width: 4),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        color: sel ? AppColors.primary : AppColors.text,
                        fontWeight:
                            sel ? FontWeight.w600 : FontWeight.normal)),
              ),
              Container(
                width: 52,
                height: 32,
                decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.all(4),
                child: Image.network(logoUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.payment, color: AppColors.grey)),
              ),
            ]),
          ),
        ),

        // ── Inline detail fields when this method is selected ────────────────
        if (sel && (id == 'mtn' || id == 'airtel'))
          _momoDetailsPanel(),
        if (sel && id == 'visa')
          _cardDetailsPanel(),
      ],
    );
  }

  Widget _radio(String id) => SizedBox(
        width: 24,
        height: 24,
        child: Radio<String>(
          value: id,
          groupValue: _selected,
          activeColor: AppColors.primary,
          onChanged: (v) => setState(() => _selected = v!),
        ),
      );

  // ── Mobile money detail panel ─────────────────────────────────────────────────
  Widget _momoDetailsPanel() => Container(
        color: AppColors.white,
        padding:
            const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Form(
          key: _detailsFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Enter your $_momoProviderName number to receive the payment prompt.',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.secondaryText),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              _inputField(
                _momoNumberCtrl,
                '$_momoProviderName Number',
                Icons.phone_outlined,
                keyboard: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter your number';
                  if (v.replaceAll(RegExp(r'\D'), '').length < 9)
                    return 'Enter a valid phone number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _inputField(
                _momoNameCtrl,
                'Account Name',
                Icons.person_outline,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter account name' : null,
              ),
            ],
          ),
        ),
      );

  // ── Card detail panel ─────────────────────────────────────────────────────────
  Widget _cardDetailsPanel() => Container(
        color: AppColors.white,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Form(
          key: _detailsFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(children: [
                  Icon(Icons.lock_outline,
                      size: 16, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your card details are encrypted and secure.',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.secondaryText),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              _inputField(
                _cardNumberCtrl,
                'Card Number',
                Icons.credit_card,
                keyboard: TextInputType.number,
                maxLength: 19,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter card number';
                  if (v.replaceAll(' ', '').length < 16)
                    return 'Enter a valid 16-digit card number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _inputField(
                _cardNameCtrl,
                'Cardholder Name',
                Icons.person_outline,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter cardholder name' : null,
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: _inputField(
                    _cardExpiryCtrl,
                    'MM / YY',
                    Icons.calendar_today,
                    keyboard: TextInputType.number,
                    maxLength: 5,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter expiry' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _inputField(
                    _cardCvvCtrl,
                    'CVV',
                    Icons.lock_outline,
                    keyboard: TextInputType.number,
                    maxLength: 3,
                    obscure: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter CVV';
                      if (v.length < 3) return 'Invalid CVV';
                      return null;
                    },
                  ),
                ),
              ]),
            ],
          ),
        ),
      );

  // ── Confirm ───────────────────────────────────────────────────────────────────
  void _confirm() {
    // Validate detail fields if a pre-pay method is selected
    if (_isMomo || _isCard) {
      if (!(_detailsFormKey.currentState?.validate() ?? false)) return;
    }

    Map<String, dynamic> details = {};
    if (_isMomo) {
      details = {
        'number': _momoNumberCtrl.text.trim(),
        'name': _momoNameCtrl.text.trim(),
      };
    } else if (_isCard) {
      details = {
        'cardNumber': _cardNumberCtrl.text.trim(),
        'cardName': _cardNameCtrl.text.trim(),
        'expiry': _cardExpiryCtrl.text.trim(),
      };
    }

    Navigator.pop(context, {
      'method': _selected,
      'details': details,
    });
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = _cart.subtotal;
    final total = subtotal + _deliveryFee;

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.text, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Select Payment',
            style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      body: ListView(children: [
        // Order summary
        _sectionLabel('Order summary'),
        Container(
          color: AppColors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(children: [
            _summaryRow("Item's total (${_cart.itemCount})",
                'UGX ${subtotal.toStringAsFixed(0)}'),
            _summaryRow('Delivery fees',
                'UGX ${_deliveryFee.toStringAsFixed(0)}'),
            const Divider(height: 20, color: AppColors.lightGrey),
            _summaryRow('Total', 'UGX ${total.toStringAsFixed(0)}',
                bold: true),
          ]),
        ),

        // Promo
        Container(
          color: AppColors.white,
          margin: const EdgeInsets.only(top: 1),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            Icon(Icons.confirmation_number_outlined,
                color: AppColors.primary.withValues(alpha: 0.7), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _promoCtrl,
                decoration: const InputDecoration(
                  hintText: 'Enter promo code',
                  hintStyle:
                      TextStyle(color: AppColors.grey, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Apply',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
        ),

        const SizedBox(height: 8),

        // Pre-pay section
        _sectionLabel('Payment Method'),
        Container(
          color: AppColors.white,
          padding:
              const EdgeInsets.only(left: 16, top: 12, bottom: 4),
          child: const Text('Pre-pay Now',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text)),
        ),
        _paymentTile(
            'visa',
            'Pay now with Bank cards',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Visa_Inc._logo.svg/320px-Visa_Inc._logo.svg.png'),
        const Divider(height: 1, color: AppColors.lightGrey),
        _paymentTile(
            'airtel',
            'Pay now with Airtel Money',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/Airtel_logo_2010.svg/320px-Airtel_logo_2010.svg.png'),
        const Divider(height: 1, color: AppColors.lightGrey),
        _paymentTile(
            'mtn',
            'Pay now with MTN Money',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/New-mtn-logo.jpg/320px-New-mtn-logo.jpg'),

        const Divider(height: 1, color: AppColors.lightGrey),

        // Pay on delivery
        Container(
          color: AppColors.white,
          padding:
              const EdgeInsets.only(left: 16, top: 14, bottom: 4),
          child: const Text('Payment on delivery',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text)),
        ),
        InkWell(
          onTap: () => setState(() => _selected = 'pod'),
          child: Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _radio('pod'),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Pay on Delivery (Mobile Money and Bank Cards)',
                    style: TextStyle(
                        fontSize: 14,
                        color: _isPod
                            ? AppColors.primary
                            : AppColors.text,
                        fontWeight: _isPod
                            ? FontWeight.w600
                            : FontWeight.normal),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.delivery_dining,
                    color: AppColors.primary, size: 28),
              ],
            ),
          ),
        ),
        if (_isPod)
          Container(
            margin: const EdgeInsets.only(
                left: 56, right: 16, bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('We accept',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText)),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 48, height: 22,
                    child: Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/New-mtn-logo.jpg/320px-New-mtn-logo.jpg',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 56, height: 22,
                    child: Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/Airtel_logo_2010.svg/320px-Airtel_logo_2010.svg.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                ]),
                const SizedBox(height: 6),
                const Text(
                  'Pay with Mobile Money or Bank Card on delivery.',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.secondaryText),
                ),
              ],
            ),
          ),

        const SizedBox(height: 80),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Confirm Payment Method',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}
