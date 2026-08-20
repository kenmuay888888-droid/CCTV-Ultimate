param(
    [int]$Port = 8090,
    [switch]$Local
)

$ErrorActionPreference = "Stop"

if ($Local) {
    $url = "http://localhost:$Port"
    Start-Process $url
    Write-Host "Opened $url"
    return
}

$tailscale = Get-Command tailscale -ErrorAction SilentlyContinue
if (-not $tailscale) {
    $url = "http://localhost:$Port"
    Start-Process $url
    Write-Host "Tailscale CLI not found. Opened local monitor: $url"
    return
}

$ip = (& tailscale ip -4 2>$null | Select-Object -First 1)
if (-not $ip) {
    $url = "http://localhost:$Port"
    Start-Process $url
    Write-Host "Tailscale IP not available. Opened local monitor: $url"
    return
}

$url = "http://${ip}:$Port"
Start-Process $url
Write-Host "Opened $url"
