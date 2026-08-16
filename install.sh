#!/bin/sh
# Install GIF as its own shell (fish engine binary named `gif` + launcher).
# Does NOT install a plugin into ~/.config/fish.
set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
DEST="${GIF_DEST:-$HOME/.config/gif}"
BIN_DIR="${GIF_BIN_DIR:-$HOME/.local/bin}"
DATA_DIR="${GIF_DATA_DIR:-$HOME/.local/share/gif}"

FISH_BIN="$(command -v fish || true)"
if [ -z "$FISH_BIN" ]; then
  echo "install.sh: the fish engine is required (GIF is built on top of it)" >&2
  echo "  install fish first, then re-run this script" >&2
  exit 1
fi
# Prefer the real binary over a brew shim/symlink for the engine copy
FISH_REAL="$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$FISH_BIN" 2>/dev/null || readlink -f "$FISH_BIN" 2>/dev/null || echo "$FISH_BIN")"

echo "Installing GIF — Goldknow's Integrated FISH (standalone shell)"
echo "  from   $ROOT"
echo "  root   $DEST"
echo "  shell  $BIN_DIR/gif"
echo "  engine copy of $FISH_REAL"

mkdir -p \
  "$DEST/functions" \
  "$DEST/conf.d" \
  "$DEST/share/gif/fonts" \
  "$DEST/bin" \
  "$DEST/libexec" \
  "$DEST/xdg/fish" \
  "$DEST/xdg/fish/conf.d" \
  "$DEST/xdg/fish/functions" \
  "$BIN_DIR" \
  "$DATA_DIR"

# Runtime modules
cp -f "$ROOT"/functions/*.gifsh "$DEST/functions/"
cp -f "$ROOT"/conf.d/*.gifsh "$DEST/conf.d/"
cp -f "$ROOT"/share/gif/fonts/* "$DEST/share/gif/fonts/"
cp -f "$ROOT"/share/gif/xdg-fish/config.fish "$DEST/xdg/fish/config.fish"

# Engine: fish binary installed under the name `gif` so ps/fastfetch see GIF
cp -f "$FISH_REAL" "$DEST/libexec/gif"
chmod +x "$DEST/libexec/gif"

# Launcher on PATH (sets env, then exec's the engine)
cp -f "$ROOT/bin/gif" "$DEST/bin/gif"
cp -f "$ROOT/bin/gif" "$BIN_DIR/gif"
chmod +x "$DEST/bin/gif" "$BIN_DIR/gif"

printf 'set -gx GIF_ROOT "%s"\n' "$DEST" > "$DEST/conf.d/00-root.gifsh"

# Remove legacy fish plugin if present
if [ -f "$HOME/.config/fish/conf.d/gif-load.fish" ]; then
  rm -f "$HOME/.config/fish/conf.d/gif-load.fish"
  echo "  removed legacy fish plugin: ~/.config/fish/conf.d/gif-load.fish"
fi

case ":${PATH}:" in
  *":$BIN_DIR:"*) ;;
  *)
    echo ""
    echo "Note: add $BIN_DIR to your PATH if needed:"
    echo "  fish_add_path $BIN_DIR"
    ;;
esac

echo ""
echo "GIF shell installed."
echo "  launcher: $BIN_DIR/gif"
echo "  engine:   $DEST/libexec/gif   (fish engine, process name: gif)"
echo "  stock fish left at: $FISH_BIN"
echo ""
echo "Start:  gif"
echo "Cursor terminal path:  $BIN_DIR/gif"
echo ""
echo "Verify:  gif -c 'fastfetch -s Shell'"
