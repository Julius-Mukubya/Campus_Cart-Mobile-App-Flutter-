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

# ── 1. checkout_screen.dart ───────────────────────────────────────────────────
content = read_file(os.path.join(base, r'pages\customer\checkout_screen.dart'))

# Remove dead code after return; that references 'addresses'
content = content.replace(
    "    return; // ignore: dead_code\n    // Auto-select default address and prefill\n"
    "    final defaultAddr = addresses.firstWhere(\n"
    "      (a) => a['isDefault'] == true,\n"
    "      orElse: () => addresses.isNotEmpty ? addresses.first : <String, dynamic>{},\n"
    "    );\n"
    "    if (defaultAddr.isNotEmpty) {\n"
    "      _selectAddress(defaultAddr);\n"
    "    }\n"
    "  }",
    "    return; // Addresses not used (no delivery)\n  }"
)

# Stub out the _addAddress method that uses _authService.addUserAddress
content = re.sub(
    r'await _authService\.addUserAddress\(.*?\);',
    '// TODO Phase 9: await userService.addAddress(...);',
    content, flags=re.DOTALL
)

write_file(os.path.join(base, r'pages\customer\checkout_screen.dart'), content)

# ── 2. order_details_screen.dart — fix broken OrderChatScreen (multiline) ─────
content = read_file(os.path.join(base, r'pages\customer\order_details_screen.dart'))
# The broken line contains a real newline inside the string literal
content = re.sub(
    r"OrderChatScreen\(orderId: widget\.order\['id'\] \?\? '', sellerId: widget\.order\['sellerId'\] \?\? '\n'\)',\n\s*userRole: 'buyer',",
    "OrderChatScreen(\n          orderId: widget.order['id'] ?? '',\n          sellerId: widget.order['sellerId'] ?? '',\n        ),",
    content
)
write_file(os.path.join(base, r'pages\customer\order_details_screen.dart'), content)

# ── 3. seller_order_details_screen.dart — same fix ────────────────────────────
content = read_file(os.path.join(base, r'pages\seller\seller_order_details_screen.dart'))
content = re.sub(
    r"OrderChatScreen\(orderId: widget\.order\['id'\] \?\? '', sellerId: widget\.order\['sellerId'\] \?\? '\n'\)',\n\s*userRole: 'buyer',",
    "OrderChatScreen(\n          orderId: widget.order['id'] ?? '',\n          sellerId: widget.order['sellerId'] ?? '',\n        ),",
    content
)
write_file(os.path.join(base, r'pages\seller\seller_order_details_screen.dart'), content)

# ── 4. edit_profile_screen.dart — fix '' && ''('http') ───────────────────────
content = read_file(os.path.join(base, r'pages\profile\edit_profile_screen.dart'))
# Replace the broken ternary condition (note trailing space on first line)
content = re.sub(
    r"child: '' && \n\s*''[^\n]*\n",
    "child: false /* TODO Phase 9: profileImage != null && profileImage.startsWith('http') */\n",
    content
)
write_file(os.path.join(base, r'pages\profile\edit_profile_screen.dart'), content)

print("All final4 fixes applied!")
