#!/usr/bin/env bash
#
# Désinstalle ce qui a été mis en place par, dans l'ordre :
#   install_powerline.sh → install_terminal.sh → install_profile.sh
#
# Usage :
#   ./uninstall.sh              # demande confirmation avant actions sensibles
#   ./uninstall.sh --yes        # sans invite (adapté aux scripts)
#   ./uninstall.sh --yes --apt  # désinstalle aussi fonts-powerline (apt)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MVNUEL_PROFILE_ID="fb358fc9-49ea-4252-ad34-1d25c649e633"

AUTO_YES=0
APT_PURGE=0
for arg in "$@"; do
  case "$arg" in
    --yes|-y) AUTO_YES=1 ;;
    --apt) APT_PURGE=1 ;;
    --help|-h)
      grep '^#' "$0" | head -20
      exit 0
      ;;
  esac
done

confirm() {
  local msg=$1
  if [[ "$AUTO_YES" -eq 1 ]]; then
    echo "OK (mode --yes): $msg"
    return 0
  fi
  read -r -p "$msg [o/N] " reply
  [[ "${reply,,}" == "o" || "${reply,,}" == "oui" || "$reply" == "y" || "$reply" == "Y" ]]
}

die() {
  echo "Erreur: $*" >&2
  exit 1
}

echo "=== Désinstallation du profil terminal Mvnuel ==="
echo ""

# --- 1) powerline-status (pipx), comme install_powerline.sh ---
if command -v pipx >/dev/null 2>&1; then
  if pipx list 2>/dev/null | grep -q powerline-status; then
    echo "[1/6] Désinstallation de powerline-status (pipx)..."
    pipx uninstall powerline-status || true
  else
    echo "[1/6] powerline-status absent de pipx — ignoré."
  fi
else
  echo "[1/6] pipx introuvable — étape pipx ignorée."
fi

# --- 2) Vim : sauvegarde du .vimrc imposé par le dépôt (Powerline) ---
if [[ -f "$HOME/.vimrc" ]]; then
  if grep -q 'powerline/bindings/vim' "$HOME/.vimrc" 2>/dev/null; then
    bak="$HOME/.vimrc.bak.mvnuel-$(date +%Y%m%d-%H%M%S)"
    echo "[2/6] Sauvegarde de ~/.vimrc → $bak"
    mv "$HOME/.vimrc" "$bak"
  else
    echo "[2/6] ~/.vimrc ne contient pas la config Powerline du dépôt — laissé tel quel."
  fi
else
  echo "[2/6] Pas de ~/.vimrc — rien à retirer."
fi

# --- 3) Polices copiées depuis fonts/ vers ~/.fonts/ ---
if [[ -d "$HOME/.fonts/RobotoMono" ]]; then
  echo "[3/6] Suppression de ~/.fonts/RobotoMono (Roboto Mono for Powerline)..."
  rm -rf "$HOME/.fonts/RobotoMono"
  if command -v fc-cache >/dev/null 2>&1; then
    fc-cache -fv "$HOME/.fonts" 2>/dev/null || true
  fi
else
  echo "[3/6] ~/.fonts/RobotoMono absent — ignoré."
fi

# --- 4) Profil GNOME Terminal (install_profile.sh / dconf) ---
if command -v dconf >/dev/null 2>&1; then
  echo "[4/6] Retrait du profil GNOME Terminal « Mvnuel » (dconf)..."
  if python3 - "$MVNUEL_PROFILE_ID" <<'PY'
import subprocess
import sys
import ast
import re

profile = sys.argv[1]
key_list = "/org/gnome/terminal/legacy/profiles:/list"
key_default = "/org/gnome/terminal/legacy/profiles:/default"

def dread(k):
    try:
        out = subprocess.check_output(["dconf", "read", k], text=True, stderr=subprocess.DEVNULL).strip()
    except subprocess.CalledProcessError:
        return None
    return out

def dwrite(k, v):
    subprocess.check_call(["dconf", "write", k, v])

raw = dread(key_list)
if raw in (None, "", "@as []"):
    print("Liste de profils vide ou absente — rien à modifier pour GNOME Terminal.")
    sys.exit(0)

# GVariant typique : "['uuid1', 'uuid2']"
s = raw
try:
    uuids = ast.literal_eval(s)
except (ValueError, SyntaxError):
    uuids = re.findall(r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", s)

if not isinstance(uuids, list):
    print("Impossible d'analyser la liste de profils — passez cette étape ou réinitialisez les profils à la main.")
    sys.exit(0)

if profile not in uuids:
    print("UUID du profil Mvnuel absent de la liste — profils dconf inchangés pour la liste.")
else:
    new_uuids = [u for u in uuids if u != profile]
    if not new_uuids:
        print(
            "Attention : il ne resterait aucun profil. "
            "Réinitialisation complète des profils GNOME Terminal (comme une remise à zéro)."
        )
        subprocess.check_call(["dconf", "reset", "-f", "/org/gnome/terminal/legacy/profiles:/"])
        sys.exit(0)

    def fmt_list(lst):
        return "[" + ", ".join("'" + u + "'" for u in lst) + "]"

    dwrite(key_list, fmt_list(new_uuids))

    cur_default = dread(key_default)
    if cur_default is not None and profile in cur_default:
        replacement = "'" + new_uuids[0] + "'"
        dwrite(key_default, replacement)

    subprocess.call(
        ["dconf", "reset", "-f", f"/org/gnome/terminal/legacy/profiles:/:{profile}/"],
        stderr=subprocess.DEVNULL,
    )
    print("Profil Mvnuel retiré et entrée dconf nettoyée.")
PY
  then
    :
  else
    echo "    (avertissement : la partie dconf a signalé un problème — vérifiez les profils dans Préférences du terminal.)"
  fi
else
  echo "[4/6] dconf absent — profil terminal non modifié (pas GNOME ?)."
fi

# --- 5) Shell par défaut → bash, puis Oh My Zsh ---
BASH_PATH="$(command -v bash || true)"
[[ -n "$BASH_PATH" ]] || die "bash introuvable dans le PATH."

if [[ "$SHELL" != "$BASH_PATH" ]] && [[ -x "$BASH_PATH" ]]; then
  if confirm "Passer le shell de connexion par défaut à bash ($BASH_PATH) ?"; then
    echo "[5a/6] chsh → bash"
    chsh -s "$BASH_PATH" || echo "    chsh a échoué — exécutez : chsh -s $BASH_PATH"
  fi
else
  echo "[5a/6] Shell par défaut déjà bash ou chsh ignoré."
fi

if [[ -f "$HOME/.oh-my-zsh/tools/uninstall.sh" ]]; then
  if confirm "Supprimer Oh My Zsh (~/.oh-my-zsh) et renommer ~/.zshrc ?"; then
    echo "[5b/6] Lancement du désinstalleur officiel Oh My Zsh..."
    printf 'y\n' | bash "$HOME/.oh-my-zsh/tools/uninstall.sh" || true
  fi
else
  echo "[5b/6] Pas de ~/.oh-my-zsh/tools/uninstall.sh — suppression manuelle si besoin."
  if [[ -d "$HOME/.oh-my-zsh" ]] && confirm "Supprimer le dossier ~/.oh-my-zsh ?"; then
    rm -rf "$HOME/.oh-my-zsh"
  fi
  if [[ -f "$HOME/.zshrc" ]] && confirm "Renommer ~/.zshrc en sauvegarde ?"; then
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak.mvnuel-$(date +%Y%m%d-%H%M%S)"
  fi
fi

# --- 6) Paquets APT optionnels (install_powerline.sh) ---
if [[ "$APT_PURGE" -eq 1 ]]; then
  echo "[6/6] Désinstallation des paquets apt (fonts-powerline)..."
  sudo apt-get remove -y --auto-remove fonts-powerline || true
  echo "    (python3-pip, pipx, python3-full n'ont pas été retirés — trop utilisés ailleurs.)"
else
  echo "[6/6] Paquets apt conservés. Pour retirer fonts-powerline : $0 --yes --apt"
fi

echo ""
echo "Terminé. Fermez tous les terminaux, rouvrez-en un : vous devriez être en bash sans thème Mvnuel."
echo "Si le terminal graphique reste bizarre : Préférences → profil par défaut, ou"
echo "  dconf reset -f /org/gnome/terminal/legacy/profiles:/"
echo "(efface tous les profils GNOME Terminal — à réserver en dernier recours.)"
