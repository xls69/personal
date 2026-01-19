# ffupdate.ps1 - Arkenfox user.js updater for Firefox ESR
# THIS SCRIPT WILL DELETE YOUR FIREFOX PROFILE DATA. BACKUP FIRST!

param([switch]$Force = $false)

Set-StrictMode -Version 3.0
$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Type = "INFO")
    $color = @{"INFO" = "Green"; "ERROR" = "Red"; "WARNING" = "Yellow"}
    Write-Host "[$(Get-Date -Format HH:mm:ss)] [$Type] $Message" -ForegroundColor $color[$Type]
}

function Write-ErrorExit { param([string]$Message) Write-Log $Message "ERROR"; exit 1 }

Write-Log "ffupdate - Firefox ESR Arkenfox Updater"

# Find Firefox
$browserExe = @("$env:PROGRAMFILES\Mozilla Firefox\firefox.exe", 
                 "$env:PROGRAMFILES(X86)\Mozilla Firefox\firefox.exe",
                 "$env:LOCALAPPDATA\Mozilla Firefox\firefox.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $browserExe) { Write-ErrorExit "Firefox not found. Please install Firefox ESR." }
Write-Log "Found Firefox at: $browserExe"

# Check if Firefox is running
if (Get-Process -Name "firefox*" -ErrorAction SilentlyContinue) {
    Write-ErrorExit "Firefox is running. Please close all Firefox windows."
}

# User confirmation
Write-Host "`nTHIS SCRIPT WILL DELETE $env:APPDATA\Mozilla" -ForegroundColor Red
if ((Read-Host "Ensure you have backups. Continue? (y/N)") -notmatch '^[Yy]$') {
    Write-ErrorExit "Aborted by user."
}

# Clean and create Mozilla directory (EXACTLY like bash script)
$mozillaDir = "$env:APPDATA\Mozilla"
Write-Log "Cleaning up existing Mozilla data."
Remove-Item -Path $mozillaDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -Path $mozillaDir -ItemType Directory -Force | Out-Null

# Create default profile
Write-Log "Starting Firefox to create default profile."
Start-Process -FilePath $browserExe -ArgumentList "--headless", "--disable-gpu" -ErrorAction Stop
Start-Sleep -Seconds 5

if (-not (Get-Process -Name "firefox*" -ErrorAction SilentlyContinue)) {
    Write-ErrorExit "Failed to start Firefox ESR."
}

Get-Process -Name "firefox*" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# EXACTLY like bash script - use profiles.ini to find profile path
$profilesIni = "$env:APPDATA\Mozilla\Firefox\profiles.ini"
if (-not (Test-Path $profilesIni)) { Write-ErrorExit "profiles.ini not found at $profilesIni" }

# Parse profiles.ini exactly like bash script - look for [Profile0] section and Path
$profileContent = Get-Content $profilesIni
$profileSection = $false
$profilePath = $null

foreach ($line in $profileContent) {
    if ($line -eq '[Profile0]') {
        $profileSection = $true
        continue
    }
    if ($profileSection -and $line -match '^\[') {
        break
    }
    if ($profileSection -and $line -match '^Path=(.+)') {
        $profilePath = $matches[1].Trim()
        break
    }
}

if (-not $profilePath) {
    Write-ErrorExit "Could not determine profile path from profiles.ini."
}

# Set full profile directory path (EXACTLY like bash script)
$pdir = "$env:APPDATA\Mozilla\Firefox\$profilePath"

# Safety check (like bash script)
if (-not $pdir.StartsWith($env:USERPROFILE)) {
    Write-ErrorExit "Profile directory $pdir is not within user directory. Aborting for safety."
}

if (-not (Test-Path $pdir)) {
    Write-ErrorExit "Profile directory $pdir does not exist."
}

Write-Log "Using profile directory: $pdir"

# Download files (EXACTLY like bash script)
$overrides = "$pdir\user-overrides.js"
Write-Log "Downloading user-overrides.js..."
try {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/xls69/personal/refs/heads/master/files/user-overrides.js" -OutFile $overrides -ErrorAction Stop
} catch {
    Write-ErrorExit "Failed to download user-overrides.js. Check your internet connection."
}

$updater = "$pdir\updater.bat"
Write-Log "Downloading updater.bat..."
try {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/arkenfox/user.js/refs/heads/master/updater.bat" -OutFile $updater -ErrorAction Stop
} catch {
    Write-ErrorExit "Failed to download updater.bat. Check your internet connection."
}

Start-Sleep -Seconds 1

# Run updater (EXACTLY like bash script but with .bat and -esr)
Write-Log "Running updater.bat..."
Push-Location $pdir
$process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$updater`" -esr" -Wait -PassThru -NoNewWindow
if ($process.ExitCode -ne 0) { Write-ErrorExit "Updater failed with exit code $($process.ExitCode)." }
Pop-Location

# Install uBlock Origin (EXACTLY like bash script logic)
Write-Log "Installing uBlock Origin..."
$addontmp = Join-Path $env:TEMP "ffaddons-$(Get-Random)"
New-Item -Path $addontmp, "$pdir\extensions" -ItemType Directory -Force | Out-Null

try {
    # Get download URL (like bash script)
    $addonPage = Invoke-WebRequest -Uri "https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/" -ErrorAction Stop
    if ($addonPage.Content -match 'https://addons.mozilla.org/firefox/downloads/file/[^"]*') {
        $addonurl = $matches[0]
    } else {
        Write-ErrorExit "Could not find download URL for uBlock Origin."
    }
    
    # Download extension
    $file = [System.IO.Path]::GetFileName($addonurl)
    $xpiPath = "$addontmp\$file"
    Invoke-WebRequest -Uri $addonurl -OutFile $xpiPath -ErrorAction Stop

    # Extract extension ID from manifest.json (like bash script)
    $zipPath = "$addontmp\temp.zip"
    $extractDir = "$addontmp\extracted"
    New-Item -Path $extractDir -ItemType Directory -Force | Out-Null
    Copy-Item -Path $xpiPath -Destination $zipPath
    Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force
    
    $manifestContent = Get-Content "$extractDir\manifest.json" -Raw
    if ($manifestContent -match '"id"\s*:\s*"([^"]+)"') {
        $id = $matches[1]
    } else {
        Write-ErrorExit "Could not extract ID for uBlock Origin."
    }
    
    Move-Item -Path $xpiPath -Destination "$pdir\extensions\$id.xpi" -Force
    Write-Log "uBlock Origin installed successfully."
} catch {
    Write-ErrorExit "Failed to install uBlock Origin. Error: $($_.Exception.Message)"
} finally {
    Remove-Item -Path $addontmp -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Log "Script completed successfully. Firefox ESR configured with arkenfox/user.js and uBlock Origin."