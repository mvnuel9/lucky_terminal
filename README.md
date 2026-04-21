# Lucky Terminal



**Lucky Terminal**, c’est une **boîte à outils** pour que ton terminal ressemble au thème **Automnale** : couleurs harmonisées (ambiance terreuse, chaleureuse voire un peu vintage), invite de commande lisible (style Agnoster), même logique sur **Linux**, **macOS** et **Windows**. L’idée : cloner le dépôt, lancer **un** script selon ton OS, et retrouver un environnement cohérent sans y passer la journée.

Inspiré des approches du type [pixegami/terminal-profile](https://github.com/pixegami/terminal-profile), ce dépôt va plus loin avec des scripts et configs **par plateforme** (installation, désinstallation, purge).

---

## 🖼️ Aperçu


| **Linux** · Ubuntu + GNOME       | **macOS** · Terminal.app / iTerm2 | **Windows** · PowerShell + Oh My Posh |
| -------------------------------- | --------------------------------- | ------------------------------------- |
| ![Linux](linux/linux.png)        | ![macOS](macos/macos.png)         | ![Windows](windows/powershell.png)    |


---

## Arborescence (vue d’ensemble)

```
lucky_terminal
├── linux/          # Config Linux (Ubuntu + GNOME)
├── macos/          # Config macOS (Terminal.app / iTerm2)
├── windows/        # Config Windows (PowerShell + Oh My Posh)
├── header.svg      # Bannière du README
├── tree.txt        # Arborescence détaillée
└── README.md       # Documentation rapide
```

Pour le **détail fichier par fichier** (polices, configs, etc.), ouvre `[tree.txt](tree.txt)`.

---

## 📋 Prérequis

- **Linux** : Ubuntu (ou dérivé Debian), `git`, `vim`, GNOME Terminal recommandé.
- **macOS** : [Homebrew](https://brew.sh) installé, Terminal.app ou iTerm2.
- **Windows** : PowerShell 5.1+ (ou 7+), connexion Internet (winget + modules).

---

## 🚀 Commandes rapides

À lancer **depuis la racine** du dépôt cloné (`lucky_terminal/`).


| Plateforme  | Action                  | Commande                                                                    |
| ----------- | ----------------------- | --------------------------------------------------------------------------- |
| **Linux**   | Tout installer          | `chmod +x linux/install.sh && ./linux/install.sh`                           |
| **Linux**   | Désinstaller            | `chmod +x linux/uninstall.sh && ./linux/uninstall.sh`                       |
| **Linux**   | Nettoyage poussé (zsh)  | `chmod +x linux/purge_zsh.sh && ./linux/purge_zsh.sh`                       |
| **macOS**   | Tout installer          | `chmod +x macos/install.sh && ./macos/install.sh`                           |
| **macOS**   | Désinstaller            | `chmod +x macos/uninstall.sh && ./macos/uninstall.sh`                       |
| **macOS**   | Nettoyage poussé (zsh)  | `chmod +x macos/purge_zsh.sh && ./macos/purge_zsh.sh`                       |
| **Windows** | Tout installer          | `powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\install.ps1` |
| **Windows** | Sans questions          | `… -File .\windows\install.ps1 -Yes`                                        |
| **Windows** | Désinstaller            | `… -File .\windows\uninstall.ps1`                                           |
| **Windows** | Purge résiduelle        | `… -File .\windows\purge_profile.ps1`                                       |
| **Windows** | Dossier polices externe | `… -File .\windows\install.ps1 -Yes -NerdFontDirectory "<chemin>"`          |
| **Windows** | Forcer MAJ PSReadLine   | `… -File .\windows\install.ps1 -Yes -ForcePSReadLineUpdate`                 |


Chaque plateforme propose aussi un **mode étape par étape** (`install_powerline`, `install_terminal`, `install_profile` pour Linux/macOS, et `install_fonts`, `install_terminal`, `install_profile` pour Windows) utile pour debugger ou n'installer qu'une partie. Voir le README dédié.

Ne mélange pas les dossiers : les scripts `**linux/`** ne sont pas faits pour macOS, etc.

---

## 📚 Pour aller plus loin


| Système | Doc dédiée                             |
| ------- | -------------------------------------- |
| Linux   | [linux/README.md](linux/README.md)     |
| macOS   | [macos/README.md](macos/README.md)     |
| Windows | [windows/README.md](windows/README.md) |


---

## 🔗 Ressources utiles

[Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) · [Powerline fonts](https://github.com/powerline/fonts) · [Nerd Fonts](https://www.nerdfonts.com/) · [Oh My Posh](https://ohmyposh.dev/) · Inspiration : [pixegami/terminal-profile](https://github.com/pixegami/terminal-profile)

---

## 📄 Licence

Ce projet est distribué sous licence **[MIT](LICENSE)**. Les polices embarquées conservent leurs licences d'origine (Apache 2.0 pour Roboto Mono et sa variante Nerd Font — voir `*/fonts/RobotoMono/LICENSE.txt`).