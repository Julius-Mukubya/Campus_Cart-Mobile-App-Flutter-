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

# ── 1. become_seller_screen.dart ─────────────────────────────────────────────
content = read_file(os.path.join(base, r'pages\profile\become_seller_screen.dart'))
# Fix: commented service calls leave orphaned variable assignments
content = content.replace(
    '    final pending = // _sellerRequestService.hasPendingSellerRequest(userId);',
    '    final pending = false; // TODO: check via SellerService'
)
content = content.replace(
    '    final approved = // _sellerRequestService.hasApprovedSellerRequest(userId);',
    '    final approved = false; // TODO: check via SellerService'
)
# Fix: orphaned named params from commented-out function call
content = content.replace(
    """      // await // _sellerRequestService.submitSellerRequest(
        userId: null ?? '',
        userName: '',
        userEmail: '',
        userPhone: '',
      );""",
    """      // TODO: submit seller request via SellerService in PHASE 2
      // await sellerService.submitSellerRequest(userId, userName, userEmail, ...);"""
)
write_file(os.path.join(base, r'pages\profile\become_seller_screen.dart'), content)

# ── 2. edit_profile_screen.dart ───────────────────────────────────────────────
content = read_file(os.path.join(base, r'pages\profile\edit_profile_screen.dart'))
# Fix: `// ''(  name: ...,  email: ...,  phone: ...,  );` - orphaned params
content = content.replace(
    """    // ''(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
    );""",
    """    // TODO: save profile via userProvider in PHASE 9
    // ref.read(userProvider.notifier).updateProfile(name: ..., email: ..., phone: ...);"""
)
# Fix null dereference errors - replace null.xxx with ''
content = re.sub(r'\bnull\.(\w+)', "''", content)
# Fix argument type 'Null' -> use '' explicitly
content = content.replace("userId: null,", "userId: '',")
write_file(os.path.join(base, r'pages\profile\edit_profile_screen.dart'), content)

# ── 3. checkout_screen.dart ───────────────────────────────────────────────────
content = read_file(os.path.join(base, r'pages\customer\checkout_screen.dart'))
# Fix 'nulluserId' → 'null' (null was merged with 'userId')
content = content.replace('nulluserId', 'null')
# Add _authService field to CheckoutState if missing
marker = 'class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {'
if '_authService' not in content:
    content = content.replace(
        marker,
        marker + '\n  final _authService = AuthService();\n'
    )
# Fix cartItems → items (CartState has .items not .cartItems)
content = content.replace('ref.watch(cartProvider).cartItems', 'ref.watch(cartProvider).items')
content = content.replace('ref.read(cartProvider).cartItems', 'ref.watch(cartProvider).items')
# Fix clearCart - it's on the notifier
content = content.replace(
    'ref.read(cartProvider.notifier).clearCart()',
    'ref.read(cartProvider.notifier).clearCart()'
)
# clearCart() was replaced as "ref.watch(cartProvider).clearCart()" — fix
content = content.replace(
    'ref.watch(cartProvider).clearCart()',
    'ref.read(cartProvider.notifier).clearCart()'
)
write_file(os.path.join(base, r'pages\customer\checkout_screen.dart'), content)

# ── 4. order_details_screen.dart — fix broken OrderChatScreen call ────────────
content = read_file(os.path.join(base, r'pages\customer\order_details_screen.dart'))
# Fix the malformed OrderChatScreen call (regex left a dangling quote)
bad_chat = r"OrderChatScreen\(orderId: widget\.order\['id'\] \?\? '', sellerId: widget\.order\['sellerId'\] \?\? ''\s*'\)',.*?userRole: '.*?',.*?\),.*?\);"
content = re.sub(
    bad_chat,
    "OrderChatScreen(\n          orderId: widget.order['id'] ?? '',\n          sellerId: widget.order['sellerId'] ?? '',\n        ),\n      ),\n    );",
    content, flags=re.DOTALL
)
# Also try simpler pattern
content = re.sub(
    r"OrderChatScreen\(orderId: widget\.order\['id'\] \?\? '', sellerId: widget\.order\['sellerId'\] \?\? ''\s*'\)',",
    "OrderChatScreen(orderId: widget.order['id'] ?? '', sellerId: widget.order['sellerId'] ?? ''),",
    content
)
write_file(os.path.join(base, r'pages\customer\order_details_screen.dart'), content)

# ── 5. seller_order_details_screen.dart — same fix ────────────────────────────
content = read_file(os.path.join(base, r'pages\seller\seller_order_details_screen.dart'))
content = re.sub(
    r"OrderChatScreen\(orderId: widget\.order\['id'\] \?\? '', sellerId: widget\.order\['sellerId'\] \?\? ''\s*'\)',",
    "OrderChatScreen(orderId: widget.order['id'] ?? '', sellerId: widget.order['sellerId'] ?? ''),",
    content
)
write_file(os.path.join(base, r'pages\seller\seller_order_details_screen.dart'), content)

# ── 6. notifications_list_screen.dart — use notifier not state ────────────────
content = read_file(os.path.join(base, r'pages\customer\notifications_list_screen.dart'))
# Fix: markAsRead etc. are on the notifier, not on the state
content = content.replace(
    'ref.watch(notificationProvider).markAsRead(',
    'ref.read(notificationProvider.notifier).markAsRead('
)
content = content.replace(
    'ref.watch(notificationProvider).markAllAsRead()',
    'ref.read(notificationProvider.notifier).markAllAsRead()'
)
content = content.replace(
    'ref.watch(notificationProvider).deleteNotification(',
    'ref.read(notificationProvider.notifier).deleteNotification('
)
content = content.replace(
    'ref.watch(notificationProvider).clearAll()',
    'ref.read(notificationProvider.notifier).clearAll()'
)
write_file(os.path.join(base, r'pages\customer\notifications_list_screen.dart'), content)

# ── 7. wishlist_screen.dart — fix wishlistItems → .items ─────────────────────
content = read_file(os.path.join(base, r'pages\customer\wishlist_screen.dart'))
# wishlistItems is not a getter on WishlistNotifier - use state.items
content = content.replace(
    'ref.read(wishlistProvider.notifier).wishlistItems',
    'ref.watch(wishlistProvider).items'
)
content = content.replace(
    'ref.watch(wishlistProvider.notifier).wishlistItems',
    'ref.watch(wishlistProvider).items'
)
write_file(os.path.join(base, r'pages\customer\wishlist_screen.dart'), content)

# ── 8. my_orders_screen.dart — fix await on non-future ───────────────────────
content = read_file(os.path.join(base, r'pages\customer\my_orders_screen.dart'))
# Remove the invalid 'await []'
content = content.replace('          await [];\n', '')
write_file(os.path.join(base, r'pages\customer\my_orders_screen.dart'), content)

# ── 9. seller_management_screen.dart — stub the screen properly ───────────────
# Read line count to understand structure
lines = read_file(os.path.join(base, r'pages\admin\seller_management_screen.dart')).splitlines()
print(f'seller_management_screen.dart has {len(lines)} lines')

content = read_file(os.path.join(base, r'pages\admin\seller_management_screen.dart'))
# Remove the ListenableBuilder that uses _requestService as Listenable
# Replace with a StatefulBuilder or ChangeNotifierProvider
# Simple fix: remove the ListenableBuilder wrapper
content = content.replace(
    'listenable: _requestService,\n              builder: (context, _) {',
    'listenable: ValueNotifier(null),\n              builder: (context, _) {'
)
# Fix method calls on Object type - stub them out
content = content.replace(
    '_requestService.getPendingRequests()',
    '[] /* TODO: SellerService.getPendingRequests() */'
)
content = content.replace(
    '_requestService.getApprovedRequests()',
    '[] /* TODO: SellerService.getApprovedRequests() */'
)
content = content.replace(
    '_requestService.getRejectedRequests()',
    '[] /* TODO: SellerService.getRejectedRequests() */'
)
content = content.replace(
    '_requestService.approveSellerRequest(',
    '// _requestService.approveSellerRequest('
)
content = content.replace(
    '_requestService.rejectSellerRequest(',
    '// _requestService.rejectSellerRequest('
)
write_file(os.path.join(base, r'pages\admin\seller_management_screen.dart'), content)

# ── 10. Fix warnings: remove _onWishlistChanged / _onCartChanged from categories ─
content = read_file(os.path.join(base, r'pages\customer\categories_screen.dart'))
content = re.sub(r'  void _onWishlistChanged\(\) \{[^}]*\}\n\n?', '', content)
content = re.sub(r'  void _onCartChanged\(\) \{[^}]*\}\n\n?', '', content)
write_file(os.path.join(base, r'pages\customer\categories_screen.dart'), content)

# ── 11. Fix simple warnings in models ─────────────────────────────────────────
for model_file in ['category_model.dart', 'review_model.dart']:
    path = os.path.join(base, 'models', model_file)
    content = read_file(path)
    # Fix unnecessary ? on dynamic
    content = re.sub(r'(dynamic)\?', r'\1', content)
    write_file(path, content)

# ── 12. Fix notification_repository unused import ─────────────────────────────
path = os.path.join(base, r'repositories\notification_repository.dart')
content = read_file(path)
content = content.replace("import 'package:path/path.dart';\n", '')
write_file(path, content)

# ── 13. Fix order_service unnecessary casts ───────────────────────────────────
path = os.path.join(base, r'services\order_service.dart')
content = read_file(path)
content = re.sub(r'\bas\s+List<Map<String,\s*dynamic>>', '', content)
write_file(path, content)

print("\nAll final fixes applied!")
