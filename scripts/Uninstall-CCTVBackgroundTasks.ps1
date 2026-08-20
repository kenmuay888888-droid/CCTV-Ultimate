param(
    [string]$FirewallRuleName = "CCTV Ultimate Agent DVR 8090",
    [switch]$DeleteLogs
)

$ErrorActionPreference = "Stop"

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if (-not $isAdmin) {
    Write-Error "Run PowerShell as Administrator before uninstalling scheduled tasks or firewall rules."
}

$tasks = @(
    "CCTV Ultimate Watchdog",
    "CCTV Ultimate Health Check"
)

foreach ($task in $tasks) {
    $existing = Get-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue
    if ($existing) {
        Unregister-ScheduledTask -TaskName $task -Confirm:$false
        Write-Host "Removed scheduled task: $task"
    }
}

$rule = Get-NetFirewallRule -DisplayName $FirewallRuleName -ErrorAction SilentlyContinue
if ($rule) {
    Remove-NetFirewallRule -DisplayName $FirewallRuleName
    Write-Host "Removed firewall rule: $FirewallRuleName"
}

if ($DeleteLogs -and (Test-Path "C:\CCTV\Logs")) {
    Remove-Item -LiteralPath "C:\CCTV\Logs" -Recurse -Force
    Write-Host "Deleted C:\CCTV\Logs"
}

Write-Host "CCTV Ultimate background helper cleanup complete."
