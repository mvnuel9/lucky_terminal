<p align="center">
    <img src="./header.svg" alt="Lucky Terminal — thème Automnale multi-plateforme" width="100%" />
</p>

---

## Description

**Lucky Terminal**, c’est une **boîte à outils** pour que ton terminal ressemble au thème **Automnale** : couleurs harmonisées (ambiance terreuse, chaleureuse voire un peu vintage), invite de commande lisible (style Agnoster), même logique sur **Linux**, **macOS** et **Windows**. L’idée : cloner le dépôt, lancer **un** script selon ton OS, et retrouver un environnement cohérent sans y passer la journée.

Inspiré des approches du type [pixegami/terminal-profile](https://github.com/pixegami/terminal-profile), ce dépôt va plus loin avec des scripts et configs **par plateforme** (installation, désinstallation, purge).

---

## 🖼️ Aperçu


| **Linux** · Ubuntu + GNOME | **macOS** · Terminal.app / iTerm2 | **Windows** · PowerShell + Oh My Posh |
| -------------------------- | --------------------------------- | ------------------------------------- |
| Linux                      | macOS                             | Windows                               |


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

## 🛟 Dépannage rapide

Symptômes les plus courants et leur correction express. Si rien ne marche, lance le script avec `--verbose` (Bash) ou ajoute `-Verbose` (PowerShell) et copie l'erreur en issue.

### Linux & macOS (Bash)

| Symptôme                                                                                | Cause probable                                                                                            | Correction                                                                                                                        |
| --------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `Permission denied` au lancement                                                        | Le bit exécutable n'est pas posé.                                                                         | `chmod +x linux/install.sh` (idem `macos/`, sous-scripts `install_*`).                                                            |
| `Ce script est prévu pour macOS (Darwin)` (exit `20`)                                   | Tu as lancé un script `macos/` sur Linux (ou inversement).                                                | Utilise le dossier qui correspond à ton OS. Vérifie : `uname -s` doit être `Darwin` pour macOS.                                   |
| `Dépôt incomplet : <chemin>/.zshrc introuvable` (exit `21`)                             | Le dépôt a été cloné incomplètement, ou tu lances le script depuis le mauvais dossier.                    | Lance les scripts **depuis la racine** du dépôt cloné : `./linux/install.sh`, pas `cd linux && ./install.sh`.                     |
| `Oh My Zsh manquant. Lancez d'abord : ./<os>/install_terminal.sh` (exit `21`)           | Tu lances `install_profile.sh` en mode étape sans avoir fait `install_terminal.sh` avant.                 | Respecte l'ordre : `install_powerline.sh` → `install_terminal.sh` → `install_profile.sh`. Ou utilise `install.sh` (orchestrateur).|
| `Commande requise introuvable : 'brew'` (exit `2`)                                      | Homebrew n'est pas installé sur macOS.                                                                    | Installer Homebrew : `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`.            |
| `URL non HTTPS refusée : http://...` (exit `1`)                                         | Une variable d'environnement (`OHMYZSH_INSTALL_URL`, etc.) pointe sur du HTTP non sécurisé.               | Utilise une URL `https://`. Si vraiment nécessaire (réseau d'entreprise) : `LUCKY_ALLOW_HTTP=1 ./linux/install.sh` (déconseillé). |
| `Vérification d'intégrité échouée` (exit `1`)                                           | Le SHA256 calculé ne correspond pas à `OHMYZSH_INSTALL_SHA256`.                                           | Recalcule le SHA256 sur la version courante du fichier amont, ou désactive le pinning (vide la variable).                         |
| Le prompt s'affiche, mais les **séparateurs** Powerline sont des points d'interrogation | La police Powerline / Nerd Font n'est pas active dans ton émulateur de terminal.                          | GNOME Terminal → Préférences → profil → Police : `RobotoMono Nerd Font` ou `Roboto Mono for Powerline`. iTerm2 → Profils → Texte. |
| `fc-cache introuvable` (warning Linux)                                                  | Le paquet `fontconfig` n'est pas installé.                                                                | `sudo apt-get install fontconfig` (Debian/Ubuntu). Sur macOS, ignore : Cocoa gère le cache des polices.                           |
| Le profil GNOME Terminal « Mvnuel » n'apparaît pas                                      | `dconf` n'a pas pu écrire (session non-GNOME, gestionnaire alternatif).                                   | Importe le profil à la main : Préférences → ⋮ → Importer → `linux/configs/terminal_profile.dconf`.                                |
| Le profil **Terminal.app** ne s'importe pas (macOS)                                     | `python3` absent ou Terminal.app fermé.                                                                   | Double-clic sur `macos/mvnuel.terminal`, puis Préférences → Profils → bouton « Par défaut ».                                      |

### Windows (PowerShell)

| Symptôme                                                                                  | Cause probable                                                                          | Correction                                                                                                                                                |
| ----------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `... cannot be loaded because running scripts is disabled`                                | Politique d'exécution restrictive.                                                      | Utilise `-ExecutionPolicy Bypass` à l'invocation : `powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\install.ps1`.                           |
| `winget introuvable` (warning)                                                            | Windows < 10 1809 ou App Installer désinstallée.                                        | Installer **App Installer** depuis le Microsoft Store, ou télécharger Oh My Posh manuellement : <https://ohmyposh.dev/docs/installation/windows>.         |
| `oh-my-posh n'est pas encore dans le PATH` après install                                  | Le PATH n'a pas été rafraîchi dans la session courante.                                 | Ferme et rouvre **complètement** PowerShell / Windows Terminal. Si ça persiste, vérifie `Get-Command oh-my-posh`.                                         |
| `PSReadLine n'a peut-être pas été mis à jour (fichiers verrouillés)`                      | PSReadLine est chargé par la session courante, donc impossible à remplacer.             | Ferme **toutes** les fenêtres PowerShell / Windows Terminal, puis relance avec `-ForcePSReadLineUpdate`.                                                  |
| `Profil source introuvable: ...\Microsoft.PowerShell_profile.ps1` (exit `21`)             | Tu lances depuis l'extérieur du dépôt, ou le clone est partiel.                         | Vérifie que `windows\configs\Microsoft.PowerShell_profile.ps1` existe. Lance depuis la racine du dépôt cloné.                                             |
| Les **glyphes** du prompt apparaissent comme des carrés ☐ ou des `?`                      | Windows Terminal n'utilise pas de Nerd Font.                                            | `settings.json` → profil PowerShell → `"font": { "face": "RobotoMono Nerd Font" }`. Réinstaller la police via `install_fonts.ps1` si besoin.              |
| `Ce script est prevu pour Windows` (exit `20`)                                            | Tu as lancé un `.ps1` du dossier `windows/` sur PowerShell Core macOS/Linux.            | Les scripts `windows/` sont **Windows uniquement**. Sur macOS/Linux, utilise les scripts Bash de leur dossier respectif.                                  |

### Désinstallation / repartir de zéro

| Cas                                                       | Commande à exécuter                                                                                                       |
| --------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| Annuler l'install (Linux/macOS), garder Zsh + Oh My Zsh   | `./linux/uninstall.sh` (idem `macos/`).                                                                                   |
| Tout virer côté Linux/macOS (Oh My Zsh + plug-ins inclus) | `./linux/purge_zsh.sh --yes` (idem `macos/`).                                                                             |
| Annuler l'install Windows, garder les modules tiers       | `powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\uninstall.ps1`.                                            |
| Tout virer côté Windows (profil + thème + historique)     | `powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\purge_profile.ps1 -Yes -WithHistory`.                      |
| Restaurer un fichier écrasé                               | Les anciennes versions sont sauvegardées avec le suffixe `.bak.mvnuel-<YYYYMMDD-HHMMSS>` à côté du fichier original.      |

> **Astuce** : avant de relancer une install, prévisualise ce qu'elle va faire avec `--dry-run --yes` (scripts Bash supportés : `linux/uninstall.sh`, `linux/purge_zsh.sh`, et leurs équivalents macOS).

### Codes de sortie

Tous les scripts utilisent les mêmes codes pour faciliter le debug en CI / supervision :

| Code | Constante (Bash / PowerShell)                                       | Sens                                              |
| ---- | ------------------------------------------------------------------- | ------------------------------------------------- |
| `0`  | `LUCKY_EXIT_OK` / `$Script:Lucky_Exit_OK`                           | Succès.                                           |
| `1`  | `LUCKY_EXIT_GENERIC` / `$Script:Lucky_Exit_Generic`                 | Erreur générique non classée.                     |
| `2`  | `LUCKY_EXIT_MISSING_TOOL` / `$Script:Lucky_Exit_MissingTool`        | Une commande/dépendance attendue est absente.     |
| `3`  | `LUCKY_EXIT_USAGE` / `$Script:Lucky_Exit_Usage`                     | Mauvais usage CLI (option inconnue, etc.).        |
| `10` | `LUCKY_EXIT_CANCELLED` / `$Script:Lucky_Exit_Cancelled`             | Refus utilisateur (réponse `n` à un `--confirm`). |
| `20` | `LUCKY_EXIT_UNSUPPORTED_OS` / `$Script:Lucky_Exit_UnsupportedOS`    | Plateforme inattendue.                            |
| `21` | `LUCKY_EXIT_MISSING_FILE` / `$Script:Lucky_Exit_MissingFile`        | Fichier requis du dépôt absent.                   |

---

## 🏠 Empreinte sur ton `$HOME`

Liste exhaustive de ce que **chaque script** dépose, écrase ou modifie dans ton répertoire utilisateur. Tout fichier déjà présent est **sauvegardé** sous la forme `<chemin>.bak.mvnuel-<YYYYMMDD-HHMMSS>` (Bash) ou `<chemin>.bak.mvnuel.<yyyyMMdd-HHmmss>` (PowerShell) avant écrasement.

### Linux (`linux/install.sh`)

| Cible                                                                       | Action                  | Posée par               | Source / contenu                                              |
| --------------------------------------------------------------------------- | ----------------------- | ----------------------- | ------------------------------------------------------------- |
| `~/.vimrc`                                                                  | copie (écrase)          | `install_powerline.sh`  | `linux/configs/.vimrc` (charge `powerline-status`).           |
| `~/.fonts/`                                                                 | `mkdir -p`              | `install_powerline.sh`  | dossier de polices utilisateur.                               |
| `~/.fonts/RobotoMono/`                                                      | copie récursive         | `install_powerline.sh`  | `linux/fonts/RobotoMono` (Roboto Mono for Powerline TTF).     |
| `~/.oh-my-zsh/`                                                             | clone + install         | `install_terminal.sh`   | script officiel Oh My Zsh (URL surchargeable, voir Sécurité). |
| `~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/`                      | `git clone --depth=1`   | `install_profile.sh`    | <https://github.com/zsh-users/zsh-syntax-highlighting>        |
| `~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/`                          | `git clone --depth=1`   | `install_profile.sh`    | <https://github.com/zsh-users/zsh-autosuggestions>            |
| `~/.oh-my-zsh/themes/mvnuel-agnoster.zsh-theme`                             | copie                   | `install_profile.sh`    | `linux/configs/mvnuel-agnoster.zsh-theme`.                    |
| `~/.zshrc`                                                                  | copie (écrase)          | `install_profile.sh`    | `linux/configs/.zshrc`.                                       |
| `~/.dircolors`                                                              | copie (écrase)          | `install_profile.sh`    | `linux/configs/dircolors`.                                    |
| Profil GNOME Terminal `fb358fc9-…-1d25c649e633`                             | `dconf load` + `write`  | `install_profile.sh`    | `linux/configs/terminal_profile.dconf` (devient profil défaut).|
| Shell de connexion utilisateur                                              | `chsh -s $(which zsh)`  | `install_profile.sh`    | bascule de Bash → Zsh (effet à la prochaine session).         |

### macOS (`macos/install.sh`)

| Cible                                                                       | Action                  | Posée par               | Source / contenu                                              |
| --------------------------------------------------------------------------- | ----------------------- | ----------------------- | ------------------------------------------------------------- |
| `~/.vimrc`                                                                  | copie (écrase)          | `install_powerline.sh`  | `macos/configs/.vimrc`.                                       |
| `~/Library/Fonts/RobotoMono/`                                               | copie récursive         | `install_powerline.sh`  | `macos/fonts/RobotoMono`.                                     |
| `~/.aliases`, `~/.functions`                                                | `touch` (placeholders)  | `install_terminal.sh`   | fichiers vides destinés à tes ajouts perso.                   |
| `~/.oh-my-zsh/`                                                             | clone + install         | `install_terminal.sh`   | script officiel Oh My Zsh.                                    |
| `~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/`                      | `git clone --depth=1`   | `install_profile.sh`    | mêmes sources qu'en Linux.                                    |
| `~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/`                          | `git clone --depth=1`   | `install_profile.sh`    | idem.                                                         |
| `~/.oh-my-zsh/themes/mvnuel-agnoster.zsh-theme`                             | copie                   | `install_profile.sh`    | `macos/configs/mvnuel-agnoster.zsh-theme`.                    |
| `~/.zshrc`                                                                  | copie (écrase)          | `install_profile.sh`    | `macos/configs/.zshrc`.                                       |
| `~/.dircolors`, `~/.dircolors.terminal`                                     | copie                   | `install_profile.sh`    | `macos/configs/dircolors{,.terminal}`.                        |
| `~/Library/Preferences/com.apple.Terminal.plist`                            | merge via `plistlib`    | `install_profile.sh`    | profil « Mvnuel » défini comme défaut + au démarrage.         |

> macOS ne déclenche **pas** de `chsh` : Zsh est déjà le shell de login par défaut depuis Catalina.

### Windows (`windows\install.ps1`)

| Cible                                                                                            | Action                | Posée par              | Source / contenu                                          |
| ------------------------------------------------------------------------------------------------ | --------------------- | ---------------------- | --------------------------------------------------------- |
| `$env:LOCALAPPDATA\Microsoft\Windows\Fonts\RobotoMono*.ttf` (et `.otf`)                          | copie + registre user | `install_fonts.ps1`    | `windows\fonts\RobotoMono` (ou `-NerdFontDirectory`).     |
| `$HOME\.config\mvnuel\mvnuel.omp.json`                                                           | copie (écrase)        | `install_profile.ps1`  | `windows\configs\mvnuel.omp.json` (thème Oh My Posh).     |
| `$PROFILE.CurrentUserCurrentHost` (`Microsoft.PowerShell_profile.ps1`, dans `Documents\PowerShell\` ou `Documents\WindowsPowerShell\` selon l'hôte) | copie (écrase, **avec backup**) | `install_profile.ps1`  | `windows\configs\Microsoft.PowerShell_profile.ps1`.       |
| `<dossier $PROFILE>\aliases.ps1`, `functions.ps1`                                                | `New-Item` si absent  | `install_profile.ps1`  | placeholders vides pour tes ajouts perso.                 |
| `$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`    | copie (avec backup, après `Confirm-Step`) | `install_profile.ps1`  | `windows\configs\windows-terminal-settings.json`.         |
| `…\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json`                      | idem (si présent)     | `install_profile.ps1`  | idem.                                                     |

> `purge_profile.ps1 -WithHistory` est le **seul** script qui touche `$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt`. L'install standard ne le lit ni ne le modifie.

### Ce qui sort de `$HOME` (modifications système)

Ces actions affectent la machine **au-delà** du répertoire utilisateur. Elles nécessitent généralement les droits administrateur.

| OS      | Modification                                                              | Déclenchée par            | Effet                                                  |
| ------- | ------------------------------------------------------------------------- | ------------------------- | ------------------------------------------------------ |
| Linux   | `sudo apt install -y git-core zsh curl`                                   | `install_terminal.sh`     | Paquets système requis (Zsh, git, curl).               |
| Linux   | `sudo apt install -y python3-pip vim fontconfig`                          | `install_powerline.sh`    | Outils pour Vim + cache des polices.                   |
| Linux   | `pipx install powerline-status[==<version>]`                              | `install_powerline.sh`    | Module Python utilisateur (pas système).               |
| macOS   | `brew install zsh git pipx`                                               | `install_powerline.sh`    | Dépendances Homebrew (formules).                       |
| macOS   | `pipx install powerline-status[==<version>]`                              | `install_powerline.sh`    | Module Python utilisateur.                             |
| Windows | `winget install JanDeDobbeleer.OhMyPosh [--version <X>]`                  | `install_terminal.ps1`    | Installation Oh My Posh à l'échelle utilisateur.       |
| Windows | `Install-Module Terminal-Icons z PSReadLine -Scope CurrentUser`           | `install_terminal.ps1`    | Modules PowerShell utilisateur.                        |
| Windows | `Uninstall-Module oh-my-posh` (l'ancien module déprécié)                  | `install_terminal.ps1`    | Nettoyage de l'ancien module avant la version binaire. |

### Restauration d'un fichier remplacé

Toutes les sauvegardes sont posées **à côté** du fichier original, ce qui rend la restauration triviale :

```bash
ls -lh ~/.zshrc.bak.mvnuel-*
mv ~/.zshrc.bak.mvnuel-20260101-103045 ~/.zshrc
```

```powershell
Get-ChildItem $PROFILE.CurrentUserCurrentHost.Replace('.ps1','*')
Move-Item "$($PROFILE.CurrentUserCurrentHost).bak.mvnuel.20260101-103045" $PROFILE.CurrentUserCurrentHost -Force
```

---

## 🔒 Sécurité des sources & épinglage

Par défaut, les scripts installent les dernières versions des dépendances distantes (Oh My Zsh, plug-ins zsh, `powerline-status`, Oh My Posh). En CI ou en environnement sensible, on peut figer ces versions et vérifier l’intégrité des scripts téléchargés **sans modifier le code** : toutes les sources passent par HTTPS obligatoire, et chaque script distant est téléchargé dans un fichier temporaire (plus de `curl | sh` aveugle).

Variables d’environnement reconnues (toutes optionnelles, valeurs vides = comportement par défaut) :

| Variable                        | Scripts concernés                                                      | Effet                                                                                 |
| ------------------------------- | ---------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| `OHMYZSH_INSTALL_URL`           | `linux/install_terminal.sh`, `macos/install_terminal.sh`               | Surcharge l’URL du script installer Oh My Zsh (défaut : `ohmyzsh/ohmyzsh/master`).    |
| `OHMYZSH_INSTALL_SHA256`        | idem                                                                   | Si défini, le script vérifie le SHA256 du fichier téléchargé avant exécution.         |
| `ZSH_SYNTAX_HIGHLIGHTING_REF`   | `linux/install_profile.sh`, `macos/install_profile.sh`                 | Ref git (branche/tag) de `zsh-syntax-highlighting` (défaut : `master`).               |
| `ZSH_AUTOSUGGESTIONS_REF`       | idem                                                                   | Ref git (branche/tag) de `zsh-autosuggestions` (défaut : `master`).                   |
| `POWERLINE_STATUS_VERSION`      | `linux/install_powerline.sh`, `macos/install_powerline.sh`             | Si défini, `pipx install powerline-status==$VERSION`.                                 |
| `LUCKY_ALLOW_HTTP`              | tout script Bash utilisant les helpers                                 | `=1` pour autoriser les URLs `http://` (fortement déconseillé).                       |

Côté Windows, l’installer PowerShell accepte `-OhMyPoshVersion` (ou `$env:OHMYPOSH_VERSION`) pour transmettre `--version` à `winget install JanDeDobbeleer.OhMyPosh`.

Exemple d’install reproductible (Linux) :

```bash
OHMYZSH_INSTALL_SHA256="<sha256 du install.sh vérifié à la main>" \
ZSH_SYNTAX_HIGHLIGHTING_REF="0.8.0" \
ZSH_AUTOSUGGESTIONS_REF="v0.7.1" \
POWERLINE_STATUS_VERSION="2.8.4" \
./linux/install.sh --yes
```

Les helpers sous-jacents (`lucky_download`, `lucky_verify_sha256`, etc.) vivent dans `scripts/_common.sh` et sont disponibles pour tout nouveau script Bash du dépôt.

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

Ce projet est distribué sous licence **[MIT](LICENSE)**. Les polices embarquées conservent leurs licences d'origine.