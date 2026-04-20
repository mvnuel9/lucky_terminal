#!/usr/bin/env bash
# Installe Zsh via Oh My Zsh (sans changer de shell ni ouvrir un nouveau zsh à la fin).
# Usage : depuis la racine du dépôt —  ./macos/install_terminal.sh
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Ce script est prévu pour macOS (Darwin)." >&2
  exit 1
fi

echo "==> Oh My Zsh..."
if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
  echo "    Installation (sans changer le shell ni ouvrir un nouveau zsh à la fin)..."
  export RUNZSH=no
  export CHSH=no
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "    ~/.oh-my-zsh existe déjà — on conserve."
fi

echo "==> Fichiers pour ~/.zshrc (aliases / functions)..."
touch "${HOME}/.aliases" "${HOME}/.functions"

echo "✅ Étape Terminal terminée."
