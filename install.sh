#!/usr/bin/env bash
set -euo pipefail

# Aspiral MCP Universal Installer (macOS & Linux x64)
INSTALL_DIR="${INSTALL_DIR:-$HOME/.aspiral/bin}"
REPO="DI-Solutions-Mx/aspiral-mcp"
BASE_URL="${ASPIRAL_RELEASE_BASE_URL:-https://github.com/$REPO/releases/latest/download}"

echo "================================================"
echo "    Instalador Oficial Aspiral Monitoring MCP   "
echo "================================================"

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

if [ "$OS" = "darwin" ]; then
  if [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
    BINARY_NAME="aspiral-mcp-macos-arm64"
  else
    BINARY_NAME="aspiral-mcp-macos-x64"
  fi
elif [ "$OS" = "linux" ]; then
  if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then
    BINARY_NAME="aspiral-mcp-linux-x64"
  else
    echo "Error: Arquitectura Linux ($ARCH) no soportada; solo x86_64/amd64 cuenta con binario oficial." >&2
    exit 1
  fi
else
  echo "Error: Esta plataforma ($OS-$ARCH) no cuenta con binario precompilado actualmente." >&2
  exit 1
fi

mkdir -p "$INSTALL_DIR"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "--> Descargando manifiesto de release..."
curl -fsSL "$BASE_URL/manifest.json" -o "$TMP_DIR/manifest.json"

EXPECTED_SHA=""
if command -v jq &>/dev/null; then
  EXPECTED_SHA=$(jq -r --arg f "$BINARY_NAME" '.artifacts[] | select(.file == $f) | .sha256 // empty' "$TMP_DIR/manifest.json" | head -n 1)
elif command -v python3 &>/dev/null; then
  EXPECTED_SHA=$(python3 -c 'import json,sys; m=json.load(open(sys.argv[1])); print(next((a.get("sha256","") for a in m.get("artifacts",[]) if a.get("file")==sys.argv[2]), ""))' "$TMP_DIR/manifest.json" "$BINARY_NAME")
elif command -v node &>/dev/null; then
  EXPECTED_SHA=$(node -e 'const fs=require("fs"); const m=JSON.parse(fs.readFileSync(process.argv[1],"utf8")); const a=(m.artifacts||[]).find(x=>x.file===process.argv[2]); console.log(a?.sha256||"");' "$TMP_DIR/manifest.json" "$BINARY_NAME")
else
  EXPECTED_SHA=$(grep -A 3 "\"$BINARY_NAME\"" "$TMP_DIR/manifest.json" | grep sha256 | head -n 1 | awk -F'"' '{print $4}' || true)
fi

if ! [[ "$EXPECTED_SHA" =~ ^[a-fA-F0-9]{64}$ ]]; then
  echo "Error: No se encontró un hash SHA-256 válido para $BINARY_NAME en manifest.json." >&2
  exit 1
fi
EXPECTED_SHA="$(printf '%s' "$EXPECTED_SHA" | tr '[:upper:]' '[:lower:]')"

echo "--> Descargando $BINARY_NAME..."
curl -fsSL "$BASE_URL/$BINARY_NAME" -o "$TMP_DIR/$BINARY_NAME"

echo "--> Verificando integridad SHA-256..."
if command -v sha256sum &>/dev/null; then
  ACTUAL_SHA=$(sha256sum "$TMP_DIR/$BINARY_NAME" | awk '{print $1}')
elif command -v shasum &>/dev/null; then
  ACTUAL_SHA=$(shasum -a 256 "$TMP_DIR/$BINARY_NAME" | awk '{print $1}')
else
  echo "Error: No se encontró 'sha256sum' ni 'shasum' para verificar integridad." >&2
  exit 1
fi

if [ "$EXPECTED_SHA" != "$ACTUAL_SHA" ]; then
  echo "Error: La suma de verificación SHA-256 no coincide." >&2
  echo "Esperado: $EXPECTED_SHA" >&2
  echo "Obtenido: $ACTUAL_SHA" >&2
  exit 1
fi

mv "$TMP_DIR/$BINARY_NAME" "$INSTALL_DIR/aspiral-mcp"
chmod +x "$INSTALL_DIR/aspiral-mcp"

echo ""
echo "✓ Aspiral MCP instalado correctamente en: $INSTALL_DIR/aspiral-mcp"
echo "✓ Configura en tu cliente MCP (Claude Desktop, Cursor, etc.):"
echo "    command: $INSTALL_DIR/aspiral-mcp"
echo "    env:"
echo "      ASPIRAL_MCP_API_KEY=<tu_clave_asmcp>"
echo "      ASPIRAL_MCP_API_BASE_URL=https://monitoring.aspiral.com.mx"
echo "================================================"
