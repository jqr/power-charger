#!/usr/bin/env bash
set -e

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

found=0
for target in "$MODS_DIR"/power-charger_*; do
  [ -e "$target" ] || continue
  if [ -L "$target" ]; then
    rm "$target"
    echo "Removed symlink $target"
    found=1
  else
    echo "Skipping $target — not a symlink. Remove it manually if needed."
  fi
done

if [ "$found" -eq 0 ]; then
  echo "Nothing to remove — no power-charger symlinks found in $MODS_DIR"
fi
