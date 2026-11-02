#!/usr/bin/env python3
import os

def check_status():
    tool_dir = os.path.dirname(os.path.abspath(__file__))
    lpk_file = os.path.join(tool_dir, 'blaisevue_ide.lpk')
    
    if not os.path.isfile(lpk_file):
        print("Not found")
        return

    # Check for compiled state file or units
    compiled_lib = os.path.join(tool_dir, 'lib')
    has_compiled = False
    if os.path.isdir(compiled_lib):
        for root, dirs, files in os.walk(compiled_lib):
            if any(f.endswith(('.ppu', '.o', '.compiled')) for f in files):
                has_compiled = True
                break
                
    if has_compiled:
        print("Available (Compiled - Ready to Install in Lazarus)")
    else:
        print("Available (Run: bv extension install blaise-lazarus)")

if __name__ == '__main__':
    check_status()
