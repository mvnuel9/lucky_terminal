#!/usr/bin/env bash
#
# Désinstalle ce qui a été mis en place par, dans l'ordre :
#   linux/install_powerline.sh → linux/install_terminal.sh → linux/install_profile.sh
#
# Usage (depuis la racine du dépôt) :
#   ./linux/uninstall.sh                   # demande confirmation avant actions sensibles
#   ./linux/uninstall.sh --yes             # sans invite (adapté aux scripts)
#   ./linux/uninstall.sh --yes --apt       # désinstalle aussi fonts-powerline (apt)
#   ./linux/uninstall.sh --dry-run         # affiche les commandes sans les exécuter
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../scripts/_common.sh
. "${SCRIPT_DIR}/../scripts/_common.sh"

MVNUEL_PROFILE_ID="fb358fc9-49ea-4252-ad34-1d25c649e633"

APT_PURGE=0
parse_common_args "$@"
for arg in ${LUCKY_REMAINING_ARGS[@]+"${LUCKY_REMAINING_ARGS[@]}"}; do
  case "$arg" in
    --apt) APT_PURGE=1 ;;
    --help | -h)
      awk '/^#/{print; next} {exit}' "$0"
      exit 0
      ;;
    *)
      log_warn "Option inconnue ignorée : $arg"
      ;;
  esac
done

log_info "=== Désinstallation du profil terminal Mvnuel ==="
echo ""

# --- 1) powerline-status (pipx), comme install_powerline.sh ---
if command -v pipx >/dev/null 2>&1; then
  if pipx list 2>/dev/null | grep -q powerline-status; then
    log_info "[1/6] Désinstallation de powerline-status (pipx)..."
    lucky_run pipx uninstall powerline-status || true
  else
    log_info "[1/6] powerline-status absent de pipx — ignoré."
  fi
else
  log_info "[1/6] pipx introuvable — étape pipx ignorée."
fi

# --- 2) Vim : sauvegarde du .vimrc imposé par le dépôt (Powerline) ---
if [[ -f "$HOME/.vimrc" ]]; then
  if grep -q 'powerline/bindings/vim' "$HOME/.vimrc" 2>/dev/null; then
    bak="$HOME/.vimrc.bak.mvnuel-$(date +%Y%m%d-%H%M%S)"
    log_info "[2/6] Sauvegarde de ~/.vimrc → $bak"
    lucky_run mv "$HOME/.vimrc" "$bak"
  else
    log_info "[2/6] ~/.vimrc ne contient pas la config Powerline du dépôt — laissé tel quel."
  fi
else
  log_info "[2/6] Pas de ~/.vimrc — rien à retirer."
fi

# --- 3) Polices copiées depuis linux/fonts/ vers ~/.fonts/ ---
if [[ -d "$HOME/.fonts/RobotoMono" ]]; then
  log_info "[3/6] Suppression de ~/.fonts/RobotoMono (Roboto Mono for Powerline)..."
  lucky_run rm -rf "$HOME/.fonts/RobotoMono"
  if command -v fc-cache >/dev/null 2>&1; then
    lucky_run fc-cache -fv "$HOME/.fonts" 2>/dev/null || true
  fi
else
  log_info "[3/6] ~/.fonts/RobotoMono absent — ignoré."
fi

# --- 4) Profil GNOME Terminal (install_profile.sh / dconf) ---
if command -v dconf >/dev/null 2>&1; then
  log_info "[4/6] Retrait du profil GNOME Terminal « Mvnuel » (dconf)..."
  if [[ "${LUCKY_DRY_RUN:-0}" -eq 1 ]]; then
    log_info "[dry-run] étape Python/dconf non exécutée (profile=$MVNUEL_PROFILE_ID)"
  elif python3 - "$MVNUEL_PROFILE_ID" <<'PY'; then
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
    :
  else
    log_warn "    (avertissement : la partie dconf a signalé un problème — vérifiez les profils dans Préférences du terminal.)"
  fi
else
  log_info "[4/6] dconf absent — profil terminal non modifié (pas GNOME ?)."
fi

# --- 5) Shell par défaut → bash, puis Oh My Zsh ---
BASH_PATH="$(command -v bash || true)"
[[ -n "$BASH_PATH" ]] || die "bash introuvable dans le PATH." "$LUCKY_EXIT_MISSING_TOOL"

if [[ "$SHELL" != "$BASH_PATH" ]] && [[ -x "$BASH_PATH" ]]; then
  if confirm "Passer le shell de connexion par défaut à bash ($BASH_PATH) ?"; then
    log_info "[5a/6] chsh → bash"
    lucky_run chsh -s "$BASH_PATH" || log_warn "    chsh a échoué — exécutez : chsh -s $BASH_PATH"
  fi
else
  log_info "[5a/6] Shell par défaut déjà bash ou chsh ignoré."
fi

if [[ -f "$HOME/.oh-my-zsh/tools/uninstall.sh" ]]; then
  if confirm "Supprimer Oh My Zsh (~/.oh-my-zsh) et renommer ~/.zshrc ?"; then
    log_info "[5b/6] Lancement du désinstalleur officiel Oh My Zsh..."
    if [[ "${LUCKY_DRY_RUN:-0}" -eq 1 ]]; then
      log_info "[dry-run] printf 'y\\n' | bash $HOME/.oh-my-zsh/tools/uninstall.sh"
    else
      printf 'y\n' | bash "$HOME/.oh-my-zsh/tools/uninstall.sh" || true
    fi
  fi
else
  log_info "[5b/6] Pas de ~/.oh-my-zsh/tools/uninstall.sh — suppression manuelle si besoin."
  if [[ -d "$HOME/.oh-my-zsh" ]] && confirm "Supprimer le dossier ~/.oh-my-zsh ?"; then
    lucky_run rm -rf "$HOME/.oh-my-zsh"
  fi
  if [[ -f "$HOME/.zshrc" ]] && confirm "Renommer ~/.zshrc en sauvegarde ?"; then
    lucky_run mv "$HOME/.zshrc" "$HOME/.zshrc.bak.mvnuel-$(date +%Y%m%d-%H%M%S)"
  fi
fi

# --- 6) Paquets APT optionnels (install_powerline.sh) ---
if [[ "$APT_PURGE" -eq 1 ]]; then
  log_info "[6/6] Désinstallation des paquets apt (fonts-powerline)..."
  lucky_run sudo apt-get remove -y --auto-remove fonts-powerline || true
  log_info "    (python3-pip, pipx, python3-full n'ont pas été retirés — trop utilisés ailleurs.)"
else
  log_info "[6/6] Paquets apt conservés. Pour retirer fonts-powerline : $0 --yes --apt"
fi

echo ""
log_ok "Terminé. Fermez tous les terminaux, rouvrez-en un : vous devriez être en bash sans thème Mvnuel."
log_info "Si le terminal graphique reste bizarre : Préférences → profil par défaut, ou"
log_info "  dconf reset -f /org/gnome/terminal/legacy/profiles:/"
log_info "(efface tous les profils GNOME Terminal — à réserver en dernier recours.)"
