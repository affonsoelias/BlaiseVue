#!/usr/bin/env python3
import os
import subprocess

def main():
    source_dir = os.path.dirname(os.path.abspath(__file__))
    print("Packaging BlaiseVue VS Code extension into .vsix bundle...")
    res = subprocess.run(['npx', '@vscode/vsce', 'package', '--no-git-tag-version', '--allow-missing-repository'],
                         cwd=source_dir)
    if res.returncode == 0:
        print("VSIX packaged successfully!")
    else:
        print("Packaging failed or npx/@vscode/vsce not installed.")

if __name__ == '__main__':
    main()
