#!/usr/bin/env bash
#
# Supprime les dossiers et fichiers zsh / Oh My Zsh restants pour repartir sur une base
# propre avant une réinstallation (après ./uninstall.sh ou installation partielle).
#
# Usage :
#   ./linux/purge_zsh.sh           # affiche ce qui sera supprimé et demande confirmation
#   ./linux/purge_zsh.sh --yes     # sans invite
#   ./linux/purge_zsh.sh --yes --with-history   # supprime aussi ~/.zsh_history
#
set -euo pipefail

AUTO_YES=0
WITH_HISTORY=0
for arg in "$@"; do
  case "$arg" in
    --yes|-y) AUTO_YES=1 ;;
    --with-history) WITH_HISTORY=1 ;;
    --help|-h)
      grep '^#' "$0" | head -15
      exit 0
      ;;
  esac
done

confirm() {
  local msg=$1
  if [[ "$AUTO_YES" -eq 1 ]]; then
    echo "OK (--yes): $msg"
    return 0
  fi
  read -r -p "$msg [o/N] " reply
  [[ "${reply,,}" == "o" || "${reply,,}" == "oui" || "$reply" == "y" || "$reply" == "Y" ]]
}

echo "=== Purge zsh / Oh My Zsh (résidus) ==="
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
  echo "Aucun fichier ou dossier cible trouvé (~/.oh-my-zsh, ~/.zshrc, .zcompdump*, etc.)."
  echo "Rien à faire."
  exit 0
fi

echo "Seront supprimés définitivement :"
printf '  %s\n' "${targets[@]}"
echo ""

if [[ "$WITH_HISTORY" -ne 1 ]] && [[ -f "$HOME/.zsh_history" ]]; then
  echo "(~/.zsh_history est conservé. Pour le supprimer aussi : $0 --yes --with-history)"
  echo ""
fi

if ! confirm "Continuer la suppression ?"; then
  echo "Annulé."
  exit 1
fi

for p in "${targets[@]}"; do
  if [[ -d "$p" ]]; then
    echo "Suppression dossier : $p"
    rm -rf "$p"
  elif [[ -f "$p" || -L "$p" ]]; then
    echo "Suppression fichier : $p"
    rm -f "$p"
  fi
done

echo ""
echo "Terminé. Tu peux relancer ./linux/install.sh (ou les scripts sous linux/) depuis une session bash."
echo "Fichiers non gérés ici (à vérifier à la main si besoin) : ~/.zshenv, ~/.zprofile, ~/.zlogin, ~/.dircolors."
