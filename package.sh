#!/usr/bin/env bash
set -e

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION=$(python3 -c "import json; print(json.load(open('$SRC_DIR/info.json'))['version'])")
MOD_NAME="power-charger_${VERSION}"
OUT_FILE="${SRC_DIR}/${MOD_NAME}.zip"
TMPDIR=$(mktemp -d)

rm -f "$OUT_FILE"

# Copy mod files into correctly named folder
mkdir "$TMPDIR/$MOD_NAME"
cp -r "$SRC_DIR"/info.json "$SRC_DIR"/changelog.txt "$SRC_DIR"/control.lua \
      "$SRC_DIR"/data.lua "$SRC_DIR"/thumbnail.png \
      "$SRC_DIR"/locale \
      "$TMPDIR/$MOD_NAME/"

# Create zip
cd "$TMPDIR"
zip -r "$OUT_FILE" "$MOD_NAME"

rm -rf "$TMPDIR"
echo "Created $OUT_FILE"
