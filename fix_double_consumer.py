import os
import re

base = r'c:\Users\AMINAH NAKAZIBWE\Desktop\Campus_Cart-Mobile-App-Flutter-\lib'

files = [
    r'pages\customer\checkout_screen.dart',
    r'pages\customer\notifications_list_screen.dart',
    r'pages\customer\order_details_screen.dart',
    r'pages\seller\seller_order_details_screen.dart',
]

for rel in files:
    path = os.path.join(base, rel)
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    # Fix ConsumerConsumerState → ConsumerState
    content = content.replace('ConsumerConsumerState<', 'ConsumerState<')
    # Fix ConsumerConsumerStatefulWidget → ConsumerStatefulWidget
    content = content.replace('ConsumerConsumerStatefulWidget', 'ConsumerStatefulWidget')
    # Remove orphan _authService field in checkout_screen
    content = re.sub(r'\n  final _authService = AuthService\(\);\n', '\n', content)
    # Remove unused AuthService import if present
    content = re.sub(r"import '.*auth_service.dart';\n", '', content)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'FIXED: {os.path.basename(path)}')

print('Done!')
