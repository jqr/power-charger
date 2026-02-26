#!/usr/bin/env bash
set -e

MOD_NAME="power-charger_0.1.0"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

# Detect OS and set mods directory
case "$(uname -s)" in
  Darwin)
    MODS_DIR="$HOME/Library/Application Support/factorio/mods"
    ;;
  Linux)
    MODS_DIR="$HOME/.factorio/mods"
    ;;
  *)
    echo "Error: Unsupported OS. On Windows, use install-local.ps1 instead."
    exit 1
    ;;
esac

if [ ! -d "$MODS_DIR" ]; then
  echo "Error: Mods directory not found at $MODS_DIR"
  echo "Is Factorio installed?"
  exit 1
fi

TARGET="$MODS_DIR/$MOD_NAME"

# Remove existing link/dir
rm -rf "$TARGET"
ln -s "$SRC_DIR" "$TARGET"

echo "Linked $TARGET -> $SRC_DIR"
echo "Restart Factorio to load the mod."
