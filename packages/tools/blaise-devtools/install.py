#!/usr/bin/env python3
import os

def main():
    tool_dir = os.path.dirname(os.path.abspath(__file__))
    manifest_path = os.path.join(tool_dir, 'manifest.json')

    print("=== BlaiseVue Browser DevTools Extension ===")
    print(f"Directory: {tool_dir}\n")

    print("To install in Google Chrome / Brave / Edge:")
    print("  1. Open your browser and navigate to: chrome://extensions")
    print('  2. Enable "Developer mode" (toggle in the top-right corner)')
    print('  3. Click "Load unpacked" (top-left button)')
    print(f"  4. Select the folder: {tool_dir}\n")

    print("To install in Mozilla Firefox:")
    print("  1. Open Firefox and navigate to: about:debugging#/runtime/this-firefox")
    print('  2. Click "Load Temporary Add-on..."')
    print(f"  3. Select the file: {manifest_path}\n")

    print('Once loaded, open your BlaiseVue app, press F12, and click the "BlaiseVue" tab!')

if __name__ == '__main__':
    main()
