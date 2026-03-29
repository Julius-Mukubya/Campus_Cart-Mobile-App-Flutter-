import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String _selectedId = 'mtn'; // default selected

  final List<Map<String, dynamic>> _methods = [
    {
      'id': 'mtn',
      'name': 'MTN Mobile Money',
      'subtitle': 'Pay with MTN MoMo',
      'logoUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/New-mtn-logo.jpg/320px-New-mtn-logo.jpg',
      'color': const Color(0xFFFFCC00),
      'textColor': Colors.black,
    },
    {
      'id': 'airtel',
      'name': 'Airtel Money',
      'subtitle': 'Pay with Airtel Money',
      'logoUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/Airtel_logo_2010.svg/320px-Airtel_logo_2010.svg.png',
      'color': const Color(0xFFE40000),
      'textColor': Colors.white,
    },
    {
      'id': 'visa',
      'name': 'Bank / Visa Card',
      'subtitle': 'Credit or Debit card',
      'logoUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Visa_Inc._logo.svg/320px-Visa_Inc._logo.svg.png',
      'color': const Color(0xFF1A1F71),
      'textColor': Colors.white,
    },
  ];

  void _confirm() {
    final selected = _methods.firstWhere((m) => m['id'] == _selectedId);
    Navigator.pop(context, selected);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selected['name']} selected'),
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
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios, color: AppColors.text, size: 16),
          ),
        ),
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Choose how you want to pay',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryText,
                ),
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _methods.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final method = _methods[index];
                  final isSelected = _selectedId == method['id'];

                  return GestureDetector(
                    onTap: () => setState(() => _selectedId = method['id']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.lightGrey,
                          width: isSelected ? 2.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.12)
                                : AppColors.black.withValues(alpha: 0.05),
                            blurRadius: isSelected ? 20 : 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            // Logo container
                            Container(
                              width: 72,
                              height: 48,
                              decoration: BoxDecoration(
                                color: (method['color'] as Color).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: (method['color'] as Color).withValues(alpha: 0.35),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Image.network(
                                    method['logoUrl'],
                                    fit: BoxFit.contain,
                                    loadingBuilder: (_, child, progress) => progress == null
                                        ? child
                                        : Center(
                                            child: SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: method['color'] as Color,
                                              ),
                                            ),
                                          ),
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.payment,
                                      color: method['color'] as Color,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Name & subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method['name'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? AppColors.primary : AppColors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    method['subtitle'],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Radio indicator
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.grey,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Confirm button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirm Payment Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
