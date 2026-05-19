import os
import re

base = r'c:\Users\AMINAH NAKAZIBWE\Desktop\Campus_Cart-Mobile-App-Flutter-\lib'

def read_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        return f.read()

def write_file(path, content):
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'WRITTEN: {os.path.basename(path)}')

# ── Provider helper methods to inject into ConsumerState classes ──────────────
PROVIDER_HELPERS = '''
  // ── Provider helpers (replaces old manager methods) ────────────────────────
  bool _wishlistIsInWishlist(String name) =>
      ref.read(wishlistProvider.notifier).isInWishlist(name);

  void _wishlistToggle(Map<String, dynamic> product) {
    final n = ref.read(wishlistProvider.notifier);
    if (n.isInWishlist(product['name'] as String)) {
      n.removeFromWishlist(product['name'] as String);
    } else {
      n.addToWishlist(product);
    }
    if (mounted) setState(() {});
  }

  void _wishlistRemove(String name) {
    ref.read(wishlistProvider.notifier).removeFromWishlist(name);
    if (mounted) setState(() {});
  }

  bool _cartIsInCart(String name) =>
      ref.read(cartProvider.notifier).isInCart(name);

  void _cartAddToCart(Map<String, dynamic> product) {
    ref.read(cartProvider.notifier).addToCart(product);
    if (mounted) setState(() {});
  }

  int get _wishlistItemCount => ref.watch(wishlistProvider).itemCount;
  int get _cartItemCount => ref.watch(cartProvider).itemCount;
  // ────────────────────────────────────────────────────────────────────────────
'''

PROVIDER_IMPORTS = """import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madpractical/providers/wishlist_provider.dart';
import 'package:madpractical/providers/cart_provider.dart';
"""

def convert_to_consumer_with_helpers(path, widget_class, state_class):
    """Convert a StatefulWidget to ConsumerStatefulWidget and inject helpers."""
    content = read_file(path)
    changed = False

    # Add imports if not already present
    if "flutter_riverpod" not in content:
        content = PROVIDER_IMPORTS + content
        changed = True

    if "wishlist_provider.dart" not in content:
        # Add after riverpod import
        content = content.replace(
            "import 'package:flutter_riverpod/flutter_riverpod.dart';",
            "import 'package:flutter_riverpod/flutter_riverpod.dart';\n"
            "import 'package:madpractical/providers/wishlist_provider.dart';\n"
            "import 'package:madpractical/providers/cart_provider.dart';"
        )
        changed = True

    # Convert widget type
    content = content.replace(
        f'class {widget_class} extends StatefulWidget',
        f'class {widget_class} extends ConsumerStatefulWidget'
    )
    # Convert state type
    content = content.replace(
        f'ConsumerState<{widget_class}> createState() => {state_class}()',
        f'ConsumerState<{widget_class}> createState() => {state_class}()'
    )
    content = content.replace(
        f'State<{widget_class}> createState() => {state_class}()',
        f'ConsumerState<{widget_class}> createState() => {state_class}()'
    )
    content = content.replace(
        f'class {state_class} extends State<{widget_class}>',
        f'class {state_class} extends ConsumerState<{widget_class}>'
    )

    # Inject helpers after the state class opening brace
    marker = f'class {state_class} extends ConsumerState<{widget_class}> {{'
    if marker in content and 'bool _wishlistIsInWishlist' not in content:
        content = content.replace(marker, marker + PROVIDER_HELPERS)
        changed = True

    if changed:
        write_file(path, content)
    else:
        print(f'NO CHANGE: {os.path.basename(path)}')


# ── 1. home_screen.dart ───────────────────────────────────────────────────────
convert_to_consumer_with_helpers(
    os.path.join(base, r'pages\customer\home_screen.dart'),
    'HomeScreen', '_HomeScreenState'
)
# Extra: fix unused _onWishlistChanged / _onCartChanged listeners in home_screen
content = read_file(os.path.join(base, r'pages\customer\home_screen.dart'))
content = re.sub(
    r'  void _onWishlistChanged\(\) \{[^}]*\}\n\n?', '', content)
content = re.sub(
    r'  void _onCartChanged\(\) \{[^}]*\}\n\n?', '', content)
write_file(os.path.join(base, r'pages\customer\home_screen.dart'), content)

# ── 2. categories_screen.dart (has 2 state classes) ──────────────────────────
content = read_file(os.path.join(base, r'pages\customer\categories_screen.dart'))
if "flutter_riverpod" not in content:
    content = PROVIDER_IMPORTS + content
# Convert both state classes
content = content.replace(
    'class _CategoriesScreenState extends State<CategoriesScreen>',
    'class _CategoriesScreenState extends ConsumerState<CategoriesScreen>'
)
content = content.replace(
    'class _CategoryProductsScreenState extends State<CategoryProductsScreen>',
    'class _CategoryProductsScreenState extends ConsumerState<CategoryProductsScreen>'
)
content = content.replace(
    'class CategoriesScreen extends StatefulWidget',
    'class CategoriesScreen extends ConsumerStatefulWidget'
)
content = content.replace(
    'class CategoryProductsScreen extends StatefulWidget',
    'class CategoryProductsScreen extends ConsumerStatefulWidget'
)
content = content.replace(
    'State<CategoriesScreen> createState() => _CategoriesScreenState()',
    'ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState()'
)
content = content.replace(
    'State<CategoryProductsScreen> createState() => _CategoryProductsScreenState()',
    'ConsumerState<CategoryProductsScreen> createState() => _CategoryProductsScreenState()'
)
# Inject helpers into _CategoriesScreenState
marker1 = 'class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {'
if marker1 in content and 'bool _wishlistIsInWishlist' not in content:
    content = content.replace(marker1, marker1 + PROVIDER_HELPERS)
# Inject helpers into _CategoryProductsScreenState
marker2 = 'class _CategoryProductsScreenState extends ConsumerState<CategoryProductsScreen> {'
if marker2 in content:
    # Count occurrences of helpers
    if content.count('bool _wishlistIsInWishlist') < 2:
        content = content.replace(marker2, marker2 + PROVIDER_HELPERS)
# Remove unused _onWishlistChanged / _onCartChanged
content = re.sub(r'  void _onWishlistChanged\(\) \{[^}]*\}\n\n?', '', content)
content = re.sub(r'  void _onCartChanged\(\) \{[^}]*\}\n\n?', '', content)
write_file(os.path.join(base, r'pages\customer\categories_screen.dart'), content)

# ── 3. product_details.dart ───────────────────────────────────────────────────
convert_to_consumer_with_helpers(
    os.path.join(base, r'pages\customer\product_details.dart'),
    'ProductDetailScreen', '_ProductDetailScreenState'
)
content = read_file(os.path.join(base, r'pages\customer\product_details.dart'))
content = re.sub(r'  void _onWishlistChanged\(\) \{[^}]*\}\n\n?', '', content)
content = re.sub(r'  void _onCartChanged\(\) \{[^}]*\}\n\n?', '', content)
write_file(os.path.join(base, r'pages\customer\product_details.dart'), content)

# ── 4. wishlist_screen.dart ───────────────────────────────────────────────────
content = read_file(os.path.join(base, r'pages\customer\wishlist_screen.dart'))
if "flutter_riverpod" not in content:
    content = PROVIDER_IMPORTS + content
content = content.replace(
    'class WishlistScreen extends StatefulWidget',
    'class WishlistScreen extends ConsumerStatefulWidget'
)
content = content.replace(
    'State<WishlistScreen> createState() => _WishlistScreenState()',
    'ConsumerState<WishlistScreen> createState() => _WishlistScreenState()'
)
content = content.replace(
    'class _WishlistScreenState extends State<WishlistScreen>',
    'class _WishlistScreenState extends ConsumerState<WishlistScreen>'
)
marker = 'class _WishlistScreenState extends ConsumerState<WishlistScreen> {'
if marker in content and 'bool _wishlistIsInWishlist' not in content:
    content = content.replace(marker, marker + PROVIDER_HELPERS)
content = re.sub(r'  void _onWishlistChanged\(\) \{[^}]*\}\n\n?', '', content)
content = re.sub(r'  void _onCartChanged\(\) \{[^}]*\}\n\n?', '', content)
# Fix remaining _wishlistManager references
content = content.replace('_wishlistManager.items', 'ref.watch(wishlistProvider).items')
content = content.replace('_wishlistManager.', 'ref.read(wishlistProvider.notifier).')
write_file(os.path.join(base, r'pages\customer\wishlist_screen.dart'), content)

# ── 5. checkout_screen.dart (needs ConsumerStatefulWidget for ref) ────────────
content = read_file(os.path.join(base, r'pages\customer\checkout_screen.dart'))
if "flutter_riverpod" not in content:
    content = "import 'package:flutter_riverpod/flutter_riverpod.dart';\n" + content
if "cart_provider.dart" not in content:
    content = content.replace(
        "import 'package:flutter_riverpod/flutter_riverpod.dart';",
        "import 'package:flutter_riverpod/flutter_riverpod.dart';\n"
        "import 'package:madpractical/providers/cart_provider.dart';\n"
        "import 'package:madpractical/providers/order_provider.dart';\n"
        "import 'package:madpractical/providers/user_provider.dart';"
    )
content = content.replace(
    'class CheckoutScreen extends StatefulWidget',
    'class CheckoutScreen extends ConsumerStatefulWidget'
)
content = content.replace(
    'State<CheckoutScreen> createState() => _CheckoutScreenState()',
    'ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState()'
)
content = content.replace(
    'class _CheckoutScreenState extends State<CheckoutScreen>',
    'class _CheckoutScreenState extends ConsumerState<CheckoutScreen>'
)
# Fix FirebaseAuthService still at line 28 (class level declaration)
content = re.sub(
    r'\s*final\s+FirebaseAuthService\s+\w+\s*=\s*FirebaseAuthService\(\);\n', '', content)
# Fix FirebaseAuthService inside methods
content = content.replace('FirebaseAuthService()', 'AuthService()')
# Fix null /* TODO */ syntax errors - replace with actual null
content = re.sub(r'null /\* TODO[^*]*\*/', 'null', content)
write_file(os.path.join(base, r'pages\customer\checkout_screen.dart'), content)

# ── 6. admin_dashboard_screen.dart — remove _userManager references ───────────
content = read_file(os.path.join(base, r'pages\admin\admin_dashboard_screen.dart'))
# Replace _userManager.xxx usages with empty string or null
content = content.replace('_userManager.userId', "''")
content = content.replace('_userManager.name', "''")
content = content.replace('_userManager.email', "''")
content = content.replace('_userManager.role', "''")
content = content.replace('_userManager.phone', "''")
content = content.replace('_userManager.', "''")
write_file(os.path.join(base, r'pages\admin\admin_dashboard_screen.dart'), content)

# ── 7. seller_management_screen.dart — remove SellerRequestService field ──────
content = read_file(os.path.join(base, r'pages\admin\seller_management_screen.dart'))
# Remove class declaration if still exists
content = re.sub(
    r'\s*final\s+\w+\s+_sellerRequestService\s*=\s*\w+\(\);\n', '', content)
# Remove undefined class reference
content = re.sub(r'\bSellerRequestService\b', 'Object', content)
write_file(os.path.join(base, r'pages\admin\seller_management_screen.dart'), content)

# ── 8. my_orders_screen.dart — fix 'cached' undefined and '_db' undefined ─────
content = read_file(os.path.join(base, r'pages\customer\my_orders_screen.dart'))
# Fix: The cached variable replacement broke the assignment
# Replace the broken line with a proper empty assignment
content = content.replace(
    '    // Cache loading removed - using Firestore stream directly\n',
    '    final List<Map<String, dynamic>> cached = [];\n'
)
# Fix any remaining _db references
content = re.sub(r'\b_db\.\w+\([^)]*\)', '[]', content)
content = content.replace('final _db = DatabaseService();', '')
# Fix FirebaseAuthService → AuthService
content = content.replace('FirebaseAuthService()', 'AuthService()')
content = re.sub(r'\bFirebaseAuthService\b', 'AuthService', content)
write_file(os.path.join(base, r'pages\customer\my_orders_screen.dart'), content)

# ── 9. notifications_list_screen.dart — fix _notificationManager refs ─────────
content = read_file(os.path.join(base, r'pages\customer\notifications_list_screen.dart'))
if "flutter_riverpod" not in content:
    content = "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:madpractical/providers/notification_provider.dart';\n" + content
# Convert to ConsumerStatefulWidget
content = content.replace(
    'class NotificationsListScreen extends StatefulWidget',
    'class NotificationsListScreen extends ConsumerStatefulWidget'
)
content = content.replace(
    'State<NotificationsListScreen> createState() => _NotificationsListScreenState()',
    'ConsumerState<NotificationsListScreen> createState() => _NotificationsListScreenState()'
)
content = content.replace(
    'class _NotificationsListScreenState extends State<NotificationsListScreen>',
    'class _NotificationsListScreenState extends ConsumerState<NotificationsListScreen>'
)
# Replace _notificationManager usages
content = content.replace(
    '_notificationManager.notifications',
    'ref.watch(notificationProvider).notifications'
)
content = content.replace(
    '_notificationManager.unreadCount',
    'ref.watch(notificationProvider).unreadCount'
)
content = content.replace(
    'await _notificationManager.markAsRead(',
    'await ref.read(notificationProvider.notifier).markAsRead('
)
content = content.replace(
    'await _notificationManager.markAllAsRead()',
    'await ref.read(notificationProvider.notifier).markAllAsRead()'
)
content = content.replace(
    'await _notificationManager.deleteNotification(',
    'await ref.read(notificationProvider.notifier).deleteNotification('
)
content = content.replace(
    '_notificationManager.', 'ref.watch(notificationProvider).'
)
write_file(os.path.join(base, r'pages\customer\notifications_list_screen.dart'), content)

# ── 10. order_details_screen.dart — fix _orderManager and OrderChatScreen ─────
content = read_file(os.path.join(base, r'pages\customer\order_details_screen.dart'))
# Replace _orderManager usages with stubs
content = content.replace(
    '_orderManager.updateOrderStatus(',
    'ref.read(orderProvider.notifier).updateOrderStatus('
)
content = content.replace(
    '_orderManager.cancelOrder(',
    'ref.read(orderProvider.notifier).cancelOrder('
)
content = content.replace(
    '_orderManager.approveOrder(',
    'ref.read(orderProvider.notifier).approveOrder('
)
content = content.replace(
    '_orderManager.rejectOrder(',
    'ref.read(orderProvider.notifier).rejectOrder('
)
content = re.sub(r'\b_orderManager\.\w+', '/* TODO: _orderManager */', content)
# Convert to ConsumerStatefulWidget
if "flutter_riverpod" not in content:
    content = "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:madpractical/providers/order_provider.dart';\n" + content
content = content.replace(
    'class OrderDetailsScreen extends StatefulWidget',
    'class OrderDetailsScreen extends ConsumerStatefulWidget'
)
content = content.replace(
    'State<OrderDetailsScreen> createState() => _OrderDetailsScreenState()',
    'ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState()'
)
content = content.replace(
    'class _OrderDetailsScreenState extends State<OrderDetailsScreen>',
    'class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen>'
)
# Fix OrderChatScreen call - use the stub class
content = re.sub(
    r'OrderChatScreen\([^)]*\)',
    'OrderChatScreen(orderId: widget.order[\'id\'] ?? \'\', sellerId: widget.order[\'sellerId\'] ?? \'\')',
    content
)
write_file(os.path.join(base, r'pages\customer\order_details_screen.dart'), content)

# ── 11. seller_order_details_screen.dart — fix _orderManager + OrderChatScreen
content = read_file(os.path.join(base, r'pages\seller\seller_order_details_screen.dart'))
# Replace _orderManager usages
content = content.replace(
    '_orderManager.updateOrderStatus(',
    'ref.read(orderProvider.notifier).updateOrderStatus('
)
content = content.replace(
    '_orderManager.approveOrder(',
    'ref.read(orderProvider.notifier).approveOrder('
)
content = content.replace(
    '_orderManager.rejectOrder(',
    'ref.read(orderProvider.notifier).rejectOrder('
)
content = re.sub(r'\b_orderManager\.\w+', '/* TODO */', content)
# Convert to ConsumerStatefulWidget
if "flutter_riverpod" not in content:
    content = "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:madpractical/providers/order_provider.dart';\n" + content
content = content.replace(
    'class OrderDetailsScreen extends StatefulWidget',
    'class OrderDetailsScreen extends ConsumerStatefulWidget'
)
content = content.replace(
    'State<OrderDetailsScreen> createState() => _OrderDetailsScreenState()',
    'ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState()'
)
content = content.replace(
    'class _OrderDetailsScreenState extends State<OrderDetailsScreen>',
    'class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen>'
)
# Fix OrderChatScreen call
content = re.sub(
    r'OrderChatScreen\([^)]*\)',
    'OrderChatScreen(orderId: widget.order[\'id\'] ?? \'\', sellerId: widget.order[\'sellerId\'] ?? \'\')',
    content
)
write_file(os.path.join(base, r'pages\seller\seller_order_details_screen.dart'), content)

# ── 12. become_seller_screen.dart — fix syntax errors ────────────────────────
content = read_file(os.path.join(base, r'pages\profile\become_seller_screen.dart'))
# Fix the null /* TODO */ syntax errors - replace with proper values
content = re.sub(r'null /\* TODO[^*]*\*/', 'null', content)
content = re.sub(r"'' /\* TODO[^*]*\*/", "''", content)
# Fix _userManager references that may remain
content = re.sub(r'\b_userManager\.\w+', "''", content)
write_file(os.path.join(base, r'pages\profile\become_seller_screen.dart'), content)

# ── 13. edit_profile_screen.dart — fix syntax errors + service classes ────────
content = read_file(os.path.join(base, r'pages\profile\edit_profile_screen.dart'))
# Fix the null /* TODO */ syntax errors
content = re.sub(r'null /\* TODO[^*]*\*/', 'null', content)
content = re.sub(r"'' /\* TODO[^*]*\*/", "''", content)
# Fix _userManager remaining references
content = re.sub(r'\b_userManager\.\w+', "''", content)
# Fix FirebaseAuthService class at lines 107, 114
content = re.sub(r'\bFirebaseAuthService\b', 'AuthService', content)
content = re.sub(r'\bFirebaseStorageService\b', 'StorageService', content)
write_file(os.path.join(base, r'pages\profile\edit_profile_screen.dart'), content)

print("All fixes in script 3 applied!")
