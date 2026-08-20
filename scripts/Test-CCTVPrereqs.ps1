$ErrorActionPreference = "Stop"

Write-Host "== CCTV Ultimate prerequisite check =="

$agent = Get-Process -Name "AgentDVR","Agent" -ErrorAction SilentlyContinue
$port = Get-NetTCPConnection -LocalPort 8090 -State Listen -ErrorAction SilentlyContinue
$tailscale = Get-Command tailscale -ErrorAction SilentlyContinue
$tailscaleIp = $null

if ($tailscale) {
    $tailscaleIp = (& tailscale ip -4 2>$null | Select-Object -First 1)
}

$cameraPrivacy = "Settings > Privacy & security > Camera"

[pscustomobject]@{
    AgentDVRProcess = if ($agent) { "OK" } else { "NOT_RUNNING_OR_NOT_INSTALLED" }
    Port8090        = if ($port) { "LISTENING" } else { "NOT_LISTENING" }
    TailscaleCli    = if ($tailscale) { "OK" } else { "NOT_FOUND" }
    TailscaleIP     = if ($tailscaleIp) { $tailscaleIp } else { "NOT_AVAILABLE" }
    CameraPrivacy   = "Check manually: $cameraPrivacy"
} | Format-List

Write-Host ""
Write-Host "Required gates:"
Write-Host "1. Windows Camera app can see the camera."
Write-Host "2. Agent DVR opens at http://localhost:8090."
Write-Host "3. Agent DVR has username/password set."
Write-Host "4. Tailscale is connected on PC and phone."
Write-Host "5. Phone opens http://<tailscale-ip>:8090."
