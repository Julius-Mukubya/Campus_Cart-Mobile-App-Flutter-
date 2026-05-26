import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madpractical/providers/cart_provider.dart';
import 'package:madpractical/providers/checkout_provider.dart';
import 'package:madpractical/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:go_router/go_router.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _showContact = true; // Toggle contact visibility to seller

  @override
  void initState() {
    super.initState();
    // Initialize checkout with cart data
    _initCheckout();
  }

  void _initCheckout() {
    final cart = ref.read(cartProvider);
    ref.read(checkoutProvider.notifier).updateCart(
      items: cart.items,
      subtotal: cart.subtotal,
    );
  }

  Future<void> _placeOrder() async {
    final user = ref.read(userProvider);
    final cart = ref.read(cartProvider);
    final checkoutNotifier = ref.read(checkoutProvider.notifier);

    // Validation checks
    if (user.userId == null || user.userId!.isEmpty) {
      _showMessage('You must be logged in', isError: true);
      return;
    }

    if (cart.items.isEmpty) {
      _showMessage('Cart is empty', isError: true);
      return;
    }

    // Ensure all items have required fields
    for (int i = 0; i < cart.items.length; i++) {
      final item = cart.items[i];
      if (item['id'] == null || (item['id'] as String).isEmpty) {
        _showMessage('Invalid product in cart', isError: true);
        return;
      }
      if (item['sellerId'] == null || (item['sellerId'] as String).isEmpty) {
        _showMessage('Product missing seller information', isError: true);
        return;
      }
    }

    // Verify all items are from same seller
    final firstSellerId = (cart.items.first['sellerId'] as String? ?? '').trim();
    final allSameSeller = cart.items.every(
      (item) => (item['sellerId'] as String? ?? '').trim() == firstSellerId,
    );
    if (!allSameSeller) {
      _showMessage('All items must be from the same seller', isError: true);
      return;
    }

    if (firstSellerId.isEmpty) {
      _showMessage('Could not determine seller', isError: true);
      return;
    }

    try {
      // Create order with status 'pending' (respects order lifecycle)
      final orderId = await checkoutNotifier.createOrder(
        customerId: user.userId!,
        customerName: user.name,
        customerPhone: user.phone,
        sellerId: firstSellerId,
        showContactToSeller: _showContact,
      );

      if (orderId == null || orderId.isEmpty) {
        // Check if error exists in provider state
        final checkoutState = ref.read(checkoutProvider);
        final errorMsg = checkoutState.error ?? 'Failed to create order. Please try again.';
        _showMessage(errorMsg, isError: true);
        return;
      }

      if (!mounted) return;

      // Clear cart after successful order creation
      ref.read(cartProvider.notifier).clearCart();

      // Show success message
      _showMessage('Order placed successfully! Status: Pending');

      // Navigate to my orders after brief delay
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        context.go('/my-orders');
      }
    } catch (e) {
      _showMessage('Error placing order: $e', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final checkout = ref.watch(checkoutProvider);
    final isProcessing = checkout.isProcessing;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.getBackground(context),
        leading: IconButton(
          onPressed: isProcessing ? null : () => context.pop(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.getSurface(context),
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
          'Checkout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.text,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Items Section ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.getSurface(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark ? [] : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Items (${cart.itemCount})',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...cart.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item['image'] != null && item['image'].toString().isNotEmpty
                              ? Image.network(
                                  item['image'],
                                  width: 48, height: 48, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 48, height: 48,
                                    color: AppColors.lightGrey,
                                    child: const Icon(Icons.image_outlined, color: AppColors.grey),
                                  ),
                                )
                              : Container(
                                  width: 48, height: 48,
                                  color: AppColors.lightGrey,
                                  child: const Icon(Icons.shopping_bag, color: AppColors.grey),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] ?? 'Product',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Qty: ${item['quantity'] ?? 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'UGX ${_formatPrice(item['price'])}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Contact Visibility Toggle ─────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.getSurface(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark ? [] : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.visibility_outlined, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Share Contact Details',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Let the seller view your phone number to arrange pickup',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _showContact,
                    onChanged: (v) => setState(() => _showContact = v),
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Price Summary ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.getSurface(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark ? [] : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      Text(
                        'UGX ${cart.subtotal.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        'UGX ${cart.subtotal.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Info Banner ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'After ordering, the seller will contact you to arrange pickup. '
                      'No payment is needed on the app.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: AppColors.getSurface(context),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isProcessing ? null : _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Place Order',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(dynamic price) {
    if (price is double || price is int) return price.toStringAsFixed(0);
    if (price is String) {
      final num = double.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return num.toStringAsFixed(0);
    }
    return '0';
  }
}