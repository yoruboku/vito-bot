#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Color([string]$text, [string]$color){ Write-Host $text -ForegroundColor $color }

Color "============================================" Cyan
Color "           V I T O - Installer              " Cyan
Color "============================================" Cyan

# Find Python
$pythonCandidates = @("python","python3","py")
$PY = $null
foreach ($c in $pythonCandidates) { if (Get-Command $c -ErrorAction SilentlyContinue) { $PY = $c; break } }
if (-not $PY) { Color "Python 3.9+ not found. Install Python and retry." Red; exit 1 }
Color "Using Python: $PY" Green

# If installed already
if (Test-Path "venv" -and Test-Path ".env") {
    Color "Existing install found." Yellow
    $resp = Read-Host "Update dependencies and start VITO now? (y/n)"
    if ($resp -match '^[Yy]') {
        & .\venv\Scripts\Activate.ps1
        pip install --upgrade pip
        pip install -r requirements.txt
        & $PY -m playwright install chromium
        & $PY main.py
        exit
    } else { exit 0 }
}

Color "Creating virtualenv..." Blue
& $PY -m venv venv
.\venv\Scripts\Activate.ps1

Color "Installing dependencies..." Blue
pip install --upgrade pip
pip install -r requirements.txt

Color "Installing Playwright Chromium..." Blue
& $PY -m playwright install chromium

# Discord token + Bot ID
while ($true) {
    $TOKEN = Read-Host "Enter your Discord BOT TOKEN"
    $BOTID = Read-Host "Enter your Discord BOT ID (numeric)"
    Color "You entered:" Magenta
    Write-Host ("TOKEN: " + $TOKEN.Substring(0,[Math]::Min(6,$TOKEN.Length)) + "... (hidden)")
    Write-Host ("BOT ID: " + $BOTID)
    $ok = Read-Host "Is this correct? (y/n)"
    if ($ok -match '^[Yy]') { break }
}

# Owner menu
Write-Host ""
Write-Host "Owner configuration options:"
Write-Host "1) Default (only 'yoruboku' has priority)"
Write-Host "2) Set Owner A (single username)"
Write-Host "3) Set Owner A + Owner B (multiple usernames)"
$choice = Read-Host "Choose 1/2/3"
$OWNER_MAIN = ""
$OWNER_EXTRA = ""

if ($choice -eq "2") {
    $OWNER_MAIN = Read-Host "Enter Owner A global username (e.g. yoruboku)"
} elseif ($choice -eq "3") {
    $OWNER_MAIN = Read-Host "Enter Owner A global username"
    $OWNER_EXTRA = Read-Host "Enter Owner B usernames (comma separated)"
}

Write-Host "Owner settings:"
if (-not $OWNER_MAIN -and -not $OWNER_EXTRA) { Write-Host "Default: priority owner 'yoruboku' only." } else {
    Write-Host ("OWNER_MAIN: " + $OWNER_MAIN)
    Write-Host ("OWNER_EXTRA: " + $OWNER_EXTRA)
}
$confirm = Read-Host "Save settings? (y/n)"
if ($confirm -notmatch '^[Yy]') { Write-Host "Aborting."; exit 1 }

# Write .env
@"
DISCORD_TOKEN=$TOKEN
BOT_ID=$BOTID
OWNER_MAIN=$OWNER_MAIN
OWNER_EXTRA=$OWNER_EXTRA
PRIORITY_OWNER=yoruboku
"@ | Out-File -Encoding utf8 .env
Write-Host ".env created." -ForegroundColor Green

# Open persistent Chromium for Gemini login
New-Item -ItemType Directory -Force -Path "playwright_data" | Out-Null
$open = Read-Host "Open Chromium now to log into Gemini? (y/n)"
if ($open -match '^[Yy]') {
    $pycode = @"
from playwright.sync_api import sync_playwright
import os
os.makedirs('playwright_data', exist_ok=True)
with sync_playwright() as p:
    context = p.chromium.launch_persistent_context(user_data_dir='playwright_data', headless=False)
    page = context.new_page()
    page.goto('https://gemini.google.com/')
    print('Log in, then close the browser window to continue.')
    try:
        context.wait_for_event('close')
    except:
        pass
    context.storage_state(path='playwright_data/state.json')
    context.close()
"@
    & $PY -c $pycode
}

Write-Host "Starting VITO..." -ForegroundColor Green
& $PY main.py
