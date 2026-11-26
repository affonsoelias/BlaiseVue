#!/usr/bin/env python3
import os

def get_lazarus_config_dirs():
    dirs = []
    local_appdata = os.environ.get('LOCALAPPDATA')
    if local_appdata:
        dirs.append(os.path.join(local_appdata, 'lazarus'))
    appdata = os.environ.get('APPDATA')
    if appdata:
        dirs.append(os.path.join(appdata, 'lazarus'))
    home = os.environ.get('HOME') or os.path.expanduser('~')
    dirs.append(os.path.join(home, '.lazarus'))
    return dirs

def is_installed_in_lazarus():
    for d in get_lazarus_config_dirs():
        static_inc = os.path.join(d, 'staticpackages.inc')
        if os.path.isfile(static_inc):
            try:
                with open(static_inc, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                    if 'blaisevue_ide' in content:
                        return True
            except OSError:
                pass
        pkg_files = os.path.join(d, 'packagefiles.xml')
        if os.path.isfile(pkg_files):
            try:
                with open(pkg_files, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                    if 'blaisevue_ide.lpk' in content:
                        return True
            except OSError:
                pass
    return False

def check_status():
    tool_dir = os.path.dirname(os.path.abspath(__file__))
    lpk_file = os.path.join(tool_dir, 'blaisevue_ide.lpk')
    
    if not os.path.isfile(lpk_file):
        print("Not found")
        return

    if is_installed_in_lazarus():
        print("Installed (Lazarus IDE)")
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
        print("Compiled (Ready to Install in Lazarus)")
    else:
        print("Available (Run: bv tool install blaise-lazarus)")

if __name__ == '__main__':
    check_status()
