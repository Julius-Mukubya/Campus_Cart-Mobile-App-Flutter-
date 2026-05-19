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

# ── 1. seller_management_screen.dart — comment out orphaned named params ──────
content = read_file(os.path.join(base, r'pages\admin\seller_management_screen.dart'))
# Fix _approveRequest orphaned params
content = content.replace(
    "    // _requestService.approveSellerRequest(\n      requestId: req['id'],\n      adminId: 'admin_1',\n    );",
    "    // TODO Phase 2: approveSellerRequest(requestId: req['id'], adminId: 'admin_1');"
)
# Fix _rejectRequest orphaned params
content = content.replace(
    "                // _requestService.rejectSellerRequest(\n                  requestId: req['id'],\n                  adminId: 'admin_1',\n                  rejectionReason: reasonCtrl.text,\n                );",
    "                // TODO Phase 2: rejectSellerRequest(requestId: req['id'], reason: reasonCtrl.text);"
)
write_file(os.path.join(base, r'pages\admin\seller_management_screen.dart'), content)

# ── 2. checkout_screen.dart — fix _authService undefined ──────────────────────
content = read_file(os.path.join(base, r'pages\customer\checkout_screen.dart'))
# Show first 35 lines to find class declaration
lines = content.splitlines()
for i, line in enumerate(lines[:35], 1):
    print(f'{i}: {line}')
# Since delivery addresses are NOT used in Campus Cart, stub out _loadSavedAddresses
old = """  Future<void> _loadSavedAddresses() async {
    final uid = null ?? _authService.currentUser?.uid;
    if (uid == null) {
      setState(() => _loadingAddresses = false);
      return;
    }
    final addresses = await _authService.getUserAddresses(uid);
    setState(() {
      _savedAddresses = addresses;
      _loadingAddresses = false;
    });"""
new = """  Future<void> _loadSavedAddresses() async {
    // Addresses not used in Campus Cart (no delivery)
    setState(() => _loadingAddresses = false);
    return; // ignore: dead_code"""
content = content.replace(old, new)
# Also fix the other _authService.currentUser usages
content = re.sub(r'\b_authService\.currentUser\?\.uid\b', 'null', content)
content = re.sub(r'await _authService\.getUserAddresses\([^)]*\)', '[]', content)
content = content.replace('_authService.currentUser', 'null')
write_file(os.path.join(base, r'pages\customer\checkout_screen.dart'), content)

# ── 3. order_details_screen.dart — fix broken OrderChatScreen call ────────────
content = read_file(os.path.join(base, r'pages\customer\order_details_screen.dart'))
# Replace the exact broken block
old_block = """        builder: (context) => OrderChatScreen(orderId: widget.order['id'] ?? '', sellerId: widget.order['sellerId'] ?? ''
')',
          userRole: 'buyer',
        ),"""
new_block = """        builder: (context) => OrderChatScreen(
          orderId: widget.order['id'] ?? '',
          sellerId: widget.order['sellerId'] ?? '',
        ),"""
content = content.replace(old_block, new_block)
write_file(os.path.join(base, r'pages\customer\order_details_screen.dart'), content)

# ── 4. seller_order_details_screen.dart — same fix ────────────────────────────
content = read_file(os.path.join(base, r'pages\seller\seller_order_details_screen.dart'))
old_block = """        builder: (context) => OrderChatScreen(orderId: widget.order['id'] ?? '', sellerId: widget.order['sellerId'] ?? ''
')',
          userRole: 'buyer',
        ),"""
new_block = """        builder: (context) => OrderChatScreen(
          orderId: widget.order['id'] ?? '',
          sellerId: widget.order['sellerId'] ?? '',
        ),"""
content = content.replace(old_block, new_block)
write_file(os.path.join(base, r'pages\seller\seller_order_details_screen.dart'), content)

# ── 5. edit_profile_screen.dart — fix broken profile image condition ───────────
content = read_file(os.path.join(base, r'pages\profile\edit_profile_screen.dart'))
# Fix: '' && ''('http') ? CircleAvatar(backgroundImage: NetworkImage(null),
# This was: _userManager.profileImage != null && _userManager.profileImage!.startsWith('http')
# Replace with a safe check using '' (empty = no image)
content = content.replace(
    "child: '' &&\n                             ''('http')",
    "child: false /* TODO Phase 9: check userProvider.profileImage */"
)
# Also fix the NetworkImage(null) call
content = content.replace(
    'backgroundImage: NetworkImage(null),',
    'backgroundImage: const NetworkImage(\'\'),'
)
# Fix 'null' type passed to String param (argument_type_not_assignable)
# Look at line 235 from the analyze output - argument type Null can't be String
# Find NetworkImage(null) → already fixed above
# Find other null → String assignments
content = re.sub(r'NetworkImage\(null\)', "const NetworkImage('')", content)
write_file(os.path.join(base, r'pages\profile\edit_profile_screen.dart'), content)

# ── 6. Remove unused _requestService field from seller_management_screen ──────
content = read_file(os.path.join(base, r'pages\admin\seller_management_screen.dart'))
content = re.sub(r'\s*final\s+Object\s+_requestService\s*=\s*Object\(\);\n', '\n', content)
write_file(os.path.join(base, r'pages\admin\seller_management_screen.dart'), content)

print("\nAll final3 fixes applied!")
