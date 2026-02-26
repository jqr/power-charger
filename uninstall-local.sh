#!/usr/bin/env bash
set -e

MOD_NAME="power-charger_0.1.0"

case "$(uname -s)" in
  Darwin)
    MODS_DIR="$HOME/Library/Application Support/factorio/mods"
    ;;
  Linux)
    MODS_DIR="$HOME/.factorio/mods"
    ;;
  *)
    echo "Error: Unsupported OS. On Windows, use uninstall-local.ps1 instead."
    exit 1
    ;;
esac

TARGET="$MODS_DIR/$MOD_NAME"

if [ -L "$TARGET" ]; then
  rm "$TARGET"
  echo "Removed symlink $TARGET"
elif [ -e "$TARGET" ]; then
  echo "Error: $TARGET exists but is not a symlink. Remove it manually."
  exit 1
else
  echo "Nothing to remove — $TARGET does not exist."
fi
