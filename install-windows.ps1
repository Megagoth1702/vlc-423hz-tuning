[CmdletBinding()]
param(
    [switch]$NoPrompt
)

$ErrorActionPreference = "Stop"

try {
    if ([string]::IsNullOrWhiteSpace($env:APPDATA)) {
        throw "The APPDATA environment variable is not available."
    }

    $sourceFile = Join-Path $PSScriptRoot "VLC-432Hz-tuning.lua"
    $extensionsDirectory = Join-Path $env:APPDATA "vlc\lua\extensions"
    $destinationFile = Join-Path $extensionsDirectory "VLC-432Hz-tuning.lua"

    if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
        throw "VLC-432Hz-tuning.lua was not found beside this installer."
    }

    New-Item -ItemType Directory -Path $extensionsDirectory -Force | Out-Null
    Copy-Item -LiteralPath $sourceFile -Destination $destinationFile -Force

    Write-Host ""
    Write-Host "VLC 432 Hz Tuning was installed successfully." -ForegroundColor Green
    Write-Host "Destination: $destinationFile"
    Write-Host "Restart VLC, then open View > 432 Hz Tuning."
}
catch {
    Write-Error "Installation failed: $($_.Exception.Message)"
    exit 1
}
finally {
    if (-not $NoPrompt -and $Host.Name -eq "ConsoleHost") {
        Read-Host "Press Enter to close"
    }
}
