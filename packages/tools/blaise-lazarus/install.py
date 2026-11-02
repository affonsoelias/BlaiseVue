#!/usr/bin/env python3
import os
import shutil
import subprocess

def find_lazbuild():
    cmd = shutil.which('lazbuild')
    if cmd:
        return cmd
    candidates = [
        r'C:\lazarus\lazbuild.exe',
        r'C:\lazarus_ide\lazbuild.exe',
        '/usr/bin/lazbuild',
        '/usr/local/bin/lazbuild'
    ]
    for c in candidates:
        if os.path.isfile(c):
            return c
    return None

def main():
    tool_dir = os.path.dirname(os.path.abspath(__file__))
    lpk_file = os.path.join(tool_dir, 'blaisevue_ide.lpk')

    print("=== BlaiseVue Lazarus IDE Package ===")
    print(f"Package: {lpk_file}\n")

    lazbuild = find_lazbuild()
    if lazbuild:
        print(f"Compiling package with lazbuild ({lazbuild})...")
        res = subprocess.run([lazbuild, lpk_file])
        if res.returncode == 0:
            print("\nPackage compiled successfully!")
        else:
            print(f"\nlazbuild exited with code {res.returncode}")
    else:
        print("Note: lazbuild executable not found on PATH or standard directories.")

    print("\nTo complete installation into Lazarus IDE:")
    print("  1. Open Lazarus IDE")
    print("  2. Go to: Package -> Open Package File (.lpk)")
    print(f"  3. Select: {lpk_file}")
    print('  4. Click "Use" -> "Install" and restart Lazarus')

if __name__ == '__main__':
    main()
