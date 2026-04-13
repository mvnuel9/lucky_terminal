# Profil terminal Mvnuel

![terminal](./mvnuel_terminal.png)

Ce projet est un fork **inspiré du dépôt [pixegami/terminal-profile](https://github.com/pixegami/terminal-profile)** (scripts d’installation en trois étapes, Oh My Zsh, thème Agnoster dérivé, profil GNOME Terminal). La base conceptuelle et la structure reprennent cette approche ; les couleurs, le nom du thème, `dircolors`, la démo HTML et le script de désinstallation sont des **extensions et personnalisations** propres à ce dépôt **Mvnuel**.

Configuration **Zsh + Oh My Zsh** pour Ubuntu / Linux (GNOME Terminal), avec une **palette personnalisée** (tons chauds, crème, accents verts / cyan) et un thème Agnoster dérivé. Sous macOS, vous pouvez vous inspirer des mêmes fichiers ; les commandes d’installation diffèrent souvent ([iTerm2](https://iterm2.com/), etc.).

Les scripts d’origine (côté Pixegami) ont été testés sur Ubuntu 20 ; ce dépôt a depuis été **enrichi** (palette Mvnuel, `dircolors`, démo web, script de désinstallation).

## Contenu du dépôt (principaux fichiers)

| Élément | Rôle |
|--------|------|
| `install_powerline.sh` | Polices Powerline, Vim, `pipx` + `powerline-status` |
| `install_terminal.sh` | Zsh, Oh My Zsh |
| `install_profile.sh` | Extensions Zsh, `~/.zshrc`, `~/.dircolors`, thème `mvnuel-agnoster`, profil GNOME Terminal, `chsh` → zsh |
| `uninstall.sh` | Retour bash, retrait du profil Mvnuel, Oh My Zsh, Powerline (pipx), etc. |
| `configs/terminal_profile.dconf` | Couleurs + police du terminal GNOME |
| `configs/mvnuel-agnoster.zsh-theme` | Prompt Powerline (couleurs hex) |
| `configs/dircolors` | Couleurs de `ls` (GNU `dircolors`) |

# Prérequis

```bash
# Mise à jour des paquets système
sudo apt-get update
sudo apt-get upgrade

# Instalation de Git et Vim
sudo apt-get install -y git vim
```

# Installation

Exécuter **dans l’ordre**, depuis la racine du dépôt :

```bash
chmod +x install_powerline.sh install_terminal.sh install_profile.sh
./install_powerline.sh
./install_terminal.sh
./install_profile.sh
```

Après installation, **ouvrez un nouveau terminal** (ou reconnectez-vous) pour que zsh et les couleurs soient pris en compte.

# Désinstallation

Le script annule l’essentiel des trois étapes d’installation (profil GNOME Mvnuel, Powerline via pipx, polices RobotoMono sous `~/.fonts`, sauvegarde d’un `.vimrc` Powerline, bash par défaut, Oh My Zsh, etc.) :

```bash
chmod +x uninstall.sh
./uninstall.sh
```

Options : `./uninstall.sh --yes` (sans questions), `./uninstall.sh --yes --apt` (retire aussi le paquet `fonts-powerline`).

Réinitialisation manuelle du terminal : [Ask Ubuntu — reset terminal](https://askubuntu.com/questions/14487/how-to-reset-the-terminal-properties-and-preferences)  
Retour bash / zsh : [Ask Ubuntu — remove zsh](https://askubuntu.com/questions/958120/remove-zsh-from-ubuntu-16-04)

## Notes utiles

Exporter les profils GNOME Terminal actuels :

```bash
dconf dump /org/gnome/terminal/legacy/profiles:/ > gnome-terminal-profiles.dconf
```

**Neofetch** (optionnel) :

```bash
sudo apt-get install neofetch
neofetch
```

## Sources

**Amont / inspiration :** [pixegami/terminal-profile](https://github.com/pixegami/terminal-profile)

[Oh My Zsh !](https://medium.com/wearetheledger/oh-my-zsh-made-for-cli-lovers-installation-guide-3131ca5491fb) | [Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh) | [Installer Powerline](https://askubuntu.com/questions/283908/how-can-i-install-and-use-powerline-plugin) | [Polices Powerline](https://github.com/powerline/fonts) | [Thème Agnoster](https://gist.github.com/3712874)
