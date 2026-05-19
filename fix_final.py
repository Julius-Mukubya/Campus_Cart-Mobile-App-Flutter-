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

def show_lines(path, start, end):
    lines = read_file(path).splitlines()
    for i, line in enumerate(lines[start-1:end], start=start):
        print(f'{i}: {line}')

# Show problematic sections
print('=== become_seller_screen.dart lines 28-65 ===')
show_lines(os.path.join(base, r'pages\profile\become_seller_screen.dart'), 28, 65)
print()
print('=== edit_profile_screen.dart lines 150-165 ===')
show_lines(os.path.join(base, r'pages\profile\edit_profile_screen.dart'), 150, 165)
print()
print('=== checkout_screen.dart lines 33-50 ===')
show_lines(os.path.join(base, r'pages\customer\checkout_screen.dart'), 33, 50)
print()
print('=== order_details_screen.dart lines 593-605 ===')
show_lines(os.path.join(base, r'pages\customer\order_details_screen.dart'), 593, 605)
print()
print('=== notifications_list_screen.dart lines 50-95 ===')
show_lines(os.path.join(base, r'pages\customer\notifications_list_screen.dart'), 50, 95)
print()
print('=== wishlist_screen.dart lines 55-85 ===')
show_lines(os.path.join(base, r'pages\customer\wishlist_screen.dart'), 55, 85)
print()
print('=== my_orders_screen.dart lines 83-95 ===')
show_lines(os.path.join(base, r'pages\customer\my_orders_screen.dart'), 83, 95)
print()
print('=== seller_management_screen.dart lines 38-50 ===')
show_lines(os.path.join(base, r'pages\admin\seller_management_screen.dart'), 38, 50)
