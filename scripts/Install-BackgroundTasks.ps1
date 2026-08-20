param(
    [string]$BasePath = "C:\CCTV",
    [int]$Port = 8090,
    [string]$AgentPath = "C:\Program Files\Agent DVR\AgentDVR.exe"
)

$ErrorActionPreference = "Stop"

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if (-not $isAdmin) {
    Write-Error "Run PowerShell as Administrator before installing scheduled tasks."
}

$scriptsDir = Join-Path $BasePath "Scripts"
$logsDir = Join-Path $BasePath "Logs"
New-Item -ItemType Directory -Path $scriptsDir,$logsDir -Force | Out-Null

Copy-Item -Path "$PSScriptRoot\Watch-AgentDVR.ps1" -Destination $scriptsDir -Force
Copy-Item -Path "$PSScriptRoot\Health-Check-AgentDVR.ps1" -Destination $scriptsDir -Force

$watchScript = Join-Path $scriptsDir "Watch-AgentDVR.ps1"
$healthScript = Join-Path $scriptsDir "Health-Check-AgentDVR.ps1"

$watchAction = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$watchScript`" -Port $Port -AgentPath `"$AgentPath`" -LogDir `"$logsDir`""

$watchTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) `
    -RepetitionInterval (New-TimeSpan -Minutes 5)

$watchSettings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 2)

Register-ScheduledTask `
    -TaskName "CCTV Ultimate Watchdog" `
    -Action $watchAction `
    -Trigger $watchTrigger `
    -Settings $watchSettings `
    -RunLevel Highest `
    -Force | Out-Null

$healthAction = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$healthScript`" -Port $Port -LogDir `"$logsDir`""

$healthTrigger = New-ScheduledTaskTrigger -Daily -At "08:00"

Register-ScheduledTask `
    -TaskName "CCTV Ultimate Health Check" `
    -Action $healthAction `
    -Trigger $healthTrigger `
    -RunLevel Highest `
    -Force | Out-Null

Write-Host "Installed scheduled tasks:"
Get-ScheduledTask -TaskName "CCTV Ultimate Watchdog","CCTV Ultimate Health Check" |
    Select-Object TaskName,State

Write-Host ""
Write-Host "Logs will be written to $logsDir"
