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

# ── 1. checkout_screen.dart — remove unused user_provider import ──────────────
content = read_file(os.path.join(base, r'pages\customer\checkout_screen.dart'))
content = content.replace(
    "import 'package:madpractical/providers/user_provider.dart';\n", ''
)
# Fix unnecessary ?? null at line 469
content = re.sub(r'\bnull \?\? null\b', 'null', content)
write_file(os.path.join(base, r'pages\customer\checkout_screen.dart'), content)

# ── 2. Remove _onWishlistChanged/_onCartChanged from all screens ──────────────
screens = [
    r'pages\customer\home_screen.dart',
    r'pages\customer\product_details.dart',
    r'pages\customer\wishlist_screen.dart',
    r'pages\customer\categories_screen.dart',
]
for rel_path in screens:
    path = os.path.join(base, rel_path)
    content = read_file(path)
    # Remove the void _onWishlistChanged/CartChanged methods
    content = re.sub(r'\n  void _onWishlistChanged\(\) \{[^}]*\}', '', content)
    content = re.sub(r'\n  void _onCartChanged\(\) \{[^}]*\}', '', content)
    write_file(path, content)

# ── 3. Fix unnecessary_null_comparison in admin_dashboard_screen ──────────────
content = read_file(os.path.join(base, r'pages\admin\admin_dashboard_screen.dart'))
# Replace `'' == null` or `'' != null` conditions with false/true
content = re.sub(r"'' == null", 'false', content)
content = re.sub(r"'' != null", 'true', content)
write_file(os.path.join(base, r'pages\admin\admin_dashboard_screen.dart'), content)

# ── 4. Fix order_service.dart unnecessary casts ───────────────────────────────
content = read_file(os.path.join(base, r'services\order_service.dart'))
content = re.sub(r'\s+as\s+List<Map<String,\s*dynamic>>', '', content)
write_file(os.path.join(base, r'services\order_service.dart'), content)

# ── 5. become_seller_screen — fix dead code (if (pending) after false) ─────────
content = read_file(os.path.join(base, r'pages\profile\become_seller_screen.dart'))
# The dead code is the `if (pending)` block after `final pending = false;`
# Replace with a comment
content = re.sub(
    r'    final pending = false; // TODO:.*?\n    if \(pending\) \{.*?\n    \}',
    '    final pending = false; // TODO: check via SellerService in PHASE 2',
    content, flags=re.DOTALL
)
content = re.sub(
    r'    final approved = false; // TODO:.*?\n    if \(approved\) \{.*?\n    \}',
    '    final approved = false; // TODO: check via SellerService in PHASE 2',
    content, flags=re.DOTALL
)
write_file(os.path.join(base, r'pages\profile\become_seller_screen.dart'), content)

# ── 6. edit_profile_screen — remove unused downloadUrl var ────────────────────
content = read_file(os.path.join(base, r'pages\profile\edit_profile_screen.dart'))
# Find and remove the unused downloadUrl local variable declaration
content = re.sub(r'\s*final downloadUrl = .*?;\n', '\n', content)
write_file(os.path.join(base, r'pages\profile\edit_profile_screen.dart'), content)

print("Warning cleanup done!")
