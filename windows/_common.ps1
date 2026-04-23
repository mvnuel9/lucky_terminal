# Fonctions utilitaires partagées par les scripts d'installation Windows.
# Dot-sourcer en début de script :  . (Join-Path $PSScriptRoot "_common.ps1")
#
# Pendant PowerShell de scripts/_common.sh (Bash). Les constantes
# $Lucky_Exit_* sont alignées sur les LUCKY_EXIT_* Bash pour permettre un
# diagnostic uniforme quelle que soit la plate-forme.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# --- Codes de sortie (convention projet, alignée avec scripts/_common.sh) ---
$Script:Lucky_Exit_OK = 0
$Script:Lucky_Exit_Generic = 1
$Script:Lucky_Exit_MissingTool = 2
$Script:Lucky_Exit_Usage = 3
$Script:Lucky_Exit_Cancelled = 10
$Script:Lucky_Exit_UnsupportedOS = 20
$Script:Lucky_Exit_MissingFile = 21

function Invoke-Die {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)][string]$Message,
        [int]$ExitCode = $Script:Lucky_Exit_Generic
    )

    Write-Host "[ERROR] $Message" -ForegroundColor Red
    exit $ExitCode
}

function Assert-Windows {
    if (-not (Test-IsWindowsHost)) {
        Invoke-Die 'Ce script est prevu pour Windows.' -ExitCode $Script:Lucky_Exit_UnsupportedOS
    }
}

function Confirm-Step {
    param(
        [Parameter(Mandatory = $true)][string]$Message,
        [Parameter()][switch]$Yes
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

function Refresh-UserPath {
    $machine = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $user = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machine;$user"
}

function Get-ScriptDir {
    param(
        [Parameter(Mandatory = $true)][System.Management.Automation.InvocationInfo]$Invocation
    )

    $dir = $PSScriptRoot
    if ([string]::IsNullOrWhiteSpace($dir)) {
        $path = $PSCommandPath
        if ([string]::IsNullOrWhiteSpace($path)) {
            $path = $Invocation.MyCommand.Path
        }
        if ([string]::IsNullOrWhiteSpace($path)) {
            Invoke-Die "Impossible de determiner le repertoire du script (PSScriptRoot vide)." -ExitCode $Script:Lucky_Exit_Generic
        }
        $dir = Split-Path -Parent -LiteralPath $path
    }
    return [string](@($dir)[0])
}
