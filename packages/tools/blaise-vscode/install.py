#!/usr/bin/env python3
import os
import sys
import json
import shutil
import subprocess

def get_home_dir():
    return os.environ.get('USERPROFILE') or os.environ.get('HOME') or os.path.expanduser('~')

def main():
    source_dir = os.path.dirname(os.path.abspath(__file__))
    pkg_json_path = os.path.join(source_dir, 'package.json')
    
    version = '4.4.0'
    if os.path.isfile(pkg_json_path):
        try:
            with open(pkg_json_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                version = data.get('version', version)
        except Exception:
            pass

    folder_name = f"blaisevue.blaisevue-vscode-{version}"
    home = get_home_dir()
    target_dirs = [
        os.path.join(home, '.antigravity-ide', 'extensions'),
        os.path.join(home, '.antigravity', 'extensions'),
        os.path.join(home, '.vscode', 'extensions'),
        os.path.join(home, '.cursor', 'extensions')
    ]

    print("=============================================")
    print(f"  BlaiseVue {version} Extension Installer     ")
    print("=============================================\n")

    # Optional: package vsix if npx vsce is available
    print("Packaging standalone .vsix (if npx vsce available)...")
    try:
        subprocess.run(['npx', '@vscode/vsce', 'package', '--no-git-tag-version', '--allow-missing-repository'],
                       cwd=source_dir, check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        pass

    deployed_count = 0
    items_to_copy = [
        'package.json',
        'language-configuration.json',
        'README.md',
        'LICENSE',
        'icon.png'
    ]
    dirs_to_copy = ['src', 'data', 'syntaxes', 'snippets']

    for base in target_dirs:
        if os.path.isdir(base):
            target_path = os.path.join(base, folder_name)
            print(f"Deploying extension to: {target_path}")
            if os.path.isdir(target_path):
                shutil.rmtree(target_path, ignore_errors=True)
            os.makedirs(target_path, exist_ok=True)

            for item in items_to_copy:
                src_item = os.path.join(source_dir, item)
                if os.path.isfile(src_item):
                    shutil.copy2(src_item, os.path.join(target_path, item))

            for d in dirs_to_copy:
                src_d = os.path.join(source_dir, d)
                if os.path.isdir(src_d):
                    shutil.copytree(src_d, os.path.join(target_path, d), dirs_exist_ok=True)

            print(f"Installed successfully in: {base}")
            deployed_count += 1

    if deployed_count == 0:
        # Default fallback to ~/.vscode/extensions
        fallback_base = os.path.join(home, '.vscode', 'extensions')
        os.makedirs(fallback_base, exist_ok=True)
        target_path = os.path.join(fallback_base, folder_name)
        print(f"Deploying extension to: {target_path}")
        if os.path.isdir(target_path):
            shutil.rmtree(target_path, ignore_errors=True)
        os.makedirs(target_path, exist_ok=True)

        for item in items_to_copy:
            src_item = os.path.join(source_dir, item)
            if os.path.isfile(src_item):
                shutil.copy2(src_item, os.path.join(target_path, item))

        for d in dirs_to_copy:
            src_d = os.path.join(source_dir, d)
            if os.path.isdir(src_d):
                shutil.copytree(src_d, os.path.join(target_path, d), dirs_exist_ok=True)
        print(f"Installed successfully in: {fallback_base}")

    print("\n---------------------------------------------")
    print("Installation completed successfully!")
    print("Reload window in your IDE (Ctrl+Shift+P -> Developer: Reload Window) to activate.")
    print("---------------------------------------------")

if __name__ == '__main__':
    main()
