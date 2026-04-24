import 'package:flutter/material.dart';
import 'package:madpractical/pages/checkout/place_order_screen.dart';
import 'package:madpractical/widgets/app_bottom_navigation.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/wishlist_manager.dart';
import 'package:madpractical/services/cart_manager.dart';
import 'package:madpractical/widgets/notification_icon.dart';
import 'package:madpractical/pages/ai_chat_support_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final WishlistManager _wishlistManager = WishlistManager();
  final CartManager _cartManager = CartManager();
  String selectedDeliveryMethod = 'Standard';
  String selectedAddress = 'Home Address';
  String selectedPaymentMethod = 'Mobile Money';
  
  @override
  void initState() {
    super.initState();
    _wishlistManager.addListener(_onWishlistChanged);
    _cartManager.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _wishlistManager.removeListener(_onWishlistChanged);
    _cartManager.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onWishlistChanged() {
    setState(() {});
  }

  void _onCartChanged() {
    setState(() {});
  }

  void increaseQuantity(String productName) {
    final item = _cartManager.cartItems.firstWhere((item) => item['name'] == productName);
    _cartManager.updateQuantity(productName, (item['quantity'] ?? 1) + 1);
  }

  void decreaseQuantity(String productName) {
    final item = _cartManager.cartItems.firstWhere((item) => item['name'] == productName);
    final currentQuantity = item['quantity'] ?? 1;
    if (currentQuantity > 1) {
      _cartManager.updateQuantity(productName, currentQuantity - 1);
    }
  }

  void removeItem(String productName) {
    _cartManager.removeFromCart(productName);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item removed from cart'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }



  Widget _buildCartItem(Map<String, dynamic> item) {
    final price = double.tryParse(item['price'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
    final discount = item['discount'] != null ? double.tryParse(item['discount'].toString().replaceAll('%', '').replaceAll('-', '')) ?? 0 : 0;
    final discountedPrice = discount > 0 ? price * (1 - discount / 100) : price;
    
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
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.05),
                    AppColors.secondary.withValues(alpha: 0.02),
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 30,
                        color: AppColors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Remove Button
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => removeItem(item['name']),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item['category'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Price and Quantity Controls
                  Row(
                    children: [
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (discount > 0) ...[
                            Text(
                              item['price'].toString().contains('UGX') ? item['price'] : 'UGX ${price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.secondaryText,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            Text(
                              'UGX ${discountedPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ] else ...[
                            Text(
                              item['price'].toString().contains('UGX') ? item['price'] : 'UGX ${price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Quantity Controls
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => decreaseQuantity(item['name']),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: item['quantity'] > 1 
                                      ? AppColors.primary.withValues(alpha: 0.1)
                                      : AppColors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 16,
                                  color: item['quantity'] > 1 
                                      ? AppColors.primary 
                                      : AppColors.grey,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '${item['quantity']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => increaseQuantity(item['name']),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal (${_cartManager.itemCount} items)',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ),
              Text(
                'UGX ${_cartManager.subtotal.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          
          // Delivery Fee
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Fee',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ),
              Text(
                'UGX ${_cartManager.deliveryFee.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          
          const Divider(height: 20),
          
          // Total
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
                'UGX ${_cartManager.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Cart is Empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add items to your cart to see them here.\nStart shopping and discover amazing products.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.secondaryText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 20),
                SizedBox(width: 8),
                Text(
                  'Start Shopping',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
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
        title: Text(
          'My Cart',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        actions: const [
          NotificationIcon(),
        ],
      ),
      body: SafeArea(
        child: _cartManager.cartItems.isEmpty
            ? _buildEmptyCart()
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Info
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
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_cartManager.itemCount} ${_cartManager.itemCount == 1 ? 'Item' : 'Items'} in Cart',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Review your items before checkout',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.shopping_cart,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Cart Items
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cartManager.itemCount,
                        itemBuilder: (context, index) {
                          return _buildCartItem(_cartManager.cartItems[index]);
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Price Summary
                    _buildPriceSummary(),
                    
                    const SizedBox(height: 20),

                    // Checkout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PlaceOrderScreen(),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.payment, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Proceed to Checkout • UGX ${_cartManager.total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AiChatSupportScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(
          Icons.support_agent,
          color: AppColors.white,
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 3,
        wishlistCount: _wishlistManager.itemCount,
        cartCount: _cartManager.itemCount,
      ),
    );
  }
}
