#!/usr/bin/env bash
#
# Étape 2/3 macOS : installe Oh My Zsh (sans changer de shell ni ouvrir un nouveau zsh).
#
# Usage : depuis la racine du dépôt —  ./macos/install_terminal.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../scripts/_common.sh
. "${SCRIPT_DIR}/../scripts/_common.sh"

if [[ "$(lucky_os)" != "macos" ]]; then
  die "Ce script est prévu pour macOS (Darwin)." "$LUCKY_EXIT_UNSUPPORTED_OS"
fi

parse_common_args "$@"
for arg in ${LUCKY_REMAINING_ARGS[@]+"${LUCKY_REMAINING_ARGS[@]}"}; do
  case "$arg" in
    --help | -h)
      awk '/^#/{print; next} {exit}' "$0"
      exit 0
      ;;
    *) log_warn "Option inconnue ignorée : $arg" ;;
  esac
done

log_info "=== Installation Oh My Zsh (macOS) ==="

if [[ -d "${HOME}/.oh-my-zsh" ]]; then
  log_info "~/.oh-my-zsh existe déjà — on conserve."
else
  log_info "Installation (sans changer le shell ni ouvrir un nouveau zsh à la fin)..."
  export RUNZSH=no
  export CHSH=no
  if [[ "${LUCKY_DRY_RUN:-0}" -eq 1 ]]; then
    log_info "[dry-run] sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
  else
    # Note : l'épinglage de version et la vérification d'intégrité sont traités
    # dans l'item "Sécuriser les téléchargements externes" de la roadmap.
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
fi

log_info "Fichiers placeholders pour ~/.zshrc (~/.aliases, ~/.functions)..."
lucky_run touch "${HOME}/.aliases" "${HOME}/.functions"

echo ""
log_ok "Étape Terminal terminée."
