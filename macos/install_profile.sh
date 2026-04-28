#!/usr/bin/env bash
#
# Étape 3/3 macOS : installe les plug-ins Oh My Zsh, le thème Mvnuel, les configs
# ~/.zshrc / ~/.dircolors, et le profil Terminal.app (Mvnuel) via plistlib (Python).
#
# Usage : depuis la racine du dépôt —  ./macos/install_profile.sh
#
# Variables d'environnement (avancé) :
#   ZSH_SYNTAX_HIGHLIGHTING_REF   Ref git de zsh-syntax-highlighting (défaut : master).
#   ZSH_AUTOSUGGESTIONS_REF       Ref git de zsh-autosuggestions (défaut : master).
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

[[ -f "${CONFIGS}/.zshrc" ]] || die "Dépôt incomplet : ${CONFIGS}/.zshrc introuvable (dossier macos/configs/)." "$LUCKY_EXIT_MISSING_FILE"
[[ -d "${HOME}/.oh-my-zsh" ]] || die "Oh My Zsh manquant. Lancez d'abord : ./macos/install_terminal.sh" "$LUCKY_EXIT_MISSING_FILE"

require_cmd git

log_info "=== Installation du profil Mvnuel (macOS) ==="

log_info "[1/3] Extensions Zsh (syntax highlighting, autosuggestions)..."
ZSH_CUSTOM="${HOME}/.oh-my-zsh/custom/plugins"
ZSH_SYNTAX_HIGHLIGHTING_REF="${ZSH_SYNTAX_HIGHLIGHTING_REF:-master}"
ZSH_AUTOSUGGESTIONS_REF="${ZSH_AUTOSUGGESTIONS_REF:-master}"
lucky_run mkdir -p "${ZSH_CUSTOM}"
clone_omz_plugin() {
  local url="$1"
  local ref="$2"
  local name
  name="$(basename "$url" .git)"
  if [[ -d "${ZSH_CUSTOM}/${name}" ]]; then
    log_info "    ${name} déjà présent."
  else
    log_info "    clone ${name} @ ${ref}"
    lucky_run git clone --depth=1 --branch "$ref" "$url" "${ZSH_CUSTOM}/${name}"
  fi
}
clone_omz_plugin "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$ZSH_SYNTAX_HIGHLIGHTING_REF"
clone_omz_plugin "https://github.com/zsh-users/zsh-autosuggestions.git" "$ZSH_AUTOSUGGESTIONS_REF"

log_info "[2/3] Copie des configs macOS (macos/configs/ → ~ et ~/.oh-my-zsh/themes)..."
lucky_run cp "${CONFIGS}/.zshrc" "${HOME}/.zshrc"
lucky_run cp "${CONFIGS}/dircolors" "${HOME}/.dircolors"
lucky_run cp "${CONFIGS}/dircolors.terminal" "${HOME}/.dircolors.terminal"
lucky_run cp "${CONFIGS}/mvnuel-agnoster.zsh-theme" "${HOME}/.oh-my-zsh/themes/mvnuel-agnoster.zsh-theme"

TERMINAL_APP_PROFILE="${SCRIPT_DIR}/mvnuel.terminal"
TERMINAL_PROFILE_NAME="Mvnuel"

log_info "[3/3] Terminal.app : profil « ${TERMINAL_PROFILE_NAME} » (import + défaut)..."
if [[ ! -f "${TERMINAL_APP_PROFILE}" ]]; then
  log_warn "${TERMINAL_APP_PROFILE} absent — importez le profil à la main (voir macos/README.md)."
elif ! command -v python3 >/dev/null 2>&1; then
  log_warn "python3 introuvable — importez macos/mvnuel.terminal à la main (double-clic ou Préférences → Profils → Importer)."
elif [[ "${LUCKY_DRY_RUN:-0}" -eq 1 ]]; then
  log_info "[dry-run] python3 plistlib update de Library/Preferences/com.apple.Terminal.plist"
else
  python3 - "${TERMINAL_APP_PROFILE}" "${TERMINAL_PROFILE_NAME}" <<'PY'
import plistlib
import sys
from pathlib import Path

profile_path = Path(sys.argv[1])
name = sys.argv[2]
home = Path.home()
prefs_path = home / "Library/Preferences/com.apple.Terminal.plist"

if not profile_path.is_file():
    print(f"(!) Fichier introuvable : {profile_path}", file=sys.stderr)
    sys.exit(1)

with open(profile_path, "rb") as f:
    profile = plistlib.load(f)
if not isinstance(profile, dict):
    print("(!) Format .terminal inattendu (dict attendu).", file=sys.stderr)
    sys.exit(1)

profile["name"] = name

if prefs_path.exists():
    with open(prefs_path, "rb") as f:
        prefs = plistlib.load(f)
else:
    prefs = {}

ws = prefs.get("Window Settings")
if not isinstance(ws, dict):
    ws = {}
prefs["Window Settings"] = ws
ws[name] = profile
prefs["Default Window Settings"] = name
prefs["Startup Window Settings"] = name

prefs_path.parent.mkdir(parents=True, exist_ok=True)
with open(prefs_path, "wb") as f:
    plistlib.dump(prefs, f, fmt=plistlib.FMT_BINARY)

print(f"    Profil « {name} » enregistré dans les préférences Terminal.app (défaut + démarrage).")
PY
  log_info "Fermez puis rouvrez Terminal.app (ou nouvelle fenêtre) pour appliquer."
fi

echo ""
log_ok "Étape Profil terminée."
