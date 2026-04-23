#!/usr/bin/env bash
#
# Étape 1/3 macOS : Homebrew deps + pipx + powerline-status + polices RobotoMono.
#
# Usage : depuis la racine du dépôt —  ./macos/install_powerline.sh
#
# Variables d'environnement (avancé) :
#   POWERLINE_STATUS_VERSION   Version pipx (défaut : vide = dernière).
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

CONFIGS="${SCRIPT_DIR}/configs"
FONTS_SRC="${SCRIPT_DIR}/fonts"

require_cmd brew 'installez Homebrew : /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'

log_info "=== Installation Powerline (macOS) ==="

log_info "[1/4] Mise à jour Homebrew et installation des dépendances (python, pipx, git, coreutils)..."
lucky_run brew update
lucky_run brew install python pipx git coreutils

log_info "[2/4] Configuration de pipx (PATH utilisateur)..."
lucky_run pipx ensurepath || true
export PATH="${HOME}/.local/bin:${PATH}"

log_info "[3/4] Installation de powerline-status via pipx..."
POWERLINE_STATUS_VERSION="${POWERLINE_STATUS_VERSION:-}"
if pipx list 2>/dev/null | grep -q powerline-status; then
  log_info "    powerline-status déjà installé — ignoré."
elif [[ -n "$POWERLINE_STATUS_VERSION" ]]; then
  log_info "    version épinglée : $POWERLINE_STATUS_VERSION"
  lucky_run pipx install "powerline-status==$POWERLINE_STATUS_VERSION"
else
  lucky_run pipx install powerline-status
fi

if [[ -f "${CONFIGS}/.vimrc" ]]; then
  log_info "    Configuration Vim (macos/configs/.vimrc)..."
  lucky_run cp "${CONFIGS}/.vimrc" "${HOME}/.vimrc"
fi

log_info "[4/4] Polices Roboto Mono Powerline → ~/Library/Fonts ..."
lucky_run mkdir -p "${HOME}/Library/Fonts"
if [[ -d "${FONTS_SRC}/RobotoMono" ]]; then
  lucky_run cp -R "${FONTS_SRC}/RobotoMono" "${HOME}/Library/Fonts/"
else
  log_warn "Dossier macos/fonts/RobotoMono absent — copiez les polices à la main si besoin."
fi

echo ""
log_ok "Étape Powerline terminée."
