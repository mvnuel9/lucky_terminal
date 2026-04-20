#!/usr/bin/env bash
# Installation complète macOS (Homebrew + Oh My Zsh + configs Mvnuel) : enchaîne les trois étapes.
# Usage : depuis la racine du dépôt —  ./macos/install.sh
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Ce script est prévu pour macOS (Darwin)." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "${SCRIPT_DIR}/install_powerline.sh"
bash "${SCRIPT_DIR}/install_terminal.sh"
bash "${SCRIPT_DIR}/install_profile.sh"

echo ""
echo "✅ Installation terminée."
echo ""
echo "Étapes suivantes :"
echo "  1. iTerm2 : importez macos/Mvnuel.itermcolors → Profiles → Colors → Color Presets… → Import."
echo "  2. Terminal.app : profil « Mvnuel » déjà importé si l'étape ci-dessus a réussi ; sinon voir macos/README.md."
echo "  3. Choisissez la police « Roboto Mono for Powerline » (taille 13–14) dans le profil si besoin."
echo "  4. Nouveau terminal zsh :  exec zsh"
echo "  5. Si « dircolors » n'est pas reconnu, rouvrez le terminal après installation des coreutils."
echo ""
echo "Documentation : macos/README.md"
