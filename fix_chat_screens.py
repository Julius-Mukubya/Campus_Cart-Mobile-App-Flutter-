import os
import re

base = r'c:\Users\AMINAH NAKAZIBWE\Desktop\Campus_Cart-Mobile-App-Flutter-\lib'

FIXED_OPEN_CHAT = (
    "void _openOrderChat() {\n"
    "    Navigator.push(\n"
    "      context,\n"
    "      MaterialPageRoute(\n"
    "        builder: (context) => OrderChatScreen(\n"
    "          orderId: widget.order['id'] ?? '',\n"
    "          sellerId: widget.order['sellerId'] ?? '',\n"
    "        ),\n"
    "      ),\n"
    "    );\n"
    "  }"
)

files = [
    os.path.join(base, r'pages\customer\order_details_screen.dart'),
    os.path.join(base, r'pages\seller\seller_order_details_screen.dart'),
]

for path in files:
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Replace the entire _openOrderChat function using DOTALL
    fixed = re.sub(
        r'void _openOrderChat\(\) \{.*?\n  \}',
        FIXED_OPEN_CHAT,
        content,
        flags=re.DOTALL
    )

    if fixed != content:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(fixed)
        print(f'FIXED: {os.path.basename(path)}')
    else:
        # Try a broader match
        m = re.search(r'void _openOrderChat', content)
        if m:
            print(f'NO MATCH in {os.path.basename(path)}, found at pos {m.start()}')
            print(repr(content[m.start():m.start()+250]))
        else:
            print(f'FUNCTION NOT FOUND in {os.path.basename(path)}')

# Also add missing import for OrderChatScreen in both files
for path in files:
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    import_line = "import 'package:madpractical/pages/customer/order_chat_screen.dart';\n"
    if 'order_chat_screen.dart' not in content:
        # Add after first import
        first_import = content.find("import '")
        if first_import != -1:
            content = content[:first_import] + import_line + content[first_import:]
            with open(path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f'ADDED import to {os.path.basename(path)}')

print("Done!")
