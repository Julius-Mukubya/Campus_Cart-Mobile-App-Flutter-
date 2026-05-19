import subprocess, sys

scripts = [
    'fix_managers2.py',
    'fix_managers3.py',
    'fix_final.py',
    'fix_final2.py',
    'fix_final3.py',
    'fix_final4.py',
    'fix_chat_screens.py',
]

base = r'c:\Users\AMINAH NAKAZIBWE\Desktop\Campus_Cart-Mobile-App-Flutter-'
for s in scripts:
    print(f'\n========== {s} ==========')
    r = subprocess.run([sys.executable, f'{base}\\{s}'], capture_output=True, text=True)
    print(r.stdout)
    if r.stderr:
        print('STDERR:', r.stderr)
print('ALL DONE')
