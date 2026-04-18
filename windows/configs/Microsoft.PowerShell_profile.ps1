# Mvnuel - PowerShell profile (Windows)
# Copie vers $PROFILE par windows/install.ps1
#
# Oh My Posh : binaire + init (plus de module PowerShell).
# Doc : https://ohmyposh.dev/docs/migrating

# Evite un double affichage du venv dans le prompt.
$env:VIRTUAL_ENV_DISABLE_PROMPT = "1"

# Init Oh My Posh avant Set-StrictMode (le script genere par init n'est pas toujours compatible StrictMode).
$themePath = Join-Path -Path $HOME -ChildPath ".config\mvnuel\mvnuel.omp.json"
$ompShell = if ($PSVersionTable.PSVersion.Major -ge 6) { "pwsh" } else { "powershell" }

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    if (Test-Path -LiteralPath $themePath) {
        try {
            (& oh-my-posh init $ompShell --config $themePath) | Out-String | Invoke-Expression
        } catch {
            Write-Host "[mvnuel] Echec init Oh My Posh : $($_.Exception.Message)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "[mvnuel] Theme introuvable : $themePath" -ForegroundColor Yellow
    }
} else {
    Write-Host "[mvnuel] oh-my-posh absent du PATH. Installez : winget install JanDeDobbeleer.OhMyPosh --source winget" -ForegroundColor Yellow
    Write-Host "         Puis relancez ce profil :  . `$PROFILE" -ForegroundColor Yellow
}

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons -ErrorAction SilentlyContinue
}

if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue
    $psReadLineModule = Get-Module -ListAvailable -Name PSReadLine | Sort-Object Version -Descending | Select-Object -First 1
    if ($psReadLineModule -and $psReadLineModule.Version -ge [Version]"2.1.0") {
        # Prediction : PSReadLine 2.1+ (souvent absent sur PS 5.1 par defaut).
        Set-PSReadLineOption -PredictionSource History
        Set-PSReadLineOption -PredictionViewStyle ListView
    }
    Set-PSReadLineKeyHandler -Chord "Ctrl+d" -Function DeleteCharOrExit
}

if (Get-Module -ListAvailable -Name z) {
    Import-Module z -ErrorAction SilentlyContinue
}

# cls -> Clear-Host est deja un alias AllScope integre ; ne pas Set-Alias (erreur AllScope sous PS 5.1).

function ll { Get-ChildItem -Force }
function la { Get-ChildItem -Force -Hidden }

# PS 5.1 : Documents\WindowsPowerShell\ ; PS 7+ : souvent Documents\PowerShell\
$__mvnuelProfileDir = $null
if ($PROFILE) {
    $__mvnuelProfileDir = Split-Path -Parent -Path $PROFILE
}
if ($__mvnuelProfileDir) {
    $__aliases = Join-Path -Path $__mvnuelProfileDir -ChildPath "aliases.ps1"
    $__functions = Join-Path -Path $__mvnuelProfileDir -ChildPath "functions.ps1"
    if (Test-Path -LiteralPath $__aliases) {
        . $__aliases
    }
    if (Test-Path -LiteralPath $__functions) {
        . $__functions
    }
}
