#!/usr/bin/env bash
#
# Installation complète Linux (Ubuntu + GNOME Terminal) : enchaîne les trois étapes.
#
# Usage (depuis la racine du dépôt) :
#   ./linux/install.sh
#   ./linux/install.sh --yes         # propage --yes aux sous-scripts qui le supportent
#   ./linux/install.sh --dry-run     # affiche sans exécuter (honoré par chaque étape)
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

log_info "=== Installation Lucky Terminal — Linux ==="

CHILD_ARGS=()
if [[ "${LUCKY_AUTO_YES:-0}" -eq 1 ]]; then CHILD_ARGS+=("--yes"); fi
if [[ "${LUCKY_DRY_RUN:-0}" -eq 1 ]]; then CHILD_ARGS+=("--dry-run"); fi

bash "${SCRIPT_DIR}/install_powerline.sh" ${CHILD_ARGS[@]+"${CHILD_ARGS[@]}"}
bash "${SCRIPT_DIR}/install_terminal.sh" ${CHILD_ARGS[@]+"${CHILD_ARGS[@]}"}
bash "${SCRIPT_DIR}/install_profile.sh" ${CHILD_ARGS[@]+"${CHILD_ARGS[@]}"}

echo ""
log_ok "Installation complète terminée."
log_info "Ouvrez un nouveau terminal pour profiter du thème Mvnuel."
