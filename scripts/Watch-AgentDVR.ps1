param(
    [int]$Port = 8090,
    [string]$AgentPath = "C:\Program Files\Agent DVR\AgentDVR.exe",
    [string]$LogDir = "C:\CCTV\Logs"
)

$ErrorActionPreference = "Stop"

New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
$logFile = Join-Path $LogDir "watchdog.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

function Write-CCTVLog {
    param([string]$Message)
    "$timestamp | $Message" | Tee-Object -FilePath $logFile -Append
}

$agent = Get-Process -Name "AgentDVR","Agent" -ErrorAction SilentlyContinue
$portState = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue

if ($agent -and $portState) {
    Write-CCTVLog "OK Agent DVR is running and port $Port is listening."
    return
}

Write-CCTVLog "WARN Agent DVR check failed. process=$([bool]$agent) port=$([bool]$portState)"

if (-not (Test-Path $AgentPath)) {
    Write-CCTVLog "ERROR Agent DVR executable not found at $AgentPath"
    exit 1
}

Start-Process -FilePath $AgentPath -WindowStyle Hidden
Start-Sleep -Seconds 15

$agent = Get-Process -Name "AgentDVR","Agent" -ErrorAction SilentlyContinue
$portState = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue

if ($agent -and $portState) {
    Write-CCTVLog "OK Agent DVR restarted successfully."
} else {
    Write-CCTVLog "ERROR Agent DVR restart did not pass health check."
    exit 1
}
