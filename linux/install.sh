#!/usr/bin/env bash
# Installation complète Linux (Ubuntu + GNOME Terminal) : enchaîne les trois étapes.
# Usage : depuis la racine du dépôt —  ./linux/install.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "${SCRIPT_DIR}/install_powerline.sh"
bash "${SCRIPT_DIR}/install_terminal.sh"
bash "${SCRIPT_DIR}/install_profile.sh"
