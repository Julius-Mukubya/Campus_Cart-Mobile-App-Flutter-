import os, re

pages_dir = "lib/pages"

# These AppColors are now dynamic (non-const)
dynamic_colors = ['AppColors.background', 'AppColors.cards', 'AppColors.text', 
                  'AppColors.secondaryText', 'AppColors.secondary']

def fix_file(fpath):
    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()
    original = content

    # Remove const from TextStyle(...) that contains a dynamic color
    for color in dynamic_colors:
        escaped = re.escape(color)
        # const TextStyle( ... dynamic_color ... )
        content = re.sub(r'\bconst\s+(TextStyle\([^)]*?' + escaped + r'[^)]*?\))', r'\1', content)
        # const Text('...', style: TextStyle(...dynamic...))  
        # Just remove const from TextStyle specifically
        content = re.sub(r'const\s+(TextStyle\()', r'\1', content)

    # Remove const from Icon(...) with dynamic color
    for color in dynamic_colors:
        escaped = re.escape(color)
        content = re.sub(r'\bconst\s+(Icon\([^)]*?' + escaped + r'[^)]*?\))', r'\1', content)

    if content != original:
        with open(fpath, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

updated = 0
for root, dirs, files in os.walk(pages_dir):
    for fname in files:
        if fname.endswith('.dart'):
            if fix_file(os.path.join(root, fname)):
                print(f"Fixed: {fname}")
                updated += 1

print(f"\nTotal: {updated} files")
