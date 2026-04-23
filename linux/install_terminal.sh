#!/usr/bin/env bash
#
# Étape 2/3 Linux : installe zsh + Oh My Zsh (script officiel).
#
# Usage : depuis la racine du dépôt —  ./linux/install_terminal.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../scripts/_common.sh
. "${SCRIPT_DIR}/../scripts/_common.sh"

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

require_cmd apt-get "distribution à base de Debian/Ubuntu requise"

log_info "=== Installation Zsh + Oh My Zsh (Linux) ==="

log_info "Installation de git-core, zsh, curl via apt..."
lucky_run sudo apt install -y git-core zsh curl

if [[ -d "${HOME}/.oh-my-zsh" ]]; then
  log_info "~/.oh-my-zsh existe déjà — installation Oh My Zsh ignorée."
else
  log_info "Installation d'Oh My Zsh (script officiel ohmyzsh.sh)..."
  if [[ "${LUCKY_DRY_RUN:-0}" -eq 1 ]]; then
    log_info "[dry-run] sh -c \"\$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)\""
  else
    # Note : l'épinglage de version et la vérification d'intégrité sont traités
    # dans l'item "Sécuriser les téléchargements externes" de la roadmap.
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  fi
fi

echo ""
log_ok "Étape Terminal terminée."
