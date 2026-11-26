#!/usr/bin/env python3
import os
import sys
import shutil
import subprocess

def main():
    source_dir = os.path.dirname(os.path.abspath(__file__))
    print("Packaging BlaiseVue VS Code extension into .vsix bundle...")
    npx_cmd = shutil.which('npx') or 'npx'
    is_win = sys.platform.startswith('win')
    try:
        res = subprocess.run([npx_cmd, '@vscode/vsce', 'package', '--no-git-tag-version', '--allow-missing-repository'],
                             cwd=source_dir, shell=is_win)
        if res.returncode == 0:
            print("VSIX packaged successfully!")
        else:
            print("Packaging failed or @vscode/vsce not installed.")
    except Exception as e:
        print(f"Error running npx vsce: {e}")

if __name__ == '__main__':
    main()
