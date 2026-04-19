[CmdletBinding()]
param(
    [switch]$Yes,
    # Tente Install-Module PSReadLine meme si une version recente est deja la (risque d'avertissement "module en cours d'utilisation").
    [switch]$ForcePSReadLineUpdate,
    # Enregistre les .ttf/.otf (ex. dossier extrait depuis Nerd Fonts) dans les polices utilisateur Windows avant d'appliquer le modele WT.
    [string]$NerdFontDirectory = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Confirm-Step {
    param(
        [Parameter(Mandatory = $true)][string]$Message
    )

    if ($Yes) {
        Write-Host "OK (--Yes): $Message"
        return $true
    }

    $answer = Read-Host "$Message [y/N]"
    return $answer -match "^(y|yes|o|oui)$"
}

function Ensure-Dir {
    param(
        [Parameter(Mandatory = $true)][string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Test-IsWindowsHost {
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        return $IsWindows
    }

    return $env:OS -eq "Windows_NT"
}

function Initialize-ModuleInstall {
    # Needed for many PS 5.1 environments that default to TLS 1.0/1.1.
    [Net.ServicePointManager]::SecurityProtocol = `
        [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
    }

    $repo = Get-PSRepository -Name "PSGallery" -ErrorAction SilentlyContinue
    if ($repo -and $repo.InstallationPolicy -ne "Trusted") {
        Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
    }
}

function Refresh-UserPath {
    $machine = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $user = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machine;$user"
}

function Remove-LegacyOhMyPoshModule {
    # Module PowerShell deprecie : https://ohmyposh.dev/docs/migrating
    if (Get-Module -ListAvailable -Name oh-my-posh -ErrorAction SilentlyContinue) {
        Write-Host "    Desinstallation de l'ancien module PowerShell oh-my-posh..."
        Uninstall-Module -Name oh-my-posh -AllVersions -Force -ErrorAction SilentlyContinue
    }
    if ($env:POSH_PATH -and (Test-Path -LiteralPath $env:POSH_PATH)) {
        Write-Host "    Suppression du cache POSH_PATH (ancien module)..."
        Remove-Item -LiteralPath $env:POSH_PATH -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Get-PSReadLineBestInstalledVersion {
    $m = Get-Module -ListAvailable -Name PSReadLine -ErrorAction SilentlyContinue |
        Sort-Object Version -Descending |
        Select-Object -First 1
    if ($m) {
        return $m.Version
    }
    return $null
}

function Test-RobotoMonoNerdFontInstalled {
    <#
    .SYNOPSIS
        Indique si une variante RobotoMono Nerd Font est deja enregistree (registre + fichiers .ttf/.otf).
    #>
    $faceNeedles = @('RobotoMono', 'Nerd')
    $fontRegPaths = @(
        'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts',
        'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
    )
    foreach ($regPath in $fontRegPaths) {
        if (-not (Test-Path -LiteralPath $regPath)) {
            continue
        }
        try {
            $props = Get-ItemProperty -LiteralPath $regPath -ErrorAction Stop
        } catch {
            continue
        }
        foreach ($p in $props.PSObject.Properties) {
            $name = $p.Name
            if ($name -match '^(PS)') {
                continue
            }
            $ok = $true
            foreach ($needle in $faceNeedles) {
                if ($name -notlike "*$needle*") {
                    $ok = $false
                    break
                }
            }
            if ($ok) {
                return $true
            }
        }
    }

    $fontDirs = @(
        (Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Microsoft\Windows\Fonts'),
        (Join-Path -Path $env:Windir -ChildPath 'Fonts')
    )
    foreach ($dir in $fontDirs) {
        if (-not (Test-Path -LiteralPath $dir)) {
            continue
        }
        $hit = Get-ChildItem -LiteralPath $dir -File -ErrorAction SilentlyContinue |
            Where-Object {
                $_.Extension -match '^\.(ttf|otf)$' -and
                    $_.Name -match '(?i)RobotoMono' -and $_.Name -match '(?i)Nerd'
            } |
            Select-Object -First 1
        if ($hit) {
            return $true
        }
    }

    return $false
}

function Install-UserFontsFromDirectory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Directory
    )

    if (Test-RobotoMonoNerdFontInstalled) {
        Write-Host "    Police RobotoMono Nerd Font deja installee : aucun enregistrement depuis le dossier."
        return
    }

    if (-not (Test-Path -LiteralPath $Directory)) {
        Write-Warning "Dossier polices introuvable: $Directory"
        return
    }

    $fontFiles = @(
        Get-ChildItem -LiteralPath $Directory -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Extension -match '^\.(ttf|otf)$' }
    )
    if ($fontFiles.Count -eq 0) {
        Write-Warning "Aucun fichier .ttf ou .otf dans: $Directory"
        return
    }

    Write-Host "    $($fontFiles.Count) fichier(s) police a enregistrer..."
    $shell = New-Object -ComObject Shell.Application
    $fontsNs = $shell.Namespace(0x14)
    foreach ($font in $fontFiles) {
        try {
            # 0x10 = pas de boite de dialogue de remplacement (equivalent "Oui a tout" selon versions Windows)
            $fontsNs.CopyHere($font.FullName, 0x10)
            Write-Host "       + $($font.Name)"
        } catch {
            Write-Warning "Echec copie police '$($font.Name)': $($_.Exception.Message)"
        }
    }
}

function Install-OhMyPoshExecutable {
    Refresh-UserPath
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        Write-Host "    oh-my-posh (CLI) deja disponible dans le PATH."
        return
    }

    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $winget) {
        Write-Warning "winget introuvable. Installez Oh My Posh manuellement : https://ohmyposh.dev/docs/installation/windows"
        return
    }

    Write-Host "    Installation du binaire Oh My Posh via winget..."
    & winget.exe install JanDeDobbeleer.OhMyPosh --source winget --accept-package-agreements --accept-source-agreements
    Refresh-UserPath

    if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
        Write-Warning "oh-my-posh n'est pas encore dans le PATH. Fermez et rouvrez le terminal, ou verifiez l'installation winget."
    }
}

if (-not (Test-IsWindowsHost)) {
    throw "Ce script est prevu pour Windows."
}

# PS 5.1 : $MyInvocation.MyCommand.Path peut etre vide ou ambigu ; $PSScriptRoot est fiable avec -File.
$scriptDir = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($scriptDir)) {
    $scriptPath = $PSCommandPath
    if ([string]::IsNullOrWhiteSpace($scriptPath)) {
        $scriptPath = $MyInvocation.MyCommand.Path
    }
    if ([string]::IsNullOrWhiteSpace($scriptPath)) {
        throw "Impossible de determiner le repertoire du script (PSScriptRoot vide)."
    }
    $scriptDir = Split-Path -Parent -LiteralPath $scriptPath
}
# Garantit une seule chaine (evite Object[] -> erreur Join-Path -ChildPath sur PS 5.1).
$scriptDir = [string](@($scriptDir)[0])

$configsDir = Join-Path -Path $scriptDir -ChildPath "configs"

# Profil courant / hote courant (chemin explicite ; $PROFILE seul peut etre ambigu selon l'hote).
$profileTarget = $null
if ($PROFILE | Get-Member -Name CurrentUserCurrentHost -ErrorAction SilentlyContinue) {
    $profileTarget = $PROFILE.CurrentUserCurrentHost
}
if ([string]::IsNullOrWhiteSpace($profileTarget)) {
    $profileTarget = [string]$PROFILE
} else {
    $profileTarget = [string]$profileTarget
}
$profileTargetDir = Split-Path -Parent -Path $profileTarget
$profileSource = Join-Path -Path $configsDir -ChildPath "Microsoft.PowerShell_profile.ps1"

$themeTargetDir = Join-Path -Path $HOME -ChildPath ".config\mvnuel"
$themeTarget = Join-Path -Path $themeTargetDir -ChildPath "mvnuel.omp.json"
$themeSource = Join-Path -Path $configsDir -ChildPath "mvnuel.omp.json"

$terminalSource = Join-Path -Path $configsDir -ChildPath "windows-terminal-settings.json"
$terminalTargets = @(
    (Join-Path -Path $env:LOCALAPPDATA -ChildPath "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"),
    (Join-Path -Path $env:LOCALAPPDATA -ChildPath "Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json")
)

if (-not (Test-Path -LiteralPath $profileSource)) {
    throw "Profil source introuvable: $profileSource"
}

if (-not [string]::IsNullOrWhiteSpace($NerdFontDirectory)) {
    if (Test-RobotoMonoNerdFontInstalled) {
        Write-Host "==> Police RobotoMono Nerd Font deja installee : -NerdFontDirectory ignore."
    } else {
        Write-Host "==> Enregistrement des polices utilisateur (depuis -NerdFontDirectory)..."
        Install-UserFontsFromDirectory -Directory $NerdFontDirectory.Trim()
    }
}

Write-Host "==> Oh My Posh (executable ; le module PowerShell est deprecie)..."
Remove-LegacyOhMyPoshModule
Install-OhMyPoshExecutable

Write-Host "==> Installation des modules PowerShell (CurrentUser)..."
Initialize-ModuleInstall
# PSReadLine: sous Windows PowerShell 5.1, le module est souvent deja charge dans CE processus ;
# Install-Module -Force declenche alors "version ... actuellement utilisee" sans necessite reelle si la version est deja OK.
$minPSReadLine = [version]"2.1.0"
$psReadLineInstalled = Get-PSReadLineBestInstalledVersion

$requiredModules = @(
    "Terminal-Icons",
    "z"
)
$psReadLinePossiblyLocked = $false
foreach ($moduleName in $requiredModules) {
    Write-Host "    - $moduleName"
    try {
        $warnBuf = @()
        Install-Module -Name $moduleName -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop `
            -WarningVariable +warnBuf -WarningAction SilentlyContinue
        foreach ($w in $warnBuf) {
            $msg = if ($w -is [System.Management.Automation.WarningRecord]) { $w.Message } else { "$w" }
            Write-Warning $msg
        }
    } catch {
        Write-Warning "Echec installation module '$moduleName': $($_.Exception.Message)"
    }
}

Write-Host "    - PSReadLine"
$shouldInstallPSReadLine = $false
if ($ForcePSReadLineUpdate) {
    $shouldInstallPSReadLine = $true
    Write-Host "       Mise a jour demandee (-ForcePSReadLineUpdate)..."
} elseif (-not $psReadLineInstalled) {
    $shouldInstallPSReadLine = $true
    Write-Host "       Aucune version detectee via Get-Module -ListAvailable, tentative d'installation..."
} elseif ($psReadLineInstalled -lt $minPSReadLine) {
    $shouldInstallPSReadLine = $true
    Write-Host "       Version $psReadLineInstalled < $minPSReadLine, tentative de mise a jour..."
} else {
    Write-Host "       OK version $psReadLineInstalled (>= $minPSReadLine) : reinstallation omise pour eviter le verrouillage DLL du processus courant."
    Write-Host "       Pour forcer quand meme: -ForcePSReadLineUpdate"
}

if ($shouldInstallPSReadLine) {
    try {
        $warnBuf = @()
        Install-Module -Name "PSReadLine" -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop `
            -WarningVariable +warnBuf -WarningAction SilentlyContinue
        foreach ($w in $warnBuf) {
            $msg = if ($w -is [System.Management.Automation.WarningRecord]) { $w.Message } else { "$w" }
            Write-Warning $msg
            if ($msg -match "(?i)(utilis|in use|fermez|close|retent|retry|locked)") {
                $psReadLinePossiblyLocked = $true
            }
        }
    } catch {
        Write-Warning "Echec installation module 'PSReadLine': $($_.Exception.Message)"
        $psReadLinePossiblyLocked = $true
    }
}

Write-Host "==> Copie du theme Oh My Posh..."
Ensure-Dir -Path $themeTargetDir
Copy-Item -LiteralPath $themeSource -Destination $themeTarget -Force

Write-Host "==> Sauvegarde et installation du profil PowerShell..."
Ensure-Dir -Path $profileTargetDir
if (Test-Path -LiteralPath $profileTarget) {
    $backup = "$profileTarget.bak.mvnuel.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item -LiteralPath $profileTarget -Destination $backup -Force
    Write-Host "    Profil sauvegarde vers: $backup"
}
Copy-Item -LiteralPath $profileSource -Destination $profileTarget -Force

Write-Host "==> Fichiers utilitaires (aliases/functions)..."
$aliasesPath = Join-Path -Path $profileTargetDir -ChildPath "aliases.ps1"
$functionsPath = Join-Path -Path $profileTargetDir -ChildPath "functions.ps1"
if (-not (Test-Path -LiteralPath $aliasesPath)) { New-Item -ItemType File -Path $aliasesPath | Out-Null }
if (-not (Test-Path -LiteralPath $functionsPath)) { New-Item -ItemType File -Path $functionsPath | Out-Null }

if (Confirm-Step -Message "Importer un profil Windows Terminal Mvnuel d'exemple ?") {
    $terminalInstalled = $false
    foreach ($target in $terminalTargets) {
        $targetDir = Split-Path -Parent $target
        if (-not (Test-Path -LiteralPath $targetDir)) {
            continue
        }

        if (Test-Path -LiteralPath $target) {
            $backup = "$target.bak.mvnuel.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Copy-Item -LiteralPath $target -Destination $backup -Force
            Write-Host "    Sauvegarde settings.json: $backup"
        }

        Copy-Item -LiteralPath $terminalSource -Destination $target -Force
        Write-Host "    Profil applique dans: $target"
        $terminalInstalled = $true
    }

    if (-not $terminalInstalled) {
        Write-Host "    Windows Terminal introuvable. Le fichier modele reste disponible dans windows/configs/."
    }
} else {
    Write-Host "    Import Windows Terminal ignore."
}

Write-Host ""
Write-Host "Installation terminee."
Write-Host "Actions recommandees:"
Write-Host "  1) Modele Windows Terminal : police RobotoMono Nerd Font. Si alerte police : enregistrer les .ttf (zip Nerd Fonts) ou relancer l'install avec -NerdFontDirectory `"chemin_vers_dossier`"."
Write-Host "  2) Ouvrir une nouvelle session PowerShell."
Write-Host "  3) Verifier le prompt Mvnuel et les icones."
if ($psReadLinePossiblyLocked) {
    Write-Host ""
    Write-Warning "PSReadLine n'a peut-etre pas ete mis a jour (fichiers verrouilles par un processus qui charge le module)."
    Write-Host "  Fermez toutes les fenetres PowerShell, Windows Terminal, Cursor/VS Code, puis relancez avec -ForcePSReadLineUpdate si besoin:" -ForegroundColor Yellow
    Write-Host "    powershell -NoProfile -ExecutionPolicy Bypass -File .\windows\install.ps1 -Yes -ForcePSReadLineUpdate" -ForegroundColor Yellow
    Write-Host "  Ou dans une seule session sans autre terminal ouvert:  Update-Module -Name PSReadLine -Scope CurrentUser -Force" -ForegroundColor Yellow
}
