#!/usr/bin/env bash
# Installation profil Mvnuel pour macOS (Homebrew + Oh My Zsh + configs).
# Usage : depuis la racine du dépôt —  ./macos/install.sh
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Ce script est prévu pour macOS (Darwin)." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONFIGS="${SCRIPT_DIR}/configs"
FONTS_SRC="${REPO_ROOT}/fonts"

if [[ ! -f "${CONFIGS}/.zshrc" ]]; then
  echo "Dépôt incomplet : ${CONFIGS}/.zshrc introuvable (dossier macos/configs/). Lancez ce script depuis le clone terminal-profile." >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew est requis : https://brew.sh" >&2
  echo 'Installez-le puis relancez : /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' >&2
  exit 1
fi

echo "==> Mise à jour Homebrew et installation des dépendances (python, pipx, git, coreutils)..."
brew update
brew install python pipx git coreutils

echo "==> pipx : PATH utilisateur (ajoutez à ~/.zprofile si besoin)..."
pipx ensurepath || true
export PATH="${HOME}/.local/bin:${PATH}"

echo "==> powerline-status (Vim)..."
pipx install powerline-status

echo "==> Configuration Vim (macos/configs/.vimrc)..."
cp "${CONFIGS}/.vimrc" "${HOME}/.vimrc"

echo "==> Polices Roboto Mono Powerline → ~/Library/Fonts ..."
mkdir -p "${HOME}/Library/Fonts"
if [[ -d "${FONTS_SRC}/RobotoMono" ]]; then
  cp -R "${FONTS_SRC}/RobotoMono" "${HOME}/Library/Fonts/"
else
  echo "(!) Dossier fonts/RobotoMono absent — copiez les polices à la main si besoin."
fi

echo "==> Fichiers pour ~/.zshrc (aliases / functions)..."
touch "${HOME}/.aliases" "${HOME}/.functions"

echo "==> Oh My Zsh..."
if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
  echo "    Installation (sans changer le shell ni ouvrir un nouveau zsh à la fin)..."
  export RUNZSH=no
  export CHSH=no
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "    ~/.oh-my-zsh existe déjà — on conserve."
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
ITERM2_PROFILE="${SCRIPT_DIR}/Mvnuel.itermcolors"
TERMINAL_PROFILE_NAME="Mvnuel"

echo "==> Terminal.app : profil « ${TERMINAL_PROFILE_NAME} » (import + défaut)..."
if [[ -f "${TERMINAL_APP_PROFILE}" ]] && command -v python3 >/dev/null 2>&1; then
  python3 - "${TERMINAL_APP_PROFILE}" "${ITERM2_PROFILE}" "${TERMINAL_PROFILE_NAME}" <<'PY'
import plistlib
import re
import sys
from pathlib import Path

profile_path = Path(sys.argv[1])
iterm_profile_path = Path(sys.argv[2])
name = sys.argv[3]
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

# Synchronise les couleurs Terminal.app depuis Mvnuel.itermcolors pour éviter les divergences.
if iterm_profile_path.is_file():
    with open(iterm_profile_path, "rb") as f:
        iterm = plistlib.load(f)

    ansi_map = {
        "ANSIBlackColor": "Ansi 0 Color",
        "ANSIRedColor": "Ansi 1 Color",
        "ANSIGreenColor": "Ansi 2 Color",
        "ANSIYellowColor": "Ansi 3 Color",
        "ANSIBlueColor": "Ansi 4 Color",
        "ANSIMagentaColor": "Ansi 5 Color",
        "ANSICyanColor": "Ansi 6 Color",
        "ANSIWhiteColor": "Ansi 7 Color",
        "ANSIBrightBlackColor": "Ansi 8 Color",
        "ANSIBrightRedColor": "Ansi 9 Color",
        "ANSIBrightGreenColor": "Ansi 10 Color",
        "ANSIBrightYellowColor": "Ansi 11 Color",
        "ANSIBrightBlueColor": "Ansi 12 Color",
        "ANSIBrightMagentaColor": "Ansi 13 Color",
        "ANSIBrightCyanColor": "Ansi 14 Color",
        "ANSIBrightWhiteColor": "Ansi 15 Color",
        "BackgroundColor": "Background Color",
        "TextColor": "Foreground Color",
        "TextBoldColor": "Bold Color",
        "CursorColor": "Cursor Color",
        "SelectionColor": "Selection Color",
    }

    template_blob = profile.get("ANSIBlackColor")
    blob_pattern = re.compile(rb"4[01]\.[0-9]{10} 0\.[0-9]{10} 0\.[0-9]{10} 1\.[0-9]{10}")

    def to_nscolor_blob(color):
        color_str = (
            f"4{color['Red Component']:.10f} "
            f"{color['Green Component']:.10f} "
            f"{color['Blue Component']:.10f} "
            f"{color['Alpha Component']:.10f}"
        ).encode()
        return blob_pattern.sub(color_str, template_blob, count=1)

    if isinstance(template_blob, (bytes, bytearray)) and blob_pattern.search(template_blob):
        for terminal_key, iterm_key in ansi_map.items():
            color = iterm.get(iterm_key)
            if isinstance(color, dict):
                profile[terminal_key] = to_nscolor_blob(color)
    else:
        print("(!) Impossible de synchroniser les couleurs Terminal.app depuis Mvnuel.itermcolors.", file=sys.stderr)
else:
    print(f"(!) Fichier introuvable : {iterm_profile_path} (palette Terminal non synchronisée).", file=sys.stderr)

profile["name"] = name
# Sur clavier AZERTY, Option ne doit pas être utilisée comme Meta,
# sinon ~ et d'autres caractères Alt/AltGr deviennent inutilisables.
profile["useOptionAsMetaKey"] = False

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

echo ""
echo "✅ Installation terminée."
echo ""
echo "Étapes suivantes :"
echo "  1. iTerm2 : importez macos/Mvnuel.itermcolors → Profiles → Colors → Color Presets… → Import."
echo "  2. Terminal.app : profil « ${TERMINAL_PROFILE_NAME} » déjà importé si l’étape ci-dessus a réussi ; sinon voir macos/README.md."
echo "  3. Terminal.app → Réglages → Profils → Mvnuel → Texte : forcez « Roboto Mono for Powerline » (13–14) si les séparateurs sont déformés."
echo "  4. Nouveau terminal zsh :  exec zsh"
echo "  5. Si « dircolors » n’est pas reconnu, rouvrez le terminal après installation des coreutils."
echo ""
echo "Documentation : macos/README.md"
