#!/usr/bin/env bash
# Retire une partie des éléments installés par macos/install.sh (sans tout supprimer aveuglément).
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Prévu pour macOS." >&2
  exit 1
fi

echo "==> pipx : désinstallation de powerline-status..."
if command -v pipx >/dev/null 2>&1; then
  pipx uninstall powerline-status 2>/dev/null || true
fi

echo "==> Polices RobotoMono dans ~/Library/Fonts ..."
if [[ -d "${HOME}/Library/Fonts/RobotoMono" ]]; then
  read -r -p "Supprimer ~/Library/Fonts/RobotoMono ? [o/N] " a
  if [[ "${a,,}" == "o" || "${a,,}" == "oui" ]]; then
    rm -rf "${HOME}/Library/Fonts/RobotoMono"
  fi
fi

echo "==> Sauvegardes ~/.zshrc et ~/.vimrc..."
TS="$(date +%Y%m%d-%H%M%S)"
[[ -f "${HOME}/.zshrc" ]] && mv "${HOME}/.zshrc" "${HOME}/.zshrc.bak.mvnuel-${TS}"
[[ -f "${HOME}/.vimrc" ]] && grep -q 'powerline/bindings/vim' "${HOME}/.vimrc" 2>/dev/null && mv "${HOME}/.vimrc" "${HOME}/.vimrc.bak.mvnuel-${TS}"

echo ""
echo "Oh My Zsh n’a pas été supprimé. Pour le retirer : exécutez le script officiel ou supprimez ~/.oh-my-zsh"
echo "Profil iTerm2 / Terminal : à réinitialiser à la main dans les préférences."
