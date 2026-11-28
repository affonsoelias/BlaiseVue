#!/usr/bin/env bash
set -euo pipefail

REPO="${BLAISEVUE_UPGRADE_REPO:-affonsoelias/BlaiseVue}"
INSTALL_ROOT="${BLAISEVUE_HOME:-$HOME/.blaisevue}"
VERSION=""
CHANNEL=""
NIGHTLY=0
ALLOW_UNSIGNED=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version=*) VERSION="${1#*=}" ;;
    --channel=*) CHANNEL="${1#*=}" ;;
    --install-dir=*) INSTALL_ROOT="${1#*=}" ;;
    --nightly) NIGHTLY=1 ;;
    --allow-unsigned) ALLOW_UNSIGNED=1 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

RESOLVED_CHANNEL="stable"
if [[ -n "$CHANNEL" ]]; then
  LOW_CH="$(echo "$CHANNEL" | tr '[:upper:]' '[:lower:]')"
  case "$LOW_CH" in
    stable|main) RESOLVED_CHANNEL="stable" ;;
    nightly|develop|dev) RESOLVED_CHANNEL="nightly"; NIGHTLY=1 ;;
    *) echo "Error: Invalid channel '$CHANNEL'. Valid: stable (main) or nightly (develop)." >&2; exit 1 ;;
  esac
elif [[ "$NIGHTLY" -eq 1 ]]; then
  RESOLVED_CHANNEL="nightly"
fi

UNAME_S="$(uname -s)"
case "$UNAME_S" in
  Darwin*) OS_NAME="macos" ;;
  Linux*)  OS_NAME="linux" ;;
  *)       echo "Unsupported OS: $UNAME_S" >&2; exit 1 ;;
esac

UNAME_M="$(uname -m)"
case "$UNAME_M" in
  x86_64|amd64) ARCH_NAME="x86_64" ;;
  arm64|aarch64) ARCH_NAME="aarch64" ;;
  *) echo "Unsupported architecture: $UNAME_M" >&2; exit 1 ;;
esac

if [[ -n "$VERSION" ]]; then
  case "$VERSION" in
    v*|V*) TAG_REQ="$VERSION" ;;
    *) TAG_REQ="v$VERSION" ;;
  esac
  API_URL="https://api.github.com/repos/${REPO}/releases/tags/${TAG_REQ}"
elif [[ "$NIGHTLY" -eq 1 ]]; then
  API_URL="https://api.github.com/repos/${REPO}/releases?per_page=15"
else
  API_URL="https://api.github.com/repos/${REPO}/releases/latest"
fi

echo "[1/4] Fetching release metadata (${OS_NAME}-${ARCH_NAME}, channel: ${RESOLVED_CHANNEL})..."
META_JSON="$(curl -fsSL -H 'User-Agent: BlaiseVue-Installer' -H 'Accept: application/vnd.github.v3+json' "$API_URL")"

ASSET_URL="$(printf '%s' "$META_JSON" | grep -oE '"browser_download_url"\s*:\s*"[^"]*"' | cut -d'"' -f4 | grep -E "${OS_NAME}.*(${ARCH_NAME}|amd64|arm64)" | grep -vE '\.(sha256|sig|asc)$' | head -n 1 || true)"
if [[ -z "$ASSET_URL" ]]; then
  echo "Error: No compatible asset found for ${OS_NAME}-${ARCH_NAME}." >&2
  exit 1
fi
ASSET_NAME="$(basename "$ASSET_URL")"
SUM_URL="$(printf '%s' "$META_JSON" | grep -oE '"browser_download_url"\s*:\s*"[^"]*"' | cut -d'"' -f4 | grep -E "${ASSET_NAME}\.sha256|SHA256SUMS\.txt" | head -n 1 || true)"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "[2/4] Downloading ${ASSET_NAME}..."
curl -fsSL -H 'User-Agent: BlaiseVue-Installer' -o "$TMP_DIR/$ASSET_NAME" "$ASSET_URL"

if command -v sha256sum >/dev/null 2>&1; then
  CALC_HASH="$(sha256sum "$TMP_DIR/$ASSET_NAME" | awk '{print $1}')"
else
  CALC_HASH="$(shasum -a 256 "$TMP_DIR/$ASSET_NAME" | awk '{print $1}')"
fi

if [[ -n "$SUM_URL" ]]; then
  SUM_CONTENT="$(curl -fsSL "$SUM_URL")"
  if ! echo "$SUM_CONTENT" | tr '[:upper:]' '[:lower:]' | grep -q "$CALC_HASH"; then
    echo "Security Error: SHA-256 verification failed for ${ASSET_NAME}!" >&2
    exit 1
  fi
  echo "      [OK] SHA-256 verified: ${CALC_HASH}"
elif [[ "$ALLOW_UNSIGNED" -eq 0 ]]; then
  echo "Security Error: No checksum asset found. Pass --allow-unsigned to override." >&2
  exit 1
fi

echo "[3/4] Extracting into ${INSTALL_ROOT}..."
mkdir -p "$TMP_DIR/extracted" "$INSTALL_ROOT/bin"
tar -xzf "$TMP_DIR/$ASSET_NAME" -C "$TMP_DIR/extracted"
EXE_SRC="$(find "$TMP_DIR/extracted" -type f -name bv | head -n 1 || true)"
if [[ -z "$EXE_SRC" ]]; then
  echo "Error: bv binary missing from archive." >&2
  exit 1
fi
SRC_SDK_ROOT="$(dirname "$(dirname "$EXE_SRC")")"
if [[ ! -d "$SRC_SDK_ROOT/core" ]]; then
  SRC_SDK_ROOT="$TMP_DIR/extracted"
fi

cp -R "$(dirname "$EXE_SRC")"/. "$INSTALL_ROOT/bin/"
chmod +x "$INSTALL_ROOT/bin/bv"

for dir in core templates; do
  if [[ -d "$SRC_SDK_ROOT/$dir" ]]; then
    rm -rf "$INSTALL_ROOT/$dir"
    cp -R "$SRC_SDK_ROOT/$dir" "$INSTALL_ROOT/$dir"
  fi
done
if [[ -d "$SRC_SDK_ROOT/packages/core" ]]; then
  mkdir -p "$INSTALL_ROOT/packages"
  rm -rf "$INSTALL_ROOT/packages/core"
  cp -R "$SRC_SDK_ROOT/packages/core" "$INSTALL_ROOT/packages/core"
fi
for vsub in zephyr pas2js; do
  if [[ -d "$SRC_SDK_ROOT/vendor/$vsub" ]]; then
    mkdir -p "$INSTALL_ROOT/vendor"
    rm -rf "$INSTALL_ROOT/vendor/$vsub"
    cp -R "$SRC_SDK_ROOT/vendor/$vsub" "$INSTALL_ROOT/vendor/$vsub"
  fi
done
chmod +x "$INSTALL_ROOT"/vendor/pas2js/pas2js-*/bin/{pas2js,compileserver,makestub,webidl2pas} 2>/dev/null || true

for f in package.json README.md LICENSE; do
  [[ -f "$SRC_SDK_ROOT/$f" ]] && cp "$SRC_SDK_ROOT/$f" "$INSTALL_ROOT/$f"
done

printf '{\n  "channel": "%s"\n}\n' "$RESOLVED_CHANNEL" > "$INSTALL_ROOT/config.json"

echo "[4/4] Installed!"
"$INSTALL_ROOT/bin/bv" --version
echo "Add to PATH: export PATH=\"$INSTALL_ROOT/bin:\$PATH\""
