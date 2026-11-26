#!/usr/bin/env python3
import os
import sys

def get_home_dir():
    return os.environ.get('USERPROFILE') or os.environ.get('HOME') or os.path.expanduser('~')

def check_status():
    home = get_home_dir()
    targets = [
        os.path.join(home, '.vscode', 'extensions'),
        os.path.join(home, '.antigravity', 'extensions'),
        os.path.join(home, '.antigravity-ide', 'extensions'),
        os.path.join(home, '.cursor', 'extensions')
    ]
    
    for t in targets:
        if os.path.isdir(t):
            try:
                for entry in os.listdir(t):
                    if entry.startswith('blaisevue.blaisevue-vscode-'):
                        version = entry.replace('blaisevue.blaisevue-vscode-', '')
                        print("Installed (VS Code / IDE)")
                        return
                    elif entry == 'blaisevue-vscode':
                        print("Installed (IDE)")
                        return
            except OSError:
                pass
                
    print("Available (Run: bv tool install blaise-vscode)")

if __name__ == '__main__':
    check_status()
