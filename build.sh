#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST="$REPO_ROOT/dist"

# dotnet setup (installed via install script)
export DOTNET_ROOT="${DOTNET_ROOT:-$HOME/.dotnet}"
export PATH="$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH"

echo "==> Cleaning dist/"
rm -rf "$DIST"
mkdir -p "$DIST"

# ── 1. Plugin (APLC.dll) ────────────────────────────────────────────────────
echo "==> Building plugin"
dotnet build "$REPO_ROOT/APLC_plugin" -c Release --nologo -v quiet

# ── 2. Thunderstore zip ─────────────────────────────────────────────────────
echo "==> Packaging Thunderstore zip"
THUNDERSTORE_DIR="$REPO_ROOT/APLC_plugin/Thunderstore"
(cd "$THUNDERSTORE_DIR" && zip -qr "$DIST/APLC-thunderstore.zip" .)
echo "    → dist/APLC-thunderstore.zip"

# ── 3. apworld ──────────────────────────────────────────────────────────────
echo "==> Packaging apworld"
(cd "$REPO_ROOT/APLC_apworld" && \
    zip -qr "$DIST/lethal_company.apworld" lethal_company \
        --exclude "lethal_company/__pycache__/*" \
        --exclude "lethal_company/*/__pycache__/*" \
        --exclude "lethal_company/*.pyc" \
        --exclude "lethal_company/test/*")
echo "    → dist/lethal_company.apworld"

# ── 4. YAML template ────────────────────────────────────────────────────────
YAML_SRC=$(find "$REPO_ROOT" -maxdepth 1 -iname "lethal_company.yaml" | head -1)
if [[ -n "$YAML_SRC" ]]; then
    echo "==> Copying YAML template"
    cp "$YAML_SRC" "$DIST/lethal_company.yaml"
    echo "    → dist/lethal_company.yaml"
else
    echo "==> Skipping YAML template (not found at repo root)"
fi

echo ""
echo "Build complete. Artifacts in dist/:"
ls -lh "$DIST"
