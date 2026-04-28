#!/usr/bin/env bash
#
# macOS — Supprime les dossiers et fichiers zsh / Oh My Zsh restants pour repartir sur une
# base propre avant une réinstallation (après ./macos/uninstall.sh ou installation partielle).
# Équivalent de ../linux/purge_zsh.sh (Linux), chemins home identiques.
#
# Usage (depuis la racine du dépôt) :
#   ./macos/purge_zsh.sh
#   ./macos/purge_zsh.sh --yes
#   ./macos/purge_zsh.sh --yes --with-history
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../scripts/_common.sh
. "${SCRIPT_DIR}/../scripts/_common.sh"

if [[ "$(lucky_os)" != "macos" ]]; then
  die "Ce script est prévu pour macOS (Darwin)." "$LUCKY_EXIT_UNSUPPORTED_OS"
fi

WITH_HISTORY=0
parse_common_args "$@"
for arg in ${LUCKY_REMAINING_ARGS[@]+"${LUCKY_REMAINING_ARGS[@]}"}; do
  case "$arg" in
    --with-history) WITH_HISTORY=1 ;;
    --help | -h)
      awk '/^#/{print; next} {exit}' "$0"
      exit 0
      ;;
    *)
      log_warn "Option inconnue ignorée : $arg"
      ;;
  esac
done

log_info "=== Purge zsh / Oh My Zsh (résidus) — macOS ==="
echo ""

targets=()

add_target() {
  local p=$1
  if [[ -e "$p" || -L "$p" ]]; then
    targets+=("$p")
  fi
}

add_target "$HOME/.oh-my-zsh"
add_target "$HOME/.zshrc"
add_target "$HOME/.zshrc.pre-oh-my-zsh"
add_target "$HOME/.zshrc.save"

shopt -s nullglob
for f in "$HOME"/.zshrc.bak.mvnuel-* "$HOME"/.zcompdump*; do
  add_target "$f"
done
shopt -u nullglob

add_target "$HOME/.cache/zsh"
add_target "$HOME/.zsh_sessions"

if [[ "$WITH_HISTORY" -eq 1 ]]; then
  add_target "$HOME/.zsh_history"
fi

if [[ ${#targets[@]} -eq 0 ]]; then
  log_info "Aucun fichier ou dossier cible trouvé (~/.oh-my-zsh, ~/.zshrc, .zcompdump*, etc.)."
  log_info "Rien à faire."
  exit "$LUCKY_EXIT_OK"
fi

log_info "Seront supprimés définitivement :"
printf '  %s\n' "${targets[@]}"
echo ""

if [[ "$WITH_HISTORY" -ne 1 ]] && [[ -f "$HOME/.zsh_history" ]]; then
  log_info "(~/.zsh_history est conservé. Pour le supprimer aussi : $0 --yes --with-history)"
  echo ""
fi

if ! confirm "Continuer la suppression ?"; then
  log_warn "Annulé."
  exit "$LUCKY_EXIT_CANCELLED"
fi

for p in "${targets[@]}"; do
  if [[ -d "$p" ]]; then
    log_info "Suppression dossier : $p"
    lucky_run rm -rf "$p"
  elif [[ -f "$p" || -L "$p" ]]; then
    log_info "Suppression fichier : $p"
    lucky_run rm -f "$p"
  fi
done

echo ""
log_ok "Terminé. Tu peux relancer ./macos/install.sh (depuis la racine du dépôt) pour réinstaller le profil."
log_info "Fichiers non gérés ici (à vérifier à la main si besoin) : ~/.zshenv, ~/.zprofile, ~/.zlogin, ~/.dircolors, ~/.dircolors.terminal."
