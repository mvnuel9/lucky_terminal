#!/usr/bin/env bash
#
# Étape 2/3 Linux : installe zsh + Oh My Zsh (script officiel).
#
# Usage : depuis la racine du dépôt —  ./linux/install_terminal.sh
#
# Variables d'environnement (avancé) :
#   OHMYZSH_INSTALL_URL     URL du script installer Oh My Zsh
#                           (défaut : https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)
#   OHMYZSH_INSTALL_SHA256  SHA256 attendu du script (défaut : vide = pas de vérif).
#                           Fortement recommandé en CI/production pour fiabiliser
#                           l'installation face à une modification du script distant.
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

OHMYZSH_INSTALL_URL="${OHMYZSH_INSTALL_URL:-https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh}"
OHMYZSH_INSTALL_SHA256="${OHMYZSH_INSTALL_SHA256:-}"

log_info "=== Installation Zsh + Oh My Zsh (Linux) ==="

log_info "Installation de git-core, zsh, curl via apt..."
lucky_run sudo apt install -y git-core zsh curl

if [[ -d "${HOME}/.oh-my-zsh" ]]; then
  log_info "~/.oh-my-zsh existe déjà — installation Oh My Zsh ignorée."
else
  log_info "Installation d'Oh My Zsh depuis : $OHMYZSH_INSTALL_URL"
  tmp_dir="$(mktemp -d -t lucky-ohmyzsh-XXXXXX)"
  # shellcheck disable=SC2064
  trap "rm -rf '$tmp_dir'" EXIT
  installer="$tmp_dir/install.sh"
  lucky_fetch_and_verify "$OHMYZSH_INSTALL_URL" "$installer" "$OHMYZSH_INSTALL_SHA256"
  if [[ "${LUCKY_DRY_RUN:-0}" -eq 1 ]]; then
    log_info "[dry-run] sh \"$installer\""
  else
    sh "$installer"
  fi
fi

echo ""
log_ok "Étape Terminal terminée."
