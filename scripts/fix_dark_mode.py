import os
import re

pages_dir = "lib/pages"

replacements = [
    # Scaffold/AppBar backgrounds - remove explicit override so theme takes over
    (r'backgroundColor: AppColors\.background,', 'backgroundColor: Theme.of(context).scaffoldBackgroundColor,'),
    # White containers -> surface color
    (r'color: AppColors\.white,', 'color: Theme.of(context).cardColor,'),
    (r'fillColor: AppColors\.white,', 'fillColor: Theme.of(context).cardColor,'),
    # Cards/secondary containers
    (r'color: AppColors\.cards,', 'color: Theme.of(context).cardColor,'),
    (r'color: AppColors\.secondary,', 'color: Theme.of(context).cardColor,'),
    # Text colors - remove const and use theme
    (r'const TextStyle\((\s*\n?\s*)color: AppColors\.text\b', r'TextStyle(\1color: Theme.of(context).textTheme.bodyLarge!.color'),
    (r'const TextStyle\((\s*\n?\s*)color: AppColors\.secondaryText\b', r'TextStyle(\1color: Theme.of(context).textTheme.bodyMedium!.color'),
    # Non-const text colors
    (r'color: AppColors\.text\b(?!\s*\))', 'color: Theme.of(context).textTheme.bodyLarge!.color'),
    (r'color: AppColors\.secondaryText\b(?!\s*\))', 'color: Theme.of(context).textTheme.bodyMedium!.color'),
]

updated = 0
for root, dirs, files in os.walk(pages_dir):
    for fname in files:
        if not fname.endswith('.dart'):
            continue
        fpath = os.path.join(root, fname)
        with open(fpath, 'r', encoding='utf-8') as f:
            content = f.read()
        original = content
        for pattern, replacement in replacements:
            content = re.sub(pattern, replacement, content)
        if content != original:
            with open(fpath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Updated: {fpath}")
            updated += 1

print(f"\nTotal files updated: {updated}")
