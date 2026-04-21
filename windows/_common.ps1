# Fonctions utilitaires partagées par les scripts d'installation Windows.
# Dot-sourcer en début de script :  . (Join-Path $PSScriptRoot "_common.ps1")

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

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
            throw "Impossible de determiner le repertoire du script (PSScriptRoot vide)."
        }
        $dir = Split-Path -Parent -LiteralPath $path
    }
    return [string](@($dir)[0])
}
