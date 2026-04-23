[CmdletBinding()]
param(
    [switch]$Yes,
    # Enregistre les .ttf/.otf d'un dossier (ex. Nerd Fonts extrait ailleurs) dans les polices utilisateur Windows.
    # Si vide, utilise windows/fonts/RobotoMono/ livré avec le dépôt.
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

# Source = -NerdFontDirectory si fourni, sinon le dossier livré avec le dépôt.
$sourceDir = $NerdFontDirectory.Trim()
if ([string]::IsNullOrWhiteSpace($sourceDir)) {
    $sourceDir = Join-Path $scriptDir "fonts\RobotoMono"
}

if (Test-RobotoMonoNerdFontInstalled) {
    Write-Host "==> Police RobotoMono Nerd Font deja installee : rien a faire."
} elseif (-not (Test-Path -LiteralPath $sourceDir)) {
    Write-Warning "==> Dossier polices introuvable : $sourceDir"
    Write-Host "    Installez a la main ou relancez avec -NerdFontDirectory `"<chemin>`"."
} else {
    Write-Host "==> Enregistrement des polices utilisateur (source: $sourceDir)..."
    Install-UserFontsFromDirectory -Directory $sourceDir
}

Write-Host "OK Etape Fonts terminee."
