#!/usr/bin/env bash
set -euo pipefail

# Aspiral MCP Universal Installer (macOS & Linux)
INSTALL_DIR="$HOME/.aspiral/bin"
REPO="DI-Solutions-Mx/aspiral-mcp"
BASE_URL="https://github.com/$REPO/releases/latest/download"

echo "================================================"
echo "    Instalador Oficial Aspiral Monitoring MCP   "
echo "================================================"

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

if [ "$OS" = "darwin" ]; then
  if [ "$ARCH" = "arm64" ]; then
    BINARY_NAME="aspiral-mcp-macos-arm64"
  else
    BINARY_NAME="aspiral-mcp-macos-x64"
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

EXPECTED_SHA=$(grep -A 3 "$BINARY_NAME" "$TMP_DIR/manifest.json" | grep sha256 | head -n 1 | awk -F'"' '{print $4}')

echo "--> Descargando $BINARY_NAME..."
curl -fsSL "$BASE_URL/$BINARY_NAME" -o "$TMP_DIR/$BINARY_NAME"

echo "--> Verificando integridad SHA-256..."
ACTUAL_SHA=$(shasum -a 256 "$TMP_DIR/$BINARY_NAME" | awk '{print $1}')
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
echo "    env: ASPIRAL_API_KEY=<tu_clave_asmcp>"
echo "================================================"
