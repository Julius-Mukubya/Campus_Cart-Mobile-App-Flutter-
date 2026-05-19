import os

base = r'c:\Users\AMINAH NAKAZIBWE\Desktop\Campus_Cart-Mobile-App-Flutter-\lib'

def fix_file(path, replacements):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    original = content
    for old, new in replacements:
        content = content.replace(old, new)
    if content != original:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'FIXED: {os.path.basename(path)}')
    else:
        print(f'NO CHANGE: {os.path.basename(path)}')

def write_file(path, content):
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'WRITTEN: {os.path.basename(path)}')

# ── 1. seller_management_screen.dart — remove SellerRequestService ──────────
fix_file(os.path.join(base, r'pages\admin\seller_management_screen.dart'), [
    ("import 'package:madpractical/services/seller_service.dart';\n", ''),
    ("  final SellerRequestService _sellerRequestService = SellerRequestService();\n\n", ''),
    ("  final _sellerRequestService = SellerRequestService();\n\n", ''),
    ("  final SellerRequestService _sellerRequestService = SellerRequestService();\n", ''),
    ("  final _sellerRequestService = SellerRequestService();\n", ''),
    # Replace calls - stub out to log
    ("await _sellerRequestService.", "// _sellerRequestService."),
    ("_sellerRequestService.", "// _sellerRequestService."),
])

# ── 2. become_seller_screen.dart — remove UserManager + SellerRequestService ─
fix_file(os.path.join(base, r'pages\profile\become_seller_screen.dart'), [
    ("import 'package:madpractical/services/seller_service.dart';\n", ''),
    ("  final _userManager = UserManager();\n  final _sellerRequestService = SellerRequestService();\n",
     ''),
    ("  final _userManager = UserManager();\n", ''),
    ("  final _sellerRequestService = SellerRequestService();\n", ''),
    ("_userManager.userId", "null /* TODO: use ref.watch(userProvider).userId */"),
    ("_userManager.name", "'' /* TODO: use ref.watch(userProvider).name */"),
    ("_userManager.email", "'' /* TODO: use ref.watch(userProvider).email */"),
    ("await _sellerRequestService.", "// await _sellerRequestService."),
    ("_sellerRequestService.", "// _sellerRequestService."),
])

# ── 3. edit_profile_screen.dart — remove UserManager + Firebase*Service ──────
fix_file(os.path.join(base, r'pages\profile\edit_profile_screen.dart'), [
    ("  final UserManager _userManager = UserManager();\n", ''),
    ("  final _userManager = UserManager();\n", ''),
    # Replace FirebaseAuthService instantiation inside methods
    ("final _authService = FirebaseAuthService();", "final _authService = AuthService();"),
    ("final FirebaseAuthService _authService = FirebaseAuthService();", "final AuthService _authService = AuthService();"),
    ("FirebaseAuthService()", "AuthService()"),
    # Replace FirebaseStorageService
    ("FirebaseStorageService()", "StorageService()"),
    ("final _storageService = FirebaseStorageService();", "final _storageService = StorageService();"),
    ("final FirebaseStorageService _storageService = FirebaseStorageService();", "final StorageService _storageService = StorageService();"),
    # Replace _userManager usages
    ("_userManager.userId", "null /* TODO: use ref.watch(userProvider).userId */"),
    ("_userManager.name", "'' /* TODO: ref.watch(userProvider).name */"),
    ("_userManager.email", "'' /* TODO: ref.watch(userProvider).email */"),
    ("_userManager.phone", "'' /* TODO: ref.watch(userProvider).phone */"),
    ("_userManager.profileImage", "null /* TODO: ref.watch(userProvider).profileImage */"),
    ("_userManager.role", "'' /* TODO: ref.watch(userProvider).role */"),
    ("await _userManager.updateProfile(", "// await _userManager.updateProfile("),
    ("_userManager.updateProfile(", "// _userManager.updateProfile("),
])

# ── 4. home_screen.dart — remove WishlistManager/CartManager/NotificationManager/DatabaseService ──
fix_file(os.path.join(base, r'pages\customer\home_screen.dart'), [
    # Remove broken imports
    ("import 'package:madpractical/services/managers/wishlist_manager.dart';\n", ''),
    ("import 'package:madpractical/services/managers/cart_manager.dart';\n", ''),
    ("import 'package:madpractical/services/managers/notification_manager.dart';\n", ''),
    # Add riverpod import after flutter import (only if not present)
    # Remove field declarations
    ("  final WishlistManager _wishlistManager = WishlistManager();\n", ''),
    ("  final CartManager _cartManager = CartManager();\n", ''),
    ("  final NotificationManager _notificationManager = NotificationManager();\n", ''),
    # Remove addListener/removeListener calls
    ("    _wishlistManager.addListener(_onWishlistChanged);\n", ''),
    ("    _cartManager.addListener(_onCartChanged);\n", ''),
    ("    _wishlistManager.removeListener(_onWishlistChanged);\n", ''),
    ("    _cartManager.removeListener(_onCartChanged);\n", ''),
    # Remove _onWishlistChanged, _onCartChanged if present
    # Replace DatabaseService with direct product service calls
    ("    final db = DatabaseService();\n", ''),
    ("    final db = DatabaseService();\n", ''),
    # Simplify _loadData to not use DatabaseService
    ("""      // ── Cache-first: show SQLite data immediately ──────────────────────
      final isFresh = await db.isProductCacheFresh(maxAgeMinutes: 30);
      if (isFresh) {
        final cached = await db.getCachedProducts();
        if (cached.isNotEmpty) {
          _applyProducts(cached);
          setState(() => _isLoading = false);
          // Refresh in background without showing loader
          _refreshFromFirestore(db);
          return;
        }
      }

      // ── No fresh cache: fetch from Firestore ───────────────────────────
      await _refreshFromFirestore(db);""",
"""      // Fetch from Firestore directly
      await _refreshFromFirestore();"""),
    ("""    } catch (e) {
      // Try stale cache as last resort
      final stale = await db.getCachedProducts();
      if (stale.isNotEmpty) {
        _applyProducts(stale);
        setState(() => _isLoading = false);
      } else {
        setState(() { _hasError = true; _isLoading = false; _loadFallbackData(); });
      }
    }""",
"""    } catch (e) {
      setState(() { _hasError = true; _isLoading = false; _loadFallbackData(); });
    }"""),
    # Fix _refreshFromFirestore signature
    ("  Future<void> _refreshFromFirestore(DatabaseService db) async {",
     "  Future<void> _refreshFromFirestore() async {"),
    # Remove db.cacheProducts call
    ("      await db.cacheProducts(products);\n", ''),
    # Fix the call in catch block too
    ("      _refreshFromFirestore(db);",
     "_refreshFromFirestore();"),
    # Replace manager method calls - wishlist
    ("_wishlistManager.isInWishlist(", "_wishlistIsInWishlist("),
    ("_wishlistManager.toggleWishlist(", "_wishlistToggle("),
    ("_wishlistManager.itemCount", "_wishlistItemCount"),
    # Replace manager method calls - cart
    ("_cartManager.addToCart(", "_cartAddToCart("),
    ("_cartManager.isInCart(", "_cartIsInCart("),
    ("_cartManager.itemCount", "_cartItemCount"),
    # Replace notification manager
    ("_notificationManager.unreadCount", "0 /* TODO: ref.watch(notificationProvider).unreadCount */"),
])

# ── 5. product_details.dart — remove WishlistManager/CartManager ─────────────
fix_file(os.path.join(base, r'pages\customer\product_details.dart'), [
    ("import 'package:madpractical/services/managers/wishlist_manager.dart';\n", ''),
    ("import 'package:madpractical/services/managers/cart_manager.dart';\n", ''),
    ("  final WishlistManager _wishlistManager = WishlistManager();\n", ''),
    ("  final CartManager _cartManager = CartManager();\n", ''),
    ("    _wishlistManager.addListener(_onWishlistChanged);\n", ''),
    ("    _cartManager.addListener(_onCartChanged);\n", ''),
    ("    _wishlistManager.removeListener(_onWishlistChanged);\n", ''),
    ("    _cartManager.removeListener(_onCartChanged);\n", ''),
    ("_wishlistManager.isInWishlist(", "_wishlistIsInWishlist("),
    ("_wishlistManager.toggleWishlist(", "_wishlistToggle("),
    ("_wishlistManager.itemCount", "_wishlistItemCount"),
    ("_cartManager.addToCart(", "_cartAddToCart("),
    ("_cartManager.isInCart(", "_cartIsInCart("),
    ("_cartManager.itemCount", "_cartItemCount"),
])

# ── 6. categories_screen.dart — remove WishlistManager/CartManager ───────────
fix_file(os.path.join(base, r'pages\customer\categories_screen.dart'), [
    ("  final WishlistManager _wishlistManager = WishlistManager();\n", ''),
    ("  final CartManager _cartManager = CartManager();\n", ''),
    ("  final WishlistManager _wishlistManager = WishlistManager();\n  ", ''),
    ("  final CartManager _cartManager = CartManager();\n  ", ''),
    ("    _wishlistManager.addListener(_onWishlistChanged);\n", ''),
    ("    _cartManager.addListener(_onCartChanged);\n", ''),
    ("    _wishlistManager.removeListener(_onWishlistChanged);\n", ''),
    ("    _cartManager.removeListener(_onCartChanged);\n", ''),
    ("_wishlistManager.isInWishlist(", "_wishlistIsInWishlist("),
    ("_wishlistManager.toggleWishlist(", "_wishlistToggle("),
    ("_wishlistManager.itemCount", "_wishlistItemCount"),
    ("_cartManager.addToCart(", "_cartAddToCart("),
    ("_cartManager.isInCart(", "_cartIsInCart("),
    ("_cartManager.itemCount", "_cartItemCount"),
])

# ── 7. wishlist_screen.dart — remove WishlistManager/CartManager ─────────────
fix_file(os.path.join(base, r'pages\customer\wishlist_screen.dart'), [
    ("  final WishlistManager _wishlistManager = WishlistManager();\n", ''),
    ("  final CartManager _cartManager = CartManager();\n", ''),
    ("    _wishlistManager.addListener(_onWishlistChanged);\n", ''),
    ("    _cartManager.addListener(_onCartChanged);\n", ''),
    ("    _wishlistManager.removeListener(_onWishlistChanged);\n", ''),
    ("    _cartManager.removeListener(_onCartChanged);\n", ''),
    ("_wishlistManager.isInWishlist(", "_wishlistIsInWishlist("),
    ("_wishlistManager.toggleWishlist(", "_wishlistToggle("),
    ("_wishlistManager.removeFromWishlist(", "_wishlistRemove("),
    ("_wishlistManager.itemCount", "_wishlistItemCount"),
    ("_cartManager.addToCart(", "_cartAddToCart("),
    ("_cartManager.isInCart(", "_cartIsInCart("),
    ("_cartManager.itemCount", "_cartItemCount"),
])

# ── 8. checkout_screen.dart — remove broken imports + manager fields ──────────
fix_file(os.path.join(base, r'pages\customer\checkout_screen.dart'), [
    ("import 'package:madpractical/services/managers/cart_manager.dart';\n", ''),
    ("import 'package:madpractical/services/managers/order_manager.dart';\n", ''),
    ("import 'package:madpractical/services/auth/firebase_auth_service.dart';\n", ''),
    ("import 'package:madpractical/services/managers/user_manager.dart';\n", ''),
    ("  final CartManager _cartManager = CartManager();\n", ''),
    ("  final OrderManager _orderManager = OrderManager();\n", ''),
    ("  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();\n", ''),
    ("  final UserManager _userManager = UserManager();\n", ''),
    ("  final CartManager _cartManager = CartManager();\n  ", ''),
    ("  final OrderManager _orderManager = OrderManager();\n  ", ''),
    ("  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();\n  ", ''),
    ("  final UserManager _userManager = UserManager();\n  ", ''),
    ("_cartManager.", "ref.watch(cartProvider)."),
    ("_orderManager.", "ref.read(orderProvider.notifier)."),
    ("_firebaseAuthService.currentUser", "null /* TODO: authService.currentUser */"),
    ("_userManager.", "null /* TODO: ref.watch(userProvider). */"),
])

# ── 9. Stub out addresses_screen.dart (marked for deletion) ──────────────────
write_file(os.path.join(base, r'pages\customer\addresses_screen.dart'), '''import 'package:flutter/material.dart';

/// This screen has been deprecated — delivery addresses are not used in Campus Cart.
class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Addresses')),
      body: const Center(child: Text('Addresses not available')),
    );
  }
}
''')

# ── 10. Stub out order_chat_screen.dart (marked for deletion) ─────────────────
write_file(os.path.join(base, r'pages\customer\order_chat_screen.dart'), '''import 'package:flutter/material.dart';

/// This screen has been deprecated — chat is now integrated directly in order details.
class OrderChatScreen extends StatelessWidget {
  final String orderId;
  final String sellerId;

  const OrderChatScreen({
    super.key,
    required this.orderId,
    required this.sellerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Chat')),
      body: const Center(child: Text('Chat will be available in order details')),
    );
  }
}
''')

print("All fixes applied!")
