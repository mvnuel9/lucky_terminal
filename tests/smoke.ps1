<#
.SYNOPSIS
    Smoke tests PowerShell pour Lucky Terminal (aucun effet de bord).

.DESCRIPTION
    Vérifie deux choses :
      1. Parsing AST (`[Parser]::ParseFile`) de chaque *.ps1 / *.psm1 / *.psd1
         versionné : aucune erreur de syntaxe.
      2. Dot-source de `windows/_common.ps1` puis présence des fonctions et des
         constantes d'exit code attendues (Invoke-Die, Assert-Windows, etc.).

    Aucune invocation d'install/uninstall : les scripts Windows n'ont pas encore
    de mode `-WhatIf` / `-DryRun` complet. Le smoke se limite donc à la
    validation statique.

    Exit codes :
      0 : tous les tests passent
      1 : au moins un test échoue
      3 : mauvais usage

.EXAMPLE
    ./tests/smoke.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptDir = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($scriptDir)) {
    $scriptDir = Split-Path -Parent -LiteralPath $MyInvocation.MyCommand.Path
}
$repoRoot = Split-Path -Parent -LiteralPath $scriptDir

function Write-Pass {
    param([Parameter(Mandatory = $true)][string]$Label)
    Write-Host "[OK]    PASS  $Label" -ForegroundColor Green
}

function Write-Fail {
    param([Parameter(Mandatory = $true)][string]$Label, [string]$Detail = "")
    Write-Host "[ERROR] FAIL  $Label" -ForegroundColor Red
    if (-not [string]::IsNullOrWhiteSpace($Detail)) {
        Write-Host "        $Detail" -ForegroundColor Red
    }
}

function Write-Info {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Host "[INFO]  $Message" -ForegroundColor Cyan
}

function Write-Warn {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Host "[WARN]  $Message" -ForegroundColor Yellow
}

$script:Total = 0
$script:Failures = 0

function Invoke-Test {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][scriptblock]$Body
    )
    $script:Total++
    try {
        $ok = & $Body
        if ($ok) {
            Write-Pass $Label
        } else {
            $script:Failures++
            Write-Fail $Label
        }
    } catch {
        $script:Failures++
        Write-Fail $Label $_.Exception.Message
    }
}

Write-Info "=== Smoke test PowerShell — racine : $repoRoot ==="

# --- 1) Parsing AST ----------------------------------------------------------
Write-Info "[1/2] Parsing AST des *.ps1 / *.psm1 / *.psd1..."

$psFiles = @(
    Get-ChildItem -Path $repoRoot -Recurse -File -Include '*.ps1', '*.psm1', '*.psd1' -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '[/\\]\.git[/\\]' }
)

if ($psFiles.Count -eq 0) {
    Write-Warn 'Aucun fichier PowerShell trouvé — étape 1 ignorée.'
} else {
    foreach ($file in $psFiles) {
        $rel = $file.FullName.Substring($repoRoot.Length + 1)
        Invoke-Test -Label "parse $rel" -Body {
            $tokens = $null
            $errors = $null
            [System.Management.Automation.Language.Parser]::ParseFile(
                $file.FullName, [ref]$tokens, [ref]$errors
            ) | Out-Null
            if ($errors.Count -eq 0) {
                return $true
            }
            foreach ($err in $errors) {
                $line = $err.Extent.StartLineNumber
                Write-Host "        L$line : $($err.Message)" -ForegroundColor Red
            }
            return $false
        }
    }
}

# --- 2) Dot-source windows/_common.ps1 et vérif des symboles exposés ---------
Write-Info "[2/2] Dot-source de windows/_common.ps1 + vérif symboles..."

$commonPath = Join-Path -Path $repoRoot -ChildPath 'windows\_common.ps1'
if (-not (Test-Path -LiteralPath $commonPath)) {
    Write-Warn "windows/_common.ps1 introuvable — étape 2 ignorée."
} else {
    Invoke-Test -Label '_common.ps1 se charge sans erreur' -Body {
        . $commonPath
        return $true
    }

    $expectedFunctions = @(
        'Invoke-Die',
        'Assert-Windows',
        'Confirm-Step',
        'Ensure-Dir',
        'Test-IsWindowsHost'
    )
    foreach ($fn in $expectedFunctions) {
        Invoke-Test -Label "function exists: $fn" -Body {
            return $null -ne (Get-Command -Name $fn -CommandType Function -ErrorAction SilentlyContinue)
        }
    }

    $expectedVars = @(
        'Lucky_Exit_OK',
        'Lucky_Exit_Generic',
        'Lucky_Exit_MissingTool',
        'Lucky_Exit_Usage',
        'Lucky_Exit_Cancelled',
        'Lucky_Exit_UnsupportedOS',
        'Lucky_Exit_MissingFile'
    )
    foreach ($v in $expectedVars) {
        Invoke-Test -Label "variable exists: `$Script:$v" -Body {
            return $null -ne (Get-Variable -Name $v -ErrorAction SilentlyContinue)
        }
    }
}

Write-Host ""
if ($script:Failures -eq 0) {
    Write-Host "[OK]    Smoke PowerShell : $($script:Total) tests, 0 échec." -ForegroundColor Green
    exit 0
} else {
    Write-Host "[ERROR] Smoke PowerShell : $($script:Failures) échec(s) sur $($script:Total) tests." -ForegroundColor Red
    exit 1
}
