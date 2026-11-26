#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$ROOT_DIR/bin"
SRC_FILE="$BIN_DIR/bv.pas"
TARGET_NEW="$BIN_DIR/bv_new"
TARGET_BIN="$BIN_DIR/bv"
TARGET_BAK="$BIN_DIR/bv.bak"

echo "================================================================"
echo "  BlaiseVue CLI Native Build (Linux / macOS)"
echo "================================================================"

if [ ! -f "$SRC_FILE" ]; then
    echo "[ERROR] Source file not found: $SRC_FILE"
    exit 1
fi

FPC_EXE=""
if command -v fpc >/dev/null 2>&1; then
    FPC_EXE="$(command -v fpc)"
elif [ -x "/usr/bin/fpc" ]; then
    FPC_EXE="/usr/bin/fpc"
elif [ -x "/usr/local/bin/fpc" ]; then
    FPC_EXE="/usr/local/bin/fpc"
elif [ -x "/opt/homebrew/bin/fpc" ]; then
    FPC_EXE="/opt/homebrew/bin/fpc"
fi

if [ -z "$FPC_EXE" ]; then
    echo "[ERROR] Free Pascal Compiler (fpc) was not detected in PATH."
    echo "        Install FPC 3.2.2+ (e.g. 'sudo apt install fpc' or 'brew install fpc')."
    exit 1
fi

echo "  [+] FPC Compiler: $FPC_EXE"
echo "  [+] Compiling bin/bv.pas -> bin/bv_new ..."

rm -f "$TARGET_NEW"
(cd "$BIN_DIR" && "$FPC_EXE" -MObjFPC -Sh -O2 -obv_new bv.pas)
BUILD_RC=$?

if [ "$BUILD_RC" -eq 0 ] && [ -f "$TARGET_NEW" ]; then
    if [ -f "$TARGET_BIN" ]; then
        cp -f "$TARGET_BIN" "$TARGET_BAK"
        echo "  [BACKUP] Previous binary preserved at bin/bv.bak"
    fi
    mv -f "$TARGET_NEW" "$TARGET_BIN"
    chmod +x "$TARGET_BIN"
    chmod +x "$ROOT_DIR"/vendor/pas2js/pas2js-*/bin/{pas2js,compileserver,makestub,webidl2pas} 2>/dev/null || true
    echo ""
    echo "  [SUCCESS] BlaiseVue CLI built cleanly: bin/bv"
    "$TARGET_BIN" --version
    echo ""
    echo "  Next step (if not already in PATH):"
    echo "    export PATH=\"$BIN_DIR:\$PATH\""
    echo "    bv doctor"
    echo "================================================================"
    exit 0
else
    rm -f "$TARGET_NEW"
    echo ""
    echo "  [ERROR] Compilation failed. See Free Pascal output above."
    if [ -f "$TARGET_BIN" ]; then
        echo "  [SAFETY] Existing bin/bv was NOT modified and remains functional."
    fi
    echo "================================================================"
    exit 1
fi
