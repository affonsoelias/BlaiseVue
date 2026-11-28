#!/usr/bin/env bash
set -euo pipefail

VERSION=""
OUT_DIR="dist"
SKIP_BUILD=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version=*) VERSION="${1#*=}" ;;
    --out-dir=*) OUT_DIR="${1#*=}" ;;
    --skip-build) SKIP_BUILD=1 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

if [[ -z "$VERSION" ]]; then
  if [[ -f "package.json" ]]; then
    VERSION="$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' package.json | head -n 1 || true)"
  fi
  VERSION="${VERSION:-0.1.0}"
fi
CLEAN_VERSION="${VERSION#v}"
CLEAN_VERSION="${CLEAN_VERSION#V}"

if [[ "$SKIP_BUILD" -eq 0 ]]; then
  if [[ -x "./build.sh" || -f "./build.sh" ]]; then
    chmod +x ./build.sh
    ./build.sh
  else
    (cd bin && fpc -MObjFPC -Sh -O2 -obv bv.pas)
  fi
fi

if [[ ! -f "bin/bv" ]]; then
  echo "Error: bin/bv not found" >&2
  exit 1
fi

UNAME_S="$(uname -s)"
case "$UNAME_S" in
  Darwin*) OS_NAME="macos" ;;
  Linux*)  OS_NAME="linux" ;;
  *)       OS_NAME="$(echo "$UNAME_S" | tr '[:upper:]' '[:lower:]')" ;;
esac

UNAME_M="$(uname -m)"
case "$UNAME_M" in
  x86_64|amd64) ARCH_NAME="x86_64" ;;
  arm64|aarch64) ARCH_NAME="aarch64" ;;
  *) ARCH_NAME="$UNAME_M" ;;
esac

case "${OS_NAME}-${ARCH_NAME}" in
  linux-x86_64)   PAS2JS_GLOB="pas2js-linux-x86_64*" ;;
  linux-aarch64)  PAS2JS_GLOB="pas2js-linux-aarch64*" ;;
  macos-x86_64)   PAS2JS_GLOB="pas2js-darwin-x86_64*" ;;
  macos-aarch64)  PAS2JS_GLOB="pas2js-darwin-aarch64*" ;;
  *)
    echo "Error: Unsupported platform ${OS_NAME}-${ARCH_NAME} for Pas2JS packaging." >&2
    exit 1
    ;;
esac

mkdir -p "$OUT_DIR"
ASSET_BASE="blaisevue-v${CLEAN_VERSION}-${OS_NAME}-${ARCH_NAME}"
STAGE_DIR="$OUT_DIR/_stage_${ASSET_BASE}"
rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR/bin" "$STAGE_DIR/vendor/pas2js"

# 1. CLI binary & helper scripts
cp "bin/bv" "$STAGE_DIR/bin/bv"
chmod +x "$STAGE_DIR/bin/bv"
for helper in dev-server.js studio-server.js; do
  if [[ -f "bin/$helper" ]]; then
    cp "bin/$helper" "$STAGE_DIR/bin/$helper"
  fi
done
if [[ -d "bin/studio" ]]; then
  cp -R "bin/studio" "$STAGE_DIR/bin/studio"
fi

# 2. Core framework, official packages, templates & Zephyr
for dir in core templates; do
  if [[ -d "$dir" ]]; then
    cp -R "$dir" "$STAGE_DIR/$dir"
  fi
done
if [[ -d "packages/core" ]]; then
  mkdir -p "$STAGE_DIR/packages"
  cp -R "packages/core" "$STAGE_DIR/packages/core"
fi
if [[ -d "vendor/zephyr" ]]; then
  cp -R "vendor/zephyr" "$STAGE_DIR/vendor/zephyr"
fi

# 3. Matching platform Pas2JS distribution ONLY
PAS2JS_DIR="$(find vendor/pas2js -maxdepth 1 -type d -name "$PAS2JS_GLOB" | head -n 1 || true)"
if [[ -z "$PAS2JS_DIR" ]]; then
  echo "Error: Matching Pas2JS directory ($PAS2JS_GLOB) not found under vendor/pas2js." >&2
  exit 1
fi
PAS2JS_BASE="$(basename "$PAS2JS_DIR")"
cp -R "$PAS2JS_DIR" "$STAGE_DIR/vendor/pas2js/$PAS2JS_BASE"
chmod +x "$STAGE_DIR/vendor/pas2js/$PAS2JS_BASE"/bin/{pas2js,compileserver,makestub,webidl2pas} 2>/dev/null || true

# 4. Root metadata files
for f in package.json README.md LICENSE; do
  [[ -f "$f" ]] && cp "$f" "$STAGE_DIR/$f"
done

# Auto-stamp staged package.json version to match the exact release/tag version
if [[ -f "$STAGE_DIR/package.json" ]]; then
  if command -v node >/dev/null 2>&1; then
    node -e 'const fs=require("fs");const p=process.argv[1];const d=JSON.parse(fs.readFileSync(p,"utf8"));d.version=process.argv[2];fs.writeFileSync(p,JSON.stringify(d,null,2)+"\n");' "$STAGE_DIR/package.json" "$CLEAN_VERSION"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c 'import json,sys;p=sys.argv[1];d=json.load(open(p));d["version"]=sys.argv[2];json.dump(d,open(p,"w"),indent=2)' "$STAGE_DIR/package.json" "$CLEAN_VERSION"
  else
    sed -i.bak -E "s/(\"version\"[[:space:]]*:[[:space:]]*\")[^\"]*(\")/\1${CLEAN_VERSION}\2/" "$STAGE_DIR/package.json" && rm -f "$STAGE_DIR/package.json.bak"
  fi
fi

# Scrub any stray build artifacts inside staged tree
find "$STAGE_DIR" -type f \( -name '*.o' -o -name '*.ppu' -o -name '*.dcu' -o -name '*.bak' -o -name '*.log' \) -delete 2>/dev/null || true

ARCHIVE_NAME="${ASSET_BASE}.tar.gz"
ARCHIVE_PATH="${OUT_DIR}/${ARCHIVE_NAME}"
tar -czf "$ARCHIVE_PATH" -C "$STAGE_DIR" .
rm -rf "$STAGE_DIR"

if command -v sha256sum >/dev/null 2>&1; then
  HASH="$(sha256sum "$ARCHIVE_PATH" | awk '{print $1}')"
else
  HASH="$(shasum -a 256 "$ARCHIVE_PATH" | awk '{print $1}')"
fi

echo "${HASH}  ${ARCHIVE_NAME}" > "${ARCHIVE_PATH}.sha256"
echo "${HASH}  ${ARCHIVE_NAME}" > "${OUT_DIR}/SHA256SUMS.txt"
echo "[OK] Packaged ${ARCHIVE_PATH} (SHA-256: ${HASH})"
