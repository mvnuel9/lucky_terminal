# Lucky Terminal — macOS

![Aperçu du terminal](./macos.png)

Tu es sur **Mac** ? Tu es au bon endroit : ce dossier contient **tout** ce qu’il faut pour appliquer le thème customisé (invite Zsh, couleurs, `ls` agréable). Les scripts sous `linux/` sont pour Linux uniquement ici on utilise `macos/install.sh` et les fichiers de `macos/configs/`.

---

## 🗂️ Arborescence du dossier

```
macos/
├── configs/
│   ├── README.md
│   ├── .vimrc
│   ├── .zshrc
│   ├── dircolors
│   └── mvnuel-agnoster.zsh-theme
├── fonts/
│   ├── RobotoMono/         # Polices Powerline (TTF)
│   └── install.sh
├── install.sh              # Enchaîne les trois étapes
├── install_powerline.sh    # Homebrew deps + pipx + polices + .vimrc
├── install_terminal.sh     # Oh My Zsh + fichiers aliases/functions
├── install_profile.sh      # Plug-ins Zsh, thème Mvnuel, profil Terminal.app
├── Mvnuel.itermcolors      # Jeu de couleurs pour iTerm2
├── mvnuel.terminal         # Profil pour Terminal.app
├── purge_zsh.sh
├── uninstall.sh
└── README.md
```

---

## 💡 Ce que font les fichiers

### Mode one-click (installation en un clic)
- **`install.sh`** : le **parcours tout-en-un** — enchaîne les trois étapes ci-dessous, idéal pour « tout d'un coup ».

### Mode étapes (pour debugger / installer à la carte)
- **`install_powerline.sh`** : prépare l'environnement (**Homebrew**, `pipx`, `powerline-status`), copie le `.vimrc` et installe les polices `Roboto Mono for Powerline` dans `~/Library/Fonts`.
- **`install_terminal.sh`** : installe ou conserve **Oh My Zsh**, crée les fichiers `~/.aliases` et `~/.functions`.
- **`install_profile.sh`** : clone les plug-ins Zsh (syntax highlighting, autosuggestions), copie les configs (`.zshrc`, `dircolors`, thème Mvnuel) et importe le profil **Terminal.app** via `mvnuel.terminal`.

### Assets
- **`Mvnuel.itermcolors`** : préréglage de couleurs pour **iTerm2**.
- **`mvnuel.terminal`** : profil « tout prêt » pour **Terminal.app** — importé automatiquement par `install_profile.sh` si `python3` est disponible.

### Désinstallation
- **`uninstall.sh`** : enlève une partie de ce qui a été posé par le projet (sans tout casser sur ta machine).
- **`purge_zsh.sh`** : nettoyage plus profond si tu veux repartir de zéro côté zsh / Oh My Zsh (avec options pour limiter les questions ou effacer aussi l'historique si tu le souhaites).

---

## ⌨️ Commandes

**Installation one-click** (depuis la racine du dépôt) :

```bash
chmod +x macos/install.sh
./macos/install.sh
```

**Installation étape par étape** (même ordre que le script maître) :

```bash
chmod +x macos/install_powerline.sh macos/install_terminal.sh macos/install_profile.sh
./macos/install_powerline.sh
./macos/install_terminal.sh
./macos/install_profile.sh
```

Ensuite, ouvre un **nouveau terminal** ou lance `exec zsh` pour profiter du shell. Si le profil graphique ne suit pas tout de suite, ferme et rouvre **Terminal** (ou une nouvelle fenêtre).

**Désinstallation (partielle)** :

```bash
chmod +x macos/uninstall.sh
./macos/uninstall.sh
```

**Purge zsh** (résidus, réinstallation propre) :

```bash
chmod +x macos/purge_zsh.sh
./macos/purge_zsh.sh

#Sans invite : 
./macos/purge_zsh.sh --yes
```

Tu peux aussi regarder les options du script (par ex. historique) avec `--help` si le script le propose.

---

## 🎨 Terminal.app ou iTerm2 ?

- Le **prompt** et le shell suivent surtout  **`install.sh`** et ton **`.zshrc`**. 
- Pour la **fenêtre** (fond, couleurs ANSI) : **Terminal.app** utilise le profil **`mvnuel.terminal`** ; **iTerm2** profite de **`Mvnuel.itermcolors`** importé dans les réglages du profil.

Si un caractère du prompt semble « coupé », vérifie la **police** et la **taille** (Roboto Mono for Powerline), ou teste iTerm2 qui gère parfois mieux certains glyphes.

### 👌Recommandation
Télécharger et installer [iTerm2](https://iterm2.com/downloads/stable/iTerm2-3_6_9.zip) Pour une meilleure expérience et appréciation du terminal customisé

---

## 🌍 Ailleurs dans le dépôt

- **Linux** : `[linux/](../linux/)`
- **Windows** : `[windows/](../windows/)`
- **Vue d’ensemble** : [README à la racine](../README.md)

Inspiration amont : [pixegami/terminal-profile](https://github.com/pixegami/terminal-profile)

Bon terminal ! 🍀