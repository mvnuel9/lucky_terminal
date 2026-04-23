[CmdletBinding()]
param(
    [switch]$Yes,
    [switch]$WithHistory
)

# Détermination du répertoire du script (compatible PS 5.1+)
$scriptDir = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($scriptDir)) {
    $scriptDir = Split-Path -Parent -LiteralPath $MyInvocation.MyCommand.Path
}
# Chargement des fonctions utilitaires communes
. (Join-Path $scriptDir "_common.ps1")

Assert-Windows

$profilePath = $null
if ($PROFILE | Get-Member -Name CurrentUserCurrentHost -ErrorAction SilentlyContinue) {
    $profilePath = $PROFILE.CurrentUserCurrentHost
}
if ([string]::IsNullOrWhiteSpace($profilePath)) {
    $profilePath = [string]$PROFILE
} else {
    $profilePath = [string]$profilePath
}

$targets = @(
    $profilePath,
    "$profilePath.bak.mvnuel.*",
    "$HOME\.config\mvnuel",
    "$HOME\Documents\PowerShell\aliases.ps1",
    "$HOME\Documents\PowerShell\functions.ps1",
    "$HOME\Documents\WindowsPowerShell\aliases.ps1",
    "$HOME\Documents\WindowsPowerShell\functions.ps1"
)

if ($WithHistory) {
    $targets += "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
}

Write-Host "Elements cibles pour purge:"
foreach ($target in $targets) {
    Write-Host "  - $target"
}

if (-not (Confirm-Step -Message "Confirmer la suppression des elements ci-dessus ?" -Yes:$Yes)) {
    Write-Host "Purge annulee."
    exit $Script:Lucky_Exit_Cancelled
}

foreach ($target in $targets) {
    if ($target.Contains("*")) {
        $dir = Split-Path -Parent $target
        $pattern = Split-Path -Leaf $target
        if (Test-Path -LiteralPath $dir) {
            Get-ChildItem -Path $dir -Filter $pattern -ErrorAction SilentlyContinue | ForEach-Object {
                Remove-Item -LiteralPath $_.FullName -Force -Recurse -ErrorAction SilentlyContinue
                Write-Host "Supprime: $($_.FullName)"
            }
        }
        continue
    }

    if (Test-Path -LiteralPath $target) {
        Remove-Item -LiteralPath $target -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "Supprime: $target"
    }
}

Write-Host "Purge terminee."
