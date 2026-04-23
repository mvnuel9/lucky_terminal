#!/usr/bin/env bash
#
# Installation complète macOS (Homebrew + Oh My Zsh + configs Mvnuel) :
# enchaîne les trois étapes.
#
# Usage (depuis la racine du dépôt) :
#   ./macos/install.sh
#   ./macos/install.sh --yes         # propage --yes aux sous-scripts
#   ./macos/install.sh --dry-run     # affiche sans exécuter
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

log_info "=== Installation Lucky Terminal — macOS ==="

CHILD_ARGS=()
if [[ "${LUCKY_AUTO_YES:-0}" -eq 1 ]]; then CHILD_ARGS+=("--yes"); fi
if [[ "${LUCKY_DRY_RUN:-0}" -eq 1 ]]; then CHILD_ARGS+=("--dry-run"); fi

bash "${SCRIPT_DIR}/install_powerline.sh" ${CHILD_ARGS[@]+"${CHILD_ARGS[@]}"}
bash "${SCRIPT_DIR}/install_terminal.sh" ${CHILD_ARGS[@]+"${CHILD_ARGS[@]}"}
bash "${SCRIPT_DIR}/install_profile.sh" ${CHILD_ARGS[@]+"${CHILD_ARGS[@]}"}

echo ""
log_ok "Installation terminée."
echo ""
log_info "Étapes suivantes :"
log_info "  1. iTerm2 : importez macos/Mvnuel.itermcolors → Profiles → Colors → Color Presets… → Import."
log_info "  2. Terminal.app : profil « Mvnuel » déjà importé si l'étape ci-dessus a réussi ; sinon voir macos/README.md."
log_info "  3. Choisissez la police « Roboto Mono for Powerline » (taille 13–14) dans le profil si besoin."
log_info "  4. Nouveau terminal zsh :  exec zsh"
log_info "  5. Si « dircolors » n'est pas reconnu, rouvrez le terminal après installation des coreutils."
echo ""
log_info "Documentation : macos/README.md"
