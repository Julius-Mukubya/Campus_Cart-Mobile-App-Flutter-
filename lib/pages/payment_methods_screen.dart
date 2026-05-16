import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String _selectedId = 'mtn';

  // MTN / Airtel details
  final _mtnNumberCtrl   = TextEditingController();
  final _mtnNameCtrl     = TextEditingController();
  final _airtelNumberCtrl = TextEditingController();
  final _airtelNameCtrl  = TextEditingController();

  // Visa details
  final _cardNumberCtrl = TextEditingController();
  final _cardNameCtrl   = TextEditingController();
  final _cardExpiryCtrl = TextEditingController();
  final _cardCvvCtrl    = TextEditingController();

  final List<Map<String, dynamic>> _methods = [
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

  @override
  void dispose() {
    _mtnNumberCtrl.dispose(); _mtnNameCtrl.dispose();
    _airtelNumberCtrl.dispose(); _airtelNameCtrl.dispose();
    _cardNumberCtrl.dispose(); _cardNameCtrl.dispose();
    _cardExpiryCtrl.dispose(); _cardCvvCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, IconData icon, BuildContext context) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.lightGrey)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.lightGrey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        filled: true,
        fillColor: AppColors.getSurface(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      );

  Widget _detailsPanel() {
    if (_selectedId == 'mtn') {
      return _momoPanel('MTN MoMo', _mtnNumberCtrl, _mtnNameCtrl, context);
    } else if (_selectedId == 'airtel') {
      return _momoPanel('Airtel Money', _airtelNumberCtrl, _airtelNameCtrl, context);
    } else if (_selectedId == 'visa') {
      return _visaPanel(context);
    }
    return const SizedBox.shrink();
  }

  Widget _momoPanel(String provider, TextEditingController numCtrl, TextEditingController nameCtrl, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$provider Details',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
          const SizedBox(height: 12),
          TextFormField(
            controller: numCtrl,
            keyboardType: TextInputType.phone,
            decoration: _dec('$provider Number', Icons.phone_outlined, context),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: nameCtrl,
            decoration: _dec('Account Name', Icons.person_outline, context),
          ),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.info_outline, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text('You will receive a payment prompt on this number.',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _visaPanel(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Card Details',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cardNumberCtrl,
            keyboardType: TextInputType.number,
            maxLength: 19,
            decoration: _dec('Card Number', Icons.credit_card, context),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cardNameCtrl,
            decoration: _dec('Cardholder Name', Icons.person_outline, context),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: _cardExpiryCtrl,
                keyboardType: TextInputType.number,
                maxLength: 5,
                decoration: _dec('MM / YY', Icons.calendar_today, context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _cardCvvCtrl,
                keyboardType: TextInputType.number,
                maxLength: 3,
                obscureText: true,
                decoration: _dec('CVV', Icons.lock_outline, context),
              ),
            ),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.lock_outline, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text('Your card details are encrypted and secure.',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
            ),
          ]),
        ],
      ),
    );
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_methods.firstWhere((m) => m['id'] == _selectedId)['name']} saved'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              color: AppColors.getSurface(context),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Icon(Icons.arrow_back_ios, color: Theme.of(context).iconTheme.color, size: 16),
          ),
        ),
        title: Text('Payment Methods',
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text('Select a payment method and enter your details',
                  style: TextStyle(fontSize: 14, color: AppColors.secondaryText)),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  ..._methods.map((method) {
                    final isSelected = _selectedId == method['id'];
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _selectedId = method['id']),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.lightGrey,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.12)
                                      : AppColors.black.withValues(alpha: 0.05),
                                  blurRadius: isSelected ? 16 : 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(children: [
                                Container(
                                  width: 64, height: 44,
                                  decoration: BoxDecoration(
                                    color: (method['color'] as Color).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: (method['color'] as Color).withValues(alpha: 0.3)),
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
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: isSelected ? AppColors.primary : AppColors.text)),
                                      Text(method['subtitle'],
                                          style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                                    ],
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 22, height: 22,
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
                              ]),
                            ),
                          ),
                        ),
                        // Inline detail fields when selected
                        if (isSelected) _detailsPanel(),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Save Payment Method',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
