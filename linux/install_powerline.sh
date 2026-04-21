#!/usr/bin/env bash

# Stop le script immédiatement en cas d'erreur
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installation de Powerline pour Vim..."

# Installer les dépendances système
echo "Installation des dépendances..."
sudo apt update
sudo apt install -y python3-full python3-pip pipx fonts-powerline

# Configurer pipx (solution moderne recommandée)
echo "Configuration de pipx..."
pipx ensurepath

# Recharge le PATH dans la session actuelle
export PATH="$HOME/.local/bin:$PATH"

# Installer Powerline avec pipx (isolé, propre)
echo "Installation de powerline-status..."
pipx install powerline-status

# Installer la configuration Vim
echo "Configuration de Vim..."

# Copier le fichier .vimrc
cp "${SCRIPT_DIR}/configs/.vimrc" ~/.vimrc

# Installer les polices personnalisées (optionnel)
echo "Installation des polices..."

# Créer le dossier si inexistant
mkdir -p ~/.fonts

# Copier les polices
cp -a "${SCRIPT_DIR}/fonts/." ~/.fonts/

# Mettre à jour le cache des polices
fc-cache -fv ~/.fonts/

# Vérification finale
echo "✅ Installation terminée !"

echo ""
echo "👉 IMPORTANT :"
echo "- Redémarre le terminal pour appliquer les changements"
echo "- S'assurer que le terminal utilise une police Powerline"
echo ""
echo "🎉 Powerline est prêt avec Vim !"