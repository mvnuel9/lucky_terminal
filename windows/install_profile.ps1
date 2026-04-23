[CmdletBinding()]
param(
    [switch]$Yes
)

# Détermination du répertoire du script (compatible PS 5.1+)
# $PSScriptRoot fonctionne sur PS 6+, fallback sur $MyInvocation.MyCommand.Path pour PS 5.1
$scriptDir = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($scriptDir)) {
    $scriptDir = Split-Path -Parent -LiteralPath $MyInvocation.MyCommand.Path
}
# Chargement des fonctions utilitaires communes
. (Join-Path $scriptDir "_common.ps1")

Assert-Windows

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
    Invoke-Die "Profil source introuvable: $profileSource" -ExitCode $Script:Lucky_Exit_MissingFile
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

if (Confirm-Step -Message "Importer un profil Windows Terminal Mvnuel d'exemple ?" -Yes:$Yes) {
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

Write-Host "OK Etape Profil terminee."
