import re
import os

base = r'c:\Users\AMINAH NAKAZIBWE\Desktop\Campus_Cart-Mobile-App-Flutter-\lib'

def fix_file(path, replacements):
    """Apply list of (old, new) string replacements to a file."""
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    original = content
    for old, new in replacements:
        content = content.replace(old, new)
    if content != original:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'FIXED: {path}')
    else:
        print(f'NO CHANGE: {path}')

# 1. sign_up_screen.dart - remove UserManager import and usage
fix_file(os.path.join(base, r'pages\auth\sign_up_screen.dart'), [
    ("import 'package:madpractical/services/managers/user_manager.dart';\n", ''),
    ("""      // Update user manager
      final userManager = UserManager();
      userManager.updateProfile(
        userId: result['user']?.uid,
        name: name,
        email: email,
        phone: '',
        role: _selectedRole,
      );

""", ''),
])

# 2. admin_dashboard_screen.dart - remove UserManager field
fix_file(os.path.join(base, r'pages\admin\admin_dashboard_screen.dart'), [
    ("  final UserManager _userManager = UserManager();\n  \n", '  '),
    ("  final UserManager _userManager = UserManager();\n", ''),
])

# 3. seller_orders_screen.dart - remove UserManager, use authService only
fix_file(os.path.join(base, r'pages\seller\seller_orders_screen.dart'), [
    ("  final UserManager _userManager = UserManager();\n", ''),
    ("    final uid = _userManager.userId ?? _authService.currentUser?.uid;",
     "    final uid = _authService.currentUser?.uid;"),
])

# 4. my_orders_screen.dart - replace FirebaseAuthService, remove UserManager, DatabaseService
fix_file(os.path.join(base, r'pages\customer\my_orders_screen.dart'), [
    ("  final _authService = FirebaseAuthService();\n", "  final _authService = AuthService();\n"),
    ("  final _userManager = UserManager();\n", ''),
    ("  final _db = DatabaseService();\n", ''),
    ("    final uid = _userManager.userId ?? _authService.currentUser?.uid;",
     "    final uid = _authService.currentUser?.uid;"),
    ("    final cached = await _db.getCachedOrders(uid);\n",
     "    // Cache loading removed - using Firestore stream directly\n"),
])

# 5. seller_order_details_screen.dart - remove OrderManager, fix order_chat_screen import
fix_file(os.path.join(base, r'pages\seller\seller_order_details_screen.dart'), [
    ("import 'package:madpractical/pages/customer/order_chat_screen.dart';\n", ''),
    ("  final OrderManager _orderManager = OrderManager();\n", ''),
    ("  @override\n  void initState() {\n    super.initState();\n  }\n", 
     "  @override\n  void initState() {\n    super.initState();\n  }\n"),
])

# 6. order_details_screen.dart - remove OrderManager, fix import
fix_file(os.path.join(base, r'pages\customer\order_details_screen.dart'), [
    ("import 'package:madpractical/pages/customer/order_chat_screen.dart';\n", ''),
    ("  final OrderManager _orderManager = OrderManager();\n\n  @override\n  void initState() {\n    super.initState();\n    _orderManager.addListener(_onOrderChanged);\n  }\n\n  @override\n  void dispose() {\n    _orderManager.removeListener(_onOrderChanged);\n    super.dispose();\n  }\n\n  void _onOrderChanged() {\n    setState(() {});\n  }\n",
     "  @override\n  void initState() {\n    super.initState();\n  }\n"),
])

# 7. notifications_list_screen.dart - remove NotificationManager
fix_file(os.path.join(base, r'pages\customer\notifications_list_screen.dart'), [
    ("  final NotificationManager _notificationManager = NotificationManager();\n\n  @override\n  void initState() {\n    super.initState();\n    _notificationManager.addListener(_onNotificationsChanged);\n  }\n\n  @override\n  void dispose() {\n    _notificationManager.removeListener(_onNotificationsChanged);\n    super.dispose();\n  }\n\n  void _onNotificationsChanged() {\n    setState(() {});\n  }\n",
     "  @override\n  void initState() {\n    super.initState();\n  }\n"),
])

print("All fixes applied!")
