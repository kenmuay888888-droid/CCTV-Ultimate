$ErrorActionPreference = "Stop"

$versionOutput = py -3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')"
$version = [version]$versionOutput
if ($version -lt [version]"3.11" -or $version -ge [version]"3.14") {
    Write-Error "CCTV Ultimate requires Python 3.11, 3.12, or 3.13. Detected Python $versionOutput."
}

if (-not (Test-Path ".venv")) {
    py -3 -m venv .venv
}

.\.venv\Scripts\python.exe -m pip install --upgrade pip
.\.venv\Scripts\python.exe -m pip install -r requirements.txt

if (-not (Test-Path "config.json")) {
    Copy-Item "config.example.json" "config.json"
}

.\.venv\Scripts\python.exe -m cctv_ultimate
