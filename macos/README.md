# Lucky Terminal — macOS

**Vous êtes sur macOS ?** C’est le **seul** dossier d’installation à utiliser (`install.sh`, `macos/configs/`). Les scripts `install_powerline.sh` / `install_terminal.sh` / `install_profile.sh` à la racine du dépôt sont réservés à **Linux (Ubuntu + GNOME Terminal)**.

Ce dossier est **autonome** : les configurations shell/Vim/thème pour macOS vivent dans **`macos/configs/`**, séparées du dossier **`configs/`** (Linux / Ubuntu + GNOME Terminal).

## Arborescence

```
macos/
├── README.md                 # Documentation
├── install.sh                # Installation du thème
├── uninstall.sh              # Script de désintallation du thème
├── purge_zsh.sh              # Nettoyage résiduel zsh / Oh My Zsh avant réinstall
├── Mvnuel.itermcolors        # Jeu de couleurs iTerm2
├── mvnuel.terminal           # Profil Terminal.app (import auto par install.sh)
└── configs/                  # Configurations dédiées macOS
    ├── README.md
    ├── .vimrc
    ├── .zshrc
    ├── dircolors
    └── mvnuel-agnoster.zsh-theme
```

Les **polices** restent à la racine du dépôt (`fonts/`) : `install.sh` les copie vers `~/Library/Fonts/`.

## Prérequis

- **macOS** récent
- [Homebrew](https://brew.sh/) (`brew`)
- Accès Internet (curl, git, clones Oh My Zsh)

## Installation rapide

Depuis la **racine du dépôt** :

```bash
chmod +x macos/install.sh
./macos/install.sh
```

Le script installe les dépendances Homebrew (**python**, **pipx**, **git**, **coreutils**), **powerline-status**, copie les polices, installe **Oh My Zsh** si besoin, clone les plugins, copie **`macos/configs/`** vers `~` et `~/.oh-my-zsh/themes/`, puis **importe le profil Terminal.app** depuis **`mvnuel.terminal`** dans `~/Library/Preferences/com.apple.Terminal.plist` et le définit comme **profil par défaut** et **au démarrage** (nécessite **python3**, fourni par Homebrew dans ce flux).

Ensuite : **nouveau terminal** ou `exec zsh`. **Fermez puis rouvrez Terminal.app** (ou ouvrez une nouvelle fenêtre) pour appliquer le profil graphique.

## Couleurs du terminal

L’installation **shell** (`install.sh`) est la même que vous utilisiez **Terminal.app** (intégré à macOS) ou **iTerm2**. Seule la **mise en couleur de la fenêtre** change.

### Avec iTerm2 (import rapide)

1. **iTerm2 → Settings → Profiles → Colors → Color Presets… → Import…**
2. Fichier **`macos/Mvnuel.itermcolors`**, puis choisir le préréglage **Mvnuel**.
3. **Text** : police **Roboto Mono for Powerline**, taille **13–14**.

### Avec Terminal.app uniquement (sans iTerm2)

`Mvnuel.itermcolors` ne s’importe **pas** dans Terminal.app (réservé à iTerm2). À la place, **`./macos/install.sh`** enregistre automatiquement le fichier **`macos/mvnuel.terminal`** comme profil **Mvnuel** (couleurs ANSI, fond, texte, curseur, etc.) et le définit comme **défaut** et **profil au démarrage**, tant que **python3** est disponible (après `brew install python`, c’est le cas).

1. Après installation : fermez **Terminal.app** puis rouvrez-le, ou **nouvelle fenêtre** (**⌘N**), pour charger le profil.
2. **Police** : dans **Réglages → Profil Mvnuel → Texte**, choisissez **Roboto Mono for Powerline** (installée dans `~/Library/Fonts/`), taille **13–14**, si ce n’est pas déjà le cas dans l’export.

**Sans script** (import manuel) : double-clic sur **`mvnuel.terminal`** ou **Terminal → Réglages… → Profils → … → Importer…**, puis définissez **Mvnuel** comme profil par défaut.

**Réglage manuel des couleurs** (si l’import automatique échoue : pas de `python3`, fichier manquant) : dupliquez un profil, renommez-le **Mvnuel**, puis par exemple **Fond** `#1a1210`, **Texte** `#f0dfc0`, **Curseur** `#e0a040`. Les **couleurs ANSI** peuvent s’aligner sur **`configs/terminal_profile.dconf`** (palette) ou sur **`Mvnuel.itermcolors`** (mêmes teintes, autre format).

Le **prompt Zsh** (thème Mvnuel) et **`ls`** (`dircolors`) fonctionnent **dès** que `install.sh` a été exécuté ; le **cadre** du terminal (fond, texte, ANSI) suit le profil **Mvnuel** une fois Terminal.app rechargé.

**Limite** : Terminal.app gère parfois moins finement les couleurs ou les glyphes Powerline qu’iTerm2 ; si un séparateur du prompt semble coupé, vérifiez la police et la taille, ou testez iTerm2.

## `ls` et `dircolors`

`macos/configs/.zshrc` ajoute le **GNU coreutils** au `PATH` (`brew --prefix/opt/coreutils/...`) avant `dircolors`. `brew install coreutils` est exécuté par `install.sh`.

## Désinstallation partielle

```bash
chmod +x macos/uninstall.sh
./macos/uninstall.sh
```

`uninstall.sh` ne supprime pas **Oh My Zsh**. Pour retirer `~/.oh-my-zsh`, `~/.zshrc`, caches, etc. :

```bash
chmod +x macos/purge_zsh.sh
./macos/purge_zsh.sh
```

Options : `./macos/purge_zsh.sh --yes` (sans invite), `./macos/purge_zsh.sh --yes --with-history` (efface aussi `~/.zsh_history`). Équivalent Linux : `purge_zsh.sh` à la racine du dépôt.

## Limites

- Pas d’équivalent **`dconf`** : pas de profil GNOME. **iTerm2** : import `Mvnuel.itermcolors`. **Terminal.app** : profil **`mvnuel.terminal`** importé par **`install.sh`** (ou à la main), pas besoin de tout saisir sauf en secours.
- Les scripts **`install_*.sh`** à la racine du dépôt ciblent **Ubuntu** ; sous macOS, utilisez **`macos/install.sh`** uniquement.

**Amont / inspiration :** [pixegami/terminal-profile](https://github.com/pixegami/terminal-profile)
