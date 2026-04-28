#!/usr/bin/env bash
#
# Étape 2/3 macOS : installe Oh My Zsh (sans changer de shell ni ouvrir un nouveau zsh).
#
# Usage : depuis la racine du dépôt —  ./macos/install_terminal.sh
#
# Variables d'environnement (avancé) :
#   OHMYZSH_INSTALL_URL     URL du script installer Oh My Zsh
#                           (défaut : https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)
#   OHMYZSH_INSTALL_SHA256  SHA256 attendu du script (défaut : vide = pas de vérif).
#                           Fortement recommandé en CI/production.
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

OHMYZSH_INSTALL_URL="${OHMYZSH_INSTALL_URL:-https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh}"
OHMYZSH_INSTALL_SHA256="${OHMYZSH_INSTALL_SHA256:-}"

log_info "=== Installation Oh My Zsh (macOS) ==="

if [[ -d "${HOME}/.oh-my-zsh" ]]; then
  # shellcheck disable=SC2088  # message informatif : on affiche le chemin avec ~ pour l'utilisateur
  log_info "~/.oh-my-zsh existe déjà — on conserve."
else
  log_info "Installation Oh My Zsh depuis : $OHMYZSH_INSTALL_URL"
  log_info "(sans changer le shell ni ouvrir un nouveau zsh à la fin)"
  export RUNZSH=no
  export CHSH=no
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

log_info "Fichiers placeholders pour ~/.zshrc (~/.aliases, ~/.functions)..."
lucky_run touch "${HOME}/.aliases" "${HOME}/.functions"

echo ""
log_ok "Étape Terminal terminée."
