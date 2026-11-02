#!/usr/bin/env python3
import os
import shutil

def get_home_dir():
    return os.environ.get('USERPROFILE') or os.environ.get('HOME') or os.path.expanduser('~')

def main():
    home = get_home_dir()
    target_dirs = [
        os.path.join(home, '.antigravity-ide', 'extensions'),
        os.path.join(home, '.antigravity', 'extensions'),
        os.path.join(home, '.vscode', 'extensions'),
        os.path.join(home, '.cursor', 'extensions')
    ]

    print("Removing BlaiseVue VS Code extension...")
    removed = 0
    for base in target_dirs:
        if os.path.isdir(base):
            try:
                for entry in os.listdir(base):
                    if entry.startswith('blaisevue.blaisevue-vscode') or entry == 'blaisevue-vscode':
                        full_path = os.path.join(base, entry)
                        shutil.rmtree(full_path, ignore_errors=True)
                        print(f"Removed: {full_path}")
                        removed += 1
            except OSError:
                pass

    if removed > 0:
        print("BlaiseVue VS Code extension removed successfully.")
    else:
        print("No installed BlaiseVue extension found to remove.")

if __name__ == '__main__':
    main()
