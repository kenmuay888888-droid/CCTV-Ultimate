param(
    [int]$Port = 8090,
    [string]$DisplayName = "CCTV Ultimate Agent DVR 8090"
)

$ErrorActionPreference = "Stop"

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if (-not $isAdmin) {
    Write-Error "Run PowerShell as Administrator before installing firewall rules."
}

$existing = Get-NetFirewallRule -DisplayName $DisplayName -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "Firewall rule already exists: $DisplayName"
    Get-NetFirewallRule -DisplayName $DisplayName | Format-List DisplayName,Enabled,Profile,Direction,Action
    return
}

New-NetFirewallRule `
    -DisplayName $DisplayName `
    -Direction Inbound `
    -Action Allow `
    -Protocol TCP `
    -LocalPort $Port `
    -Profile Private | Out-Null

Write-Host "Created firewall rule for TCP port $Port on Private profile only."
Write-Host "Do not create router port forwarding. Use Tailscale private IP from your phone."
