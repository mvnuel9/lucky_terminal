# Lucky Terminal - Windows (PowerShell)

Vous etes sur Windows ? Utilisez uniquement les scripts de ce dossier.

Ce dossier est autonome, comme `macos/`, et contient:

- `install.ps1`: installation du profil Mvnuel pour PowerShell
- `uninstall.ps1`: desinstallation partielle avec sauvegardes
- `purge_profile.ps1`: nettoyage residuel
- `configs/`: profil PowerShell, theme Oh My Posh, exemple Windows Terminal

## Prerequis

- Windows PowerShell 5.1 (supporte) ou PowerShell 7+ (recommande)
- Politique d'execution qui autorise les scripts du user (`RemoteSigned`)
- Connexion Internet (modules PowerShell + **winget** pour Oh My Posh)
- **RobotoMono Nerd Font** (recommande) : telechargee depuis [nerdfonts.com](https://www.nerdfonts.com/font-downloads), puis soit installee a la main, soit en passant le dossier des `.ttf` a l'installateur avec **`-NerdFontDirectory`** (voir ci-dessous)

Notes :

- Oh My Posh ne s’installe **plus** via `Install-Module oh-my-posh` (module deprecie). Le script utilise **`winget install JanDeDobbeleer.OhMyPosh`** puis le profil appelle `oh-my-posh init powershell|pwsh` (voir [migration](https://ohmyposh.dev/docs/migrating)).
- Sur PowerShell 5.1, `install.ps1` force TLS 1.2, installe `NuGet` si besoin, puis installe les modules depuis PSGallery.

## Installation

Depuis la racine du depot:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\install.ps1
```

Mode non interactif :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\install.ps1 -Yes
```

`-NoProfile` evite de charger un ancien `$PROFILE` (ex. encore en `Set-PoshPrompt`) pendant l’installation.

Si PSReadLine est deja en version suffisante (>= 2.1.0), le script **ne relance pas** `Install-Module PSReadLine` par defaut (evite verrouillage DLL). Pour forcer une mise a jour :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\install.ps1 -Yes -ForcePSReadLineUpdate
```

Apres avoir extrait les fichiers **RobotoMono** (fichiers `.ttf`), enregistre-les dans Windows et applique le modele en une fois :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\install.ps1 -Yes -NerdFontDirectory "$env:USERPROFILE\Downloads\RobotoMono"
```

(adapte le chemin si ton dossier n'est pas sous `Downloads\RobotoMono`.)

Le script:

1. retire l’ancien module `oh-my-posh` (s’il est encore la) et installe le **binaire** Oh My Posh via **winget**
2. installe les modules `Terminal-Icons`, `z`, et `PSReadLine` si absent ou < 2.1.0 (sinon conserve ; `-ForcePSReadLineUpdate` pour forcer une mise a jour)
3. copie le theme vers `$HOME\.config\mvnuel\mvnuel.omp.json`
4. sauvegarde puis remplace `$PROFILE`
5. initialise `aliases.ps1` et `functions.ps1`
6. propose d'ecraser `settings.json` de Windows Terminal avec un profil Mvnuel de demonstration (police par defaut : **RobotoMono Nerd Font**)

## Windows Terminal

Le fichier `windows/configs/windows-terminal-settings.json` est un modele complet.
La police par defaut est **RobotoMono Nerd Font** (glyphes pour Oh My Posh / Terminal-Icons). Si Windows Terminal affiche une alerte « font not found », enregistre les polices (clic droit sur les `.ttf` > Installer pour tous les utilisateurs, ou utilise **`-NerdFontDirectory`** avec `install.ps1` comme ci-dessus).

Si tu as deja une config riche, prefere fusionner manuellement la section `schemes` et le profil PowerShell plutot que d'ecraser tout le fichier.

## Desinstallation

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\uninstall.ps1
```

Sans invites :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\uninstall.ps1 -Yes
```

## Purge residuelle

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\purge_profile.ps1
```

Avec historique PSReadLine :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\purge_profile.ps1 -Yes -WithHistory
```
