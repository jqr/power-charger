$ModName = "power-charger_0.1.0"
$ModsDir = "$env:APPDATA\Factorio\mods"
$Target = Join-Path $ModsDir $ModName

if (Test-Path $Target) {
    $item = Get-Item $Target -Force
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        Remove-Item $Target -Force
        Write-Host "Removed junction $Target"
    } else {
        Write-Error "$Target exists but is not a junction. Remove it manually."
        exit 1
    }
} else {
    Write-Host "Nothing to remove - $Target does not exist."
}
