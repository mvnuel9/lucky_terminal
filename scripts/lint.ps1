<#
.SYNOPSIS
    Lance PSScriptAnalyzer sur les scripts PowerShell du dépôt.

.DESCRIPTION
    Parcourt les fichiers *.ps1, *.psm1, *.psd1 versionnés (via git ls-files) et
    lance Invoke-ScriptAnalyzer avec la configuration PSScriptAnalyzerSettings.psd1
    située à la racine du dépôt.

    Exit codes :
      0 : aucun warning/erreur
      1 : warnings ou erreurs trouvés
      2 : module PSScriptAnalyzer manquant

.PARAMETER Fix
    Applique Invoke-Formatter en place sur chaque script (formatage selon les
    règles de style PSScriptAnalyzerSettings.psd1).

.EXAMPLE
    .\scripts\lint.ps1
    .\scripts\lint.ps1 -Fix
#>
param(
    [switch]$Fix
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Racine du dépôt = dossier parent de ce script.
$scriptDir = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($scriptDir)) {
    $scriptDir = Split-Path -Parent -LiteralPath $MyInvocation.MyCommand.Path
}
$repoRoot = Split-Path -Parent -LiteralPath $scriptDir
$settingsFile = Join-Path -Path $repoRoot -ChildPath 'PSScriptAnalyzerSettings.psd1'

function Write-Info { param([string]$Message) Write-Host "[INFO] $Message" }
function Write-Warn { param([string]$Message) Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-Err { param([string]$Message) Write-Host "[ERROR] $Message" -ForegroundColor Red }

# Vérifie la présence du module.
if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
    Write-Warn 'PSScriptAnalyzer introuvable.'
    Write-Warn 'Installation (CurrentUser) :'
    Write-Warn '  Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force'
    exit 2
}

Import-Module PSScriptAnalyzer -ErrorAction Stop

# Liste des scripts versionnés (fallback sur Get-ChildItem si pas de git).
Push-Location -LiteralPath $repoRoot
try {
    $scripts = @()
    $gitAvailable = $null -ne (Get-Command git -ErrorAction SilentlyContinue)
    if ($gitAvailable) {
        $scripts = git ls-files '*.ps1' '*.psm1' '*.psd1' 2>$null
    }
    if (-not $scripts -or $scripts.Count -eq 0) {
        $scripts = Get-ChildItem -Path $repoRoot -Recurse -Include *.ps1, *.psm1, *.psd1 -File `
        | Where-Object { $_.FullName -notmatch '\\\.git\\' } `
        | ForEach-Object { $_.FullName.Substring($repoRoot.Length + 1) }
    }
} finally {
    Pop-Location
}

if (-not $scripts -or $scripts.Count -eq 0) {
    Write-Warn 'Aucun script PowerShell trouvé — rien à linter.'
    exit 0
}

Write-Info "$($scripts.Count) script(s) PowerShell à analyser."

$exitCode = 0

foreach ($relPath in $scripts) {
    $fullPath = Join-Path -Path $repoRoot -ChildPath $relPath

    if ($Fix) {
        Write-Info "Formatting: $relPath"
        try {
            $content = Get-Content -LiteralPath $fullPath -Raw
            $formatted = Invoke-Formatter -ScriptDefinition $content -Settings $settingsFile
            if ($formatted -ne $content) {
                Set-Content -LiteralPath $fullPath -Value $formatted -NoNewline
                Write-Info "  -> reformaté"
            }
        } catch {
            Write-Warn "  -> échec formatage : $($_.Exception.Message)"
        }
    }

    $issues = Invoke-ScriptAnalyzer -Path $fullPath -Settings $settingsFile -ErrorAction SilentlyContinue
    if ($issues) {
        $exitCode = 1
        Write-Err "$relPath : $($issues.Count) problème(s)"
        $issues | Format-Table -AutoSize -Property Severity, Line, RuleName, Message
    } else {
        Write-Info "$relPath : OK"
    }
}

if ($exitCode -eq 0) {
    Write-Info 'PSScriptAnalyzer : aucun problème.'
} else {
    Write-Err 'PSScriptAnalyzer a signalé des problèmes (voir ci-dessus).'
}

exit $exitCode
