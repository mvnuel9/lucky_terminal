# Profil terminal Mvnuel — macOS

**Vous êtes sur macOS ?** C’est le **seul** dossier d’installation à utiliser (`install.sh`, `macos/configs/`). Les scripts `install_powerline.sh` / `install_terminal.sh` / `install_profile.sh` à la racine du dépôt sont réservés à **Linux (Ubuntu + GNOME Terminal)**.

Ce dossier est **autonome** : les configurations shell/Vim/thème pour macOS vivent dans **`macos/configs/`**, séparées du dossier **`configs/`** (Linux / Ubuntu + GNOME Terminal).

## Arborescence

```
macos/
├── README.md                 # Ce fichier
├── install.sh
├── uninstall.sh
├── Mvnuel.itermcolors        # Jeu de couleurs iTerm2
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

Le script installe les dépendances Homebrew (**python**, **pipx**, **git**, **coreutils**), **powerline-status**, copie les polices, installe **Oh My Zsh** si besoin, clone les plugins, puis copie **`macos/configs/`** vers `~` et `~/.oh-my-zsh/themes/`.

Ensuite : **nouveau terminal** ou `exec zsh`.

## Couleurs du terminal

L’installation **shell** (`install.sh`) est la même que vous utilisiez **Terminal.app** (intégré à macOS) ou **iTerm2**. Seule la **mise en couleur de la fenêtre** change.

### Avec iTerm2 (import rapide)

1. **iTerm2 → Settings → Profiles → Colors → Color Presets… → Import…**
2. Fichier **`macos/Mvnuel.itermcolors`**, puis choisir le préréglage **Mvnuel**.
3. **Text** : police **Roboto Mono for Powerline**, taille **13–14**.

### Avec Terminal.app uniquement (sans iTerm2)

`Mvnuel.itermcolors` ne s’importe **pas** dans l’app Terminal : il faut **créer ou dupliquer un profil** et saisir les couleurs à la main (ou vous rapprocher des valeurs ci-dessous).

1. Ouvrez **Terminal** → **Réglages…** (ou **Paramètres…** selon la version) → onglet **Profils**.
2. Dupliquez un profil (ex. « Pro ») et renommez-le (ex. **Mvnuel**).
3. **Police** : **Roboto Mono for Powerline** (installée par `install.sh` dans `~/Library/Fonts/`), taille **13–14**.
4. **Couleurs** : selon votre version de macOS, réglez au minimum :
   - **Fond** : `#1a1210` (RVB 26, 18, 16)
   - **Texte** : `#f0dfc0` (RVB 240, 223, 192)
   - **Curseur** (si proposé) : `#e0a040` (RVB 224, 160, 64)
5. Si l’onglet propose des **couleurs ANSI** (16 couleurs), vous pouvez les aligner sur la palette du fichier **`configs/terminal_profile.dconf`** à la racine du dépôt (section `palette=[...]`), ou sur les teintes du fichier **`Mvnuel.itermcolors`** (mêmes couleurs, format différent).

Le **prompt Zsh** (thème Mvnuel) et **`ls`** (`dircolors`) fonctionnent **dès** que `install.sh` a été exécuté ; seul le **cadre** du terminal (fond, texte, ANSI) dépend de ces réglages manuels dans Terminal.app.

**Limite** : Terminal.app gère parfois moins finement les couleurs ou les glyphes Powerline qu’iTerm2 ; si un séparateur du prompt semble coupé, vérifiez la police et la taille, ou testez iTerm2.

## `ls` et `dircolors`

`macos/configs/.zshrc` ajoute le **GNU coreutils** au `PATH` (`brew --prefix/opt/coreutils/...`) avant `dircolors`. `brew install coreutils` est exécuté par `install.sh`.

## Désinstallation partielle

```bash
chmod +x macos/uninstall.sh
./macos/uninstall.sh
```

## Limites

- Pas d’équivalent **`dconf`** : pas de profil GNOME. **iTerm2** permet d’importer `Mvnuel.itermcolors` en un clic ; **Terminal.app** impose un réglage manuel des couleurs (voir ci-dessus).
- Les scripts **`install_*.sh`** à la racine du dépôt ciblent **Ubuntu** ; sous macOS, utilisez **`macos/install.sh`** uniquement.

**Amont / inspiration :** [pixegami/terminal-profile](https://github.com/pixegami/terminal-profile)
