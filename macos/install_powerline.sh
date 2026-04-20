#!/usr/bin/env bash
# Installe Homebrew deps, pipx + powerline-status, et les polices Roboto Mono Powerline.
# Usage : depuis la racine du dépôt —  ./macos/install_powerline.sh
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Ce script est prévu pour macOS (Darwin)." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS="${SCRIPT_DIR}/configs"
FONTS_SRC="${SCRIPT_DIR}/fonts"

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew est requis : https://brew.sh" >&2
  echo 'Installez-le puis relancez : /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' >&2
  exit 1
fi

echo "==> Mise à jour Homebrew et installation des dépendances (python, pipx, git, coreutils)..."
brew update
brew install python pipx git coreutils

echo "==> pipx : PATH utilisateur (ajoutez à ~/.zprofile si besoin)..."
pipx ensurepath || true
export PATH="${HOME}/.local/bin:${PATH}"

echo "==> powerline-status (Vim)..."
pipx install powerline-status || echo "    powerline-status déjà installé."

if [[ -f "${CONFIGS}/.vimrc" ]]; then
  echo "==> Configuration Vim (macos/configs/.vimrc)..."
  cp "${CONFIGS}/.vimrc" "${HOME}/.vimrc"
fi

echo "==> Polices Roboto Mono Powerline → ~/Library/Fonts ..."
mkdir -p "${HOME}/Library/Fonts"
if [[ -d "${FONTS_SRC}/RobotoMono" ]]; then
  cp -R "${FONTS_SRC}/RobotoMono" "${HOME}/Library/Fonts/"
else
  echo "(!) Dossier macos/fonts/RobotoMono absent — copiez les polices à la main si besoin."
fi

echo "✅ Étape Powerline terminée."
