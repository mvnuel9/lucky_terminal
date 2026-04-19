[CmdletBinding()]
param(
    [switch]$Yes
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

function Test-IsWindowsHost {
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        return $IsWindows
    }

    return $env:OS -eq "Windows_NT"
}

if (-not (Test-IsWindowsHost)) {
    throw "Ce script est prevu pour Windows."
}

$profileTarget = $null
if ($PROFILE | Get-Member -Name CurrentUserCurrentHost -ErrorAction SilentlyContinue) {
    $profileTarget = $PROFILE.CurrentUserCurrentHost
}
if ([string]::IsNullOrWhiteSpace($profileTarget)) {
    $profileTarget = [string]$PROFILE
} else {
    $profileTarget = [string]$profileTarget
}
$themeTarget = Join-Path -Path $HOME -ChildPath ".config\mvnuel\mvnuel.omp.json"

$terminalTargets = @(
    (Join-Path -Path $env:LOCALAPPDATA -ChildPath "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"),
    (Join-Path -Path $env:LOCALAPPDATA -ChildPath "Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json")
)

Write-Host "==> Desinstallation Lucky Terminal Windows"

if (Test-Path -LiteralPath $profileTarget) {
    if (Confirm-Step -Message "Sauvegarder puis supprimer le profil PowerShell actuel ($profileTarget) ?") {
        $backup = "$profileTarget.bak.uninstall.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item -LiteralPath $profileTarget -Destination $backup -Force
        Remove-Item -LiteralPath $profileTarget -Force
        Write-Host "    Profil retire. Sauvegarde: $backup"
    }
}

if (Test-Path -LiteralPath $themeTarget) {
    if (Confirm-Step -Message "Supprimer le theme Mvnuel Oh My Posh ($themeTarget) ?") {
        Remove-Item -LiteralPath $themeTarget -Force
        Write-Host "    Theme supprime."
    }
}

if (Confirm-Step -Message 'Desinstaller les modules PowerShell (Terminal-Icons, z) et l''ancien module oh-my-posh s''il reste ?') {
    $modules = @("oh-my-posh", "Terminal-Icons", "z")
    foreach ($moduleName in $modules) {
        if (Get-Module -ListAvailable -Name $moduleName) {
            Uninstall-Module -Name $moduleName -AllVersions -Force -ErrorAction SilentlyContinue
            Write-Host "    Module retire: $moduleName"
        }
    }
}

if (Confirm-Step -Message "Desinstaller le binaire Oh My Posh installe via winget (JanDeDobbeleer.OhMyPosh) ?") {
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($winget) {
        & winget.exe uninstall JanDeDobbeleer.OhMyPosh --source winget --accept-source-agreements 2>$null
        Write-Host "    Desinstallation winget demandee (verifiez la sortie ci-dessus)."
    } else {
        Write-Host "    winget introuvable - desinstallez Oh My Posh a la main si besoin."
    }
}

if (Confirm-Step -Message "Restaurer les settings Windows Terminal depuis un backup recent (si present) ?") {
    foreach ($target in $terminalTargets) {
        $parent = Split-Path -Parent $target
        if (-not (Test-Path -LiteralPath $parent)) {
            continue
        }

        $backups = Get-ChildItem -Path $parent -Filter "settings.json.bak.mvnuel.*" -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending
        $backupList = @($backups)
        if ($backupList.Count -gt 0) {
            Copy-Item -LiteralPath $backupList[0].FullName -Destination $target -Force
            Write-Host "    Restaure: $target"
        }
    }
}

Write-Host ""
Write-Host 'Desinstallation terminee.'
Write-Host 'Si besoin d''un nettoyage plus profond, lance windows/purge_profile.ps1.'
