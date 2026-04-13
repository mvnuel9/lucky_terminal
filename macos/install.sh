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

echo ""
echo "✅ Installation terminée."
echo ""
echo "Étapes suivantes :"
echo "  1. Importez la couleur iTerm2 : macos/Mvnuel.itermcolors → iTerm2 → Settings → Profiles → Colors → Color Presets… → Import."
echo "  2. Choisissez la police « Roboto Mono for Powerline » (taille 13–14) dans le profil."
echo "  3. Ouvrez un nouveau terminal zsh :  exec zsh"
echo "  4. Si « dircolors » n’est pas reconnu, vérifiez : brew install coreutils (déjà fait) et relancez le terminal."
echo ""
echo "Documentation : macos/README.md"
