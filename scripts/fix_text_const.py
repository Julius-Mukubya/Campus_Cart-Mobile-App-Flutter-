import os, re

def fix_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    original = content
    # Remove const from TextStyle that contains AppColors.text or AppColors.secondaryText
    content = re.sub(r'\bconst\s+(TextStyle\([^)]*?AppColors\.(?:text|secondaryText)[^)]*?\))', r'\1', content, flags=re.DOTALL)
    if content != original:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

count = 0
for root, dirs, files in os.walk('lib'):
    for fname in files:
        if fname.endswith('.dart'):
            if fix_file(os.path.join(root, fname)):
                print(f'Fixed: {fname}')
                count += 1
print(f'\nDone: {count} files updated')
