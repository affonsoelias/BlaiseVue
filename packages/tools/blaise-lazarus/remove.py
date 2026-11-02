#!/usr/bin/env python3
import os
import shutil

def main():
    tool_dir = os.path.dirname(os.path.abspath(__file__))
    lib_dir = os.path.join(tool_dir, 'lib')
    print("Cleaning BlaiseVue Lazarus package build artifacts...")
    if os.path.isdir(lib_dir):
        shutil.rmtree(lib_dir, ignore_errors=True)
        print("Cleaned lib/ directory.")
    print("To uninstall from Lazarus IDE:")
    print("  1. Open Lazarus IDE")
    print("  2. Go to: Package -> Install/Uninstall Packages...")
    print('  3. In "Installed Packages", select "blaisevue_ide" and click "Uninstall selection"')
    print('  4. Click "Save and rebuild IDE"')

if __name__ == '__main__':
    main()
