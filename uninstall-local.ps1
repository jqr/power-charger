$ModsDir = "$env:APPDATA\Factorio\mods"
$found = $false

Get-ChildItem "$ModsDir\power-charger_*" -ErrorAction SilentlyContinue | ForEach-Object {
    if ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        Remove-Item $_.FullName -Force
        Write-Host "Removed junction $($_.FullName)"
        $found = $true
    } else {
        Write-Host "Skipping $($_.FullName) - not a junction. Remove it manually if needed."
    }
}

if (-not $found) {
    Write-Host "Nothing to remove - no power-charger junctions found in $ModsDir"
}
