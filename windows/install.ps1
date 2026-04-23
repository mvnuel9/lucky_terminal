[CmdletBinding()]
param(
    [switch]$Yes,
    # Tente Install-Module PSReadLine meme si une version recente est deja la.
    [switch]$ForcePSReadLineUpdate,
    # Enregistre les .ttf/.otf d'un dossier dans les polices utilisateur avant install.
    [string]$NerdFontDirectory = ""
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

$fontsScript = Join-Path $scriptDir "install_fonts.ps1"
$terminalScript = Join-Path $scriptDir "install_terminal.ps1"
$profileScript = Join-Path $scriptDir "install_profile.ps1"

Write-Host "==> [1/3] Polices Nerd Font..."
& $fontsScript -Yes:$Yes -NerdFontDirectory $NerdFontDirectory

Write-Host ""
Write-Host "==> [2/3] Oh My Posh + modules PowerShell..."
& $terminalScript -Yes:$Yes -ForcePSReadLineUpdate:$ForcePSReadLineUpdate

Write-Host ""
Write-Host "==> [3/3] Profil PowerShell + theme Windows Terminal..."
& $profileScript -Yes:$Yes

Write-Host ""
Write-Host "Installation terminee."
Write-Host "Actions recommandees:"
Write-Host "  1) Modele Windows Terminal : police RobotoMono Nerd Font. Si alerte police : relancer avec -NerdFontDirectory `"chemin_vers_dossier`"."
Write-Host "  2) Ouvrir une nouvelle session PowerShell."
Write-Host "  3) Verifier le prompt Mvnuel et les icones."
