[CmdletBinding()]
param(
    [switch]$Yes,
    # Tente Install-Module PSReadLine meme si une version recente est deja la.
    [switch]$ForcePSReadLineUpdate,
    # Version d'Oh My Posh a installer via winget. Vide = derniere.
    # Ex. "19.33.0". Surchargeable via $env:OHMYPOSH_VERSION.
    [string]$OhMyPoshVersion = ""
)

if (-not $OhMyPoshVersion) {
    $OhMyPoshVersion = "$($env:OHMYPOSH_VERSION)"
}

# Détermination du répertoire du script (compatible PS 5.1+)
# $PSScriptRoot fonctionne sur PS 6+, fallback sur $MyInvocation.MyCommand.Path pour PS 5.1
$scriptDir = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($scriptDir)) {
    $scriptDir = Split-Path -Parent -LiteralPath $MyInvocation.MyCommand.Path
}
# Chargement des fonctions utilitaires communes
. (Join-Path $scriptDir "_common.ps1")

Assert-Windows

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
    $wingetArgs = @(
        "install", "JanDeDobbeleer.OhMyPosh",
        "--source", "winget",
        "--accept-package-agreements", "--accept-source-agreements"
    )
    if (-not [string]::IsNullOrWhiteSpace($OhMyPoshVersion)) {
        Write-Host "    Version epinglee : $OhMyPoshVersion"
        $wingetArgs += @("--version", $OhMyPoshVersion)
    }
    & winget.exe @wingetArgs
    Refresh-UserPath

    if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
        Write-Warning "oh-my-posh n'est pas encore dans le PATH. Fermez et rouvrez le terminal, ou verifiez l'installation winget."
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

Write-Host "==> Oh My Posh (executable ; le module PowerShell est deprecie)..."
Remove-LegacyOhMyPoshModule
Install-OhMyPoshExecutable

Write-Host "==> Installation des modules PowerShell (CurrentUser)..."
Initialize-ModuleInstall

$minPSReadLine = [version]"2.1.0"
$psReadLineInstalled = Get-PSReadLineBestInstalledVersion

$requiredModules = @(
    "Terminal-Icons",
    "z"
)
$script:PSReadLinePossiblyLocked = $false
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
                $script:PSReadLinePossiblyLocked = $true
            }
        }
    } catch {
        Write-Warning "Echec installation module 'PSReadLine': $($_.Exception.Message)"
        $script:PSReadLinePossiblyLocked = $true
    }
}

# Code de sortie 2 pour signaler a l'orchestrateur un probable verrouillage PSReadLine (sans echouer la suite).
if ($script:PSReadLinePossiblyLocked) {
    Write-Host ""
    Write-Warning "PSReadLine n'a peut-etre pas ete mis a jour (fichiers verrouilles par un processus qui charge le module)."
    Write-Host "  Fermez toutes les fenetres PowerShell/Windows Terminal/Cursor/VS Code, puis relancez avec -ForcePSReadLineUpdate si besoin." -ForegroundColor Yellow
}

Write-Host "OK Etape Terminal terminee."
