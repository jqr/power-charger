$SrcDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Info = Get-Content "$SrcDir\info.json" | ConvertFrom-Json
$ModName = "power-charger_$($Info.version)"
$ModsDir = "$env:APPDATA\Factorio\mods"

if (-not (Test-Path $ModsDir)) {
    Write-Error "Mods directory not found at $ModsDir. Is Factorio installed?"
    exit 1
}

$Target = Join-Path $ModsDir $ModName

if (Test-Path $Target) {
    Remove-Item $Target -Recurse -Force
}

New-Item -ItemType Junction -Path $Target -Target $SrcDir | Out-Null

Write-Host "Linked $Target -> $SrcDir"
Write-Host "Restart Factorio to load the mod."
