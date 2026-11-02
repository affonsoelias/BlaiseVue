#!/usr/bin/env python3
import os

def check_status():
    tool_dir = os.path.dirname(os.path.abspath(__file__))
    manifest = os.path.join(tool_dir, 'manifest.json')
    if os.path.isfile(manifest):
        print("Available (Firefox / Chrome / Edge)")
    else:
        print("Not found")

if __name__ == '__main__':
    check_status()
