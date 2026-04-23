#!/usr/bin/env bash
#
# Étape 1/3 Linux : installe les dépendances apt, pipx + powerline-status,
# les polices Powerline, et la config Vim.
#
# Usage : depuis la racine du dépôt —  ./linux/install_powerline.sh
#
# Variables d'environnement (avancé) :
#   POWERLINE_STATUS_VERSION   Version pipx (défaut : vide = dernière).
#                              Ex. 2.8.4 pour épingler : `pipx install powerline-status==2.8.4`.
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

require_cmd apt-get "ce script cible les distributions à base de Debian/Ubuntu"

log_info "=== Installation Powerline (Linux) ==="

log_info "[1/4] Installation des dépendances apt (python3-full, python3-pip, pipx, fonts-powerline)..."
lucky_run sudo apt update
lucky_run sudo apt install -y python3-full python3-pip pipx fonts-powerline

log_info "[2/4] Configuration de pipx (PATH utilisateur)..."
lucky_run pipx ensurepath

export PATH="$HOME/.local/bin:$PATH"

log_info "[3/4] Installation de powerline-status via pipx..."
POWERLINE_STATUS_VERSION="${POWERLINE_STATUS_VERSION:-}"
if [[ -n "$POWERLINE_STATUS_VERSION" ]]; then
  log_info "    version épinglée : $POWERLINE_STATUS_VERSION"
  lucky_run pipx install "powerline-status==$POWERLINE_STATUS_VERSION"
else
  lucky_run pipx install powerline-status
fi

log_info "[4/4] Configuration Vim + polices..."
lucky_run cp "${SCRIPT_DIR}/configs/.vimrc" "$HOME/.vimrc"
lucky_run mkdir -p "$HOME/.fonts"
lucky_run cp -a "${SCRIPT_DIR}/fonts/." "$HOME/.fonts/"
if command -v fc-cache >/dev/null 2>&1; then
  lucky_run fc-cache -fv "$HOME/.fonts/"
else
  log_warn "fc-cache introuvable — le cache des polices ne sera pas rafraîchi."
fi

echo ""
log_ok "Étape Powerline terminée."
log_info "Pense à redémarrer le terminal et à sélectionner une police Powerline."
