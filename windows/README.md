# Lucky Terminal — Windows

![Aperçu du terminal PowerShell](./powershell.png)

Pour **Windows**, tout se passe ici : **PowerShell**, thème **Oh My Posh** façon Automnale, modules utiles (`Terminal-Icons`, navigation rapide, ligne de commande confortable) et un exemple de profil **Windows Terminal**. Pas besoin de lancer les scripts **Linux** ou **macOS** ce dossier est autonome.

---

## 🗂️ Arborescence du dossier

```
windows/
├── configs/
│   ├── Microsoft.PowerShell_profile.ps1
│   ├── mvnuel.omp.json
│   └── windows-terminal-settings.json
├── fonts/
│   ├── README.md
│   └── RobotoMono/          # RobotoMono Nerd Font (glyphes pour le thème)
├── _common.ps1              # Helpers partagés (dot-sourcé)
├── install.ps1              # Orchestre les trois étapes ci-dessous
├── install_fonts.ps1        # Enregistre les polices Nerd Font
├── install_terminal.ps1     # Oh My Posh + modules PowerShell
├── install_profile.ps1      # $PROFILE, thème Oh My Posh, Windows Terminal
├── purge_profile.ps1
├── uninstall.ps1
└── README.md
```

Le dossier **`fonts/`** regroupe les polices **Nerd Font** compatibles avec Oh My Posh et les icônes du terminal ; l’installateur peut aussi pointer vers un dossier de **`.ttf`** que tu as déjà téléchargé ailleurs.

---

## 💡 En clair : à quoi sert chaque script

### Mode one-click (installation en un clic)
- **`install.ps1`** : le **parcours tout-en-un** — enchaîne les trois étapes modulaires ci-dessous et forwarde les paramètres (`-Yes`, `-ForcePSReadLineUpdate`, `-NerdFontDirectory`).

### Mode étapes (pour debugger / installer à la carte)
- **`install_fonts.ps1`** : enregistre **RobotoMono Nerd Font** depuis `fonts/RobotoMono/` (ou `-NerdFontDirectory`) dans les polices utilisateur Windows. Détecte les polices déjà installées pour ne pas doublonner.
- **`install_terminal.ps1`** : retire l'ancien module `oh-my-posh` déprécié, installe le **binaire Oh My Posh** via `winget`, puis installe les modules PowerShell (`Terminal-Icons`, `z`, `PSReadLine`).
- **`install_profile.ps1`** : copie le thème Oh My Posh vers `$HOME\.config\mvnuel\`, sauvegarde et remplace `$PROFILE`, crée `aliases.ps1`/`functions.ps1`, propose d'écraser le `settings.json` de Windows Terminal.

### Désinstallation
- **`uninstall.ps1`** : retire ce que le projet a ajouté, en **gardant des sauvegardes** là où c'est prévu pour que tu puisses récupérer l'ancien profil si besoin.
- **`purge_profile.ps1`** : nettoyage plus poussé quand il reste des réglages ou fichiers liés au profil (option pour l'historique si tu veux repartir vraiment à plat).

Les fichiers dans **`configs/`** sont les **modèles** copiés ou fusionnés vers ton utilisateur (`$PROFILE`, `.config`, etc.) selon ce que fait le script.
Le fichier **`_common.ps1`** contient des helpers partagés (`Confirm-Step`, `Ensure-Dir`, `Test-IsWindowsHost`, etc.) et n'est pas destiné à être lancé directement.

---

## 📌 Prérequis

- **PowerShell** 5.1 ou de préférence **7+**
- Politique d’exécution qui permet de lancer les scripts utilisateur (souvent `RemoteSigned` en local)
- **Internet** pour winget / modules / téléchargements
- **Police Nerd Font** : le dépôt fournit **RobotoMono** sous `fonts/RobotoMono/` ; tu peux aussi passer un dossier contenant les `.ttf` à l’installation (voir ci-dessous)

---

## ⌨️ Commandes

**Installation one-click** (depuis la racine du dépôt, dans PowerShell ou en invoquant `powershell` / `pwsh`) :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\install.ps1
```

**Sans questions** :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\install.ps1 -Yes
```

**Installation étape par étape** (même ordre que le script maître) :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\install_fonts.ps1 -Yes
powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\install_terminal.ps1 -Yes
powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\install_profile.ps1 -Yes
```

`-NoProfile` évite de charger un ancien profil pendant l’installation (anciennes invites du type `Set-PoshPrompt`, etc.).

**Forcer une mise à jour de PSReadLine** (si tu as un souci de version verrouillée) :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\install.ps1 -Yes -ForcePSReadLineUpdate
```

**Indiquer un dossier de polices déjà extraits** (fichiers `.ttf`) :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\install.ps1 -Yes -NerdFontDirectory "$env:USERPROFILE\Downloads\RobotoMono"
```

(adapte le chemin à ton dossier.)

**Désinstallation** :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\uninstall.ps1
```

**Sans invites** :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\uninstall.ps1 -Yes
```

**Purge résiduelle du profil** :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\purge_profile.ps1
```

Avec historique PSReadLine :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\purge_profile.ps1 -Yes -WithHistory
```

---

## 🖥️ Windows Terminal

Le fichier **`configs/windows-terminal-settings.json`** est un **exemple complet**. Si tu as déjà une config riche, il vaut mieux **fusionner** les couleurs et le profil PowerShell plutôt que d’écraser tout le fichier d’un coup.

Si Windows Terminal affiche une alerte « font not found », installe les polices depuis `fonts/RobotoMono/` (clic droit sur les `.ttf` → installer) ou repasse par **`-NerdFontDirectory`** à l’installation.

---

## 🌍 Autres plateformes & doc générale

- **Linux** : `[linux/](../linux/)`
- **macOS** : `[macos/](../macos/)`
- **Vue d’ensemble** : [README à la racine](../README.md)

Références : [Oh My Posh](https://ohmyposh.dev/) · [Nerd Fonts](https://www.nerdfonts.com/) · [Télécharger RobotoMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/RobotoMono.zip)

Bon terminal ! 🍀