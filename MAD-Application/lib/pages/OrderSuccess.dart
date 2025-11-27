import 'package:flutter/material.dart';
import 'package:madpractical/widgets/app_bottom_navigation.dart';
import 'package:madpractical/services/wishlist_manager.dart';

class OrderSuccess extends StatelessWidget {
  const OrderSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistManager = WishlistManager();
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'Order Placed',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 96),
            const SizedBox(height: 24),
            const Text(
              'Your order was placed successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Thank you for your purchase. You will receive an email confirmation shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Return to home and remove all previous routes
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continue Shopping',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('View Order Details'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 0,
        wishlistCount: wishlistManager.itemCount,
      ),
    );
  }
}
