param(
    [int]$Port = 8090,
    [string]$LogDir = "C:\CCTV\Logs",
    [int]$MinimumFreeGB = 10
)

$ErrorActionPreference = "Stop"

New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
$logFile = Join-Path $LogDir "health.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$agent = Get-Process -Name "AgentDVR","Agent" -ErrorAction SilentlyContinue
$portState = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
$tailscale = Get-Command tailscale -ErrorAction SilentlyContinue
$tailscaleStatus = if ($tailscale) { (& tailscale status 2>$null | Select-Object -First 1) } else { $null }
$drive = Get-PSDrive C
$freeGB = [math]::Round($drive.Free / 1GB, 2)

$results = [ordered]@{
    agent_dvr = if ($agent) { "OK" } else { "NOT_RUNNING" }
    port      = if ($portState) { "LISTENING_$Port" } else { "NOT_LISTENING_$Port" }
    tailscale = if ($tailscaleStatus) { "OK" } else { "NOT_CONNECTED_OR_NOT_INSTALLED" }
    disk      = if ($freeGB -ge $MinimumFreeGB) { "OK_${freeGB}GB_FREE" } else { "LOW_${freeGB}GB_FREE" }
}

$line = "$timestamp | " + (($results.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join " | ")
$line | Tee-Object -FilePath $logFile -Append

Write-Host ""
Write-Host "Health log: $logFile"
if ($results.Values -match "NOT_|LOW_") {
    exit 1
}
