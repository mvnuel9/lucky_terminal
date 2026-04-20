#!/usr/bin/env bash
# Installe les plug-ins Oh My Zsh, le thème Mvnuel, les configs ~/.zshrc / ~/.dircolors,
# et le profil Terminal.app (Mvnuel) via plistlib (Python).
# Usage : depuis la racine du dépôt —  ./macos/install_profile.sh
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Ce script est prévu pour macOS (Darwin)." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS="${SCRIPT_DIR}/configs"

if [[ ! -f "${CONFIGS}/.zshrc" ]]; then
  echo "Dépôt incomplet : ${CONFIGS}/.zshrc introuvable (dossier macos/configs/)." >&2
  exit 1
fi

if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
  echo "Oh My Zsh manquant. Lancez d'abord : ./macos/install_terminal.sh" >&2
  exit 1
fi

echo "==> Extensions Zsh (syntax highlighting, autosuggestions)..."
ZSH_CUSTOM="${HOME}/.oh-my-zsh/custom/plugins"
mkdir -p "${ZSH_CUSTOM}"
clone_omz_plugin() {
  local url="$1"
  local name
  name="$(basename "$url" .git)"
  if [[ ! -d "${ZSH_CUSTOM}/${name}" ]]; then
    git clone --depth=1 "$url" "${ZSH_CUSTOM}/${name}"
  else
    echo "    ${name} déjà présent."
  fi
}
clone_omz_plugin "https://github.com/zsh-users/zsh-syntax-highlighting.git"
clone_omz_plugin "https://github.com/zsh-users/zsh-autosuggestions.git"

echo "==> Copie des configs macOS (macos/configs/ → ~ et ~/.oh-my-zsh/themes)..."
cp "${CONFIGS}/.zshrc" "${HOME}/.zshrc"
cp "${CONFIGS}/dircolors" "${HOME}/.dircolors"
cp "${CONFIGS}/mvnuel-agnoster.zsh-theme" "${HOME}/.oh-my-zsh/themes/mvnuel-agnoster.zsh-theme"

TERMINAL_APP_PROFILE="${SCRIPT_DIR}/mvnuel.terminal"
TERMINAL_PROFILE_NAME="Mvnuel"

echo "==> Terminal.app : profil « ${TERMINAL_PROFILE_NAME} » (import + défaut)..."
if [[ -f "${TERMINAL_APP_PROFILE}" ]] && command -v python3 >/dev/null 2>&1; then
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
  echo "    Fermez puis rouvrez Terminal.app (ou nouvelle fenêtre) pour appliquer."
else
  if [[ ! -f "${TERMINAL_APP_PROFILE}" ]]; then
    echo "(!) ${TERMINAL_APP_PROFILE} absent — importez le profil à la main (voir macos/README.md)."
  else
    echo "(!) python3 introuvable — importez macos/mvnuel.terminal à la main (double-clic ou Préférences → Profils → Importer)."
  fi
fi

echo "✅ Étape Profil terminée."
