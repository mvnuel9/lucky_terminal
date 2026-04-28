#!/usr/bin/env bash
#
# Retire une partie des éléments installés par macos/install.sh
# (sans tout supprimer aveuglément).
#
# Usage :
#   ./macos/uninstall.sh               # demande confirmation pour les polices
#   ./macos/uninstall.sh --yes         # sans invite
#   ./macos/uninstall.sh --dry-run     # montre les commandes sans les exécuter
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../scripts/_common.sh
. "${SCRIPT_DIR}/../scripts/_common.sh"

if [[ "$(lucky_os)" != "macos" ]]; then
  die "Prévu pour macOS." "$LUCKY_EXIT_UNSUPPORTED_OS"
fi

parse_common_args "$@"
for arg in ${LUCKY_REMAINING_ARGS[@]+"${LUCKY_REMAINING_ARGS[@]}"}; do
  case "$arg" in
    --help | -h)
      awk '/^#/{print; next} {exit}' "$0"
      exit 0
      ;;
    *)
      log_warn "Option inconnue ignorée : $arg"
      ;;
  esac
done

log_info "==> pipx : désinstallation de powerline-status..."
if command -v pipx >/dev/null 2>&1; then
  lucky_run pipx uninstall powerline-status 2>/dev/null || true
fi

log_info "==> Polices RobotoMono dans ~/Library/Fonts ..."
if [[ -d "${HOME}/Library/Fonts/RobotoMono" ]]; then
  if confirm "Supprimer ~/Library/Fonts/RobotoMono ?"; then
    lucky_run rm -rf "${HOME}/Library/Fonts/RobotoMono"
  fi
fi

log_info "==> Sauvegardes ~/.zshrc et ~/.vimrc..."
TS="$(date +%Y%m%d-%H%M%S)"
if [[ -f "${HOME}/.zshrc" ]]; then
  lucky_run mv "${HOME}/.zshrc" "${HOME}/.zshrc.bak.mvnuel-${TS}"
fi
if [[ -f "${HOME}/.vimrc" ]] && grep -q 'powerline/bindings/vim' "${HOME}/.vimrc" 2>/dev/null; then
  lucky_run mv "${HOME}/.vimrc" "${HOME}/.vimrc.bak.mvnuel-${TS}"
fi

echo ""
log_info "Oh My Zsh n'a pas été supprimé. Pour le retirer : exécutez le script officiel ou supprimez ~/.oh-my-zsh"
log_info "Profil iTerm2 / Terminal : à réinitialiser à la main dans les préférences."
