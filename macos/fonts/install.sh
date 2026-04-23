#!/usr/bin/env bash
# Copie les polices Powerline de ce dossier vers le dossier polices utilisateur.
# Inspiré de github.com/powerline/fonts/install.sh (patches pour shellcheck-clean).
set -euo pipefail

powerline_fonts_dir="$(cd "$(dirname "$0")" && pwd)"

prefix="${1:-}"

if [[ "$(uname)" == "Darwin" ]]; then
  font_dir="$HOME/Library/Fonts"
else
  font_dir="$HOME/.local/share/fonts"
  mkdir -p "$font_dir"
fi

echo "Copying fonts..."
find "$powerline_fonts_dir" \( -name "${prefix}*.[ot]tf" -or -name "${prefix}*.pcf.gz" \) -type f -print0 |
  xargs -0 -n1 -I % cp "%" "$font_dir/"

if command -v fc-cache >/dev/null 2>&1; then
  echo "Resetting font cache, this may take a moment..."
  fc-cache -f "$font_dir"
fi

echo "Powerline fonts installed to $font_dir"
