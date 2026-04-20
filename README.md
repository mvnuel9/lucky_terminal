# Lucky Terminal

<p align="center">
    <img src="./header.svg" alt="Lucky Terminal — thème Automnale multi-plateforme" width="100%" />
</p>

**Lucky Terminal**, c’est une **boîte à outils** pour que ton terminal ressemble au thème **Automnale** : couleurs harmonisées (ambiance terreuse, chaleureuse voire un peu vintage), invite de commande lisible (style Agnoster), même logique sur **Linux**, **macOS** et **Windows**. L’idée : cloner le dépôt, lancer **un** script selon ton OS, et retrouver un environnement cohérent sans y passer la journée.

Inspiré des approches du type [pixegami/terminal-profile](https://github.com/pixegami/terminal-profile), ce dépôt va plus loin avec des scripts et configs **par plateforme** (installation, désinstallation, purge).

---

## Arborescence (vue d’ensemble)
```
lucky_terminal
├── linux/          # Config Linux
├── macos/          # Config MacOS
├── windows/        # Config Windows
└── README.md       # Documentation rapide
```

Pour le **détail fichier par fichier** (polices, configs, etc.), ouvre [`tree.txt`](tree.txt).

---

## 🚀 Commandes rapides

À lancer **depuis la racine** du dépôt cloné (`lucky_terminal/`).

| Plateforme | Action | Commande |
|------------|--------|----------|
| **Linux** | Tout installer | `chmod +x linux/install.sh && ./linux/install.sh` |
| **Linux** | Désinstaller | `chmod +x linux/uninstall.sh && ./linux/uninstall.sh` |
| **Linux** | Nettoyage poussé (zsh) | `chmod +x linux/purge_zsh.sh && ./linux/purge_zsh.sh` |
| **macOS** | Installer | `chmod +x macos/install.sh && ./macos/install.sh` |
| **macOS** | Désinstaller / purge | Voir [macos/README.md](macos/README.md) |
| **Windows** | Installer | `powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\install.ps1` |
| **Windows** | Sans questions | `… -File .\windows\install.ps1 -Yes` |
| **Windows** | Dossier polices externe | `… -File .\windows\install.ps1 -Yes -NerdFontDirectory "<chemin>"` |
| **Windows** | Forcer MAJ PSReadLine | `… -File .\windows\install.ps1 -Yes -ForcePSReadLineUpdate` |

Chaque plateforme propose aussi un **mode étape par étape** (`install_powerline`, `install_terminal`, `install_profile` pour Linux/macOS, et `install_fonts`, `install_terminal`, `install_profile` pour Windows) — utile pour debugger ou n'installer qu'une partie. Voir le README dédié.

Ne mélange pas les dossiers : les scripts **`linux/`** ne sont pas faits pour macOS, etc.

---

## 📚 Pour aller plus loin

| Système | Doc dédiée |
|---------|------------|
| Linux | [linux/README.md](linux/README.md) |
| macOS | [macos/README.md](macos/README.md) |
| Windows | [windows/README.md](windows/README.md) |

---

## 🔗 Ressources utiles

[Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) · [Powerline fonts](https://github.com/powerline/fonts) · [Oh My Posh](https://ohmyposh.dev/) · Inspiration : [pixegami/terminal-profile](https://github.com/pixegami/terminal-profile)
