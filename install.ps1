#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

# Color helpers
function Color([string]$text, [string]$color) {
    Write-Host $text -ForegroundColor $color
}

# Banner
Color "===============================================" Cyan
Color "             V I T O   -   Installer           " Cyan
Color "===============================================" Cyan
Start-Sleep -Milliseconds 400

# Python detection
$pythonCandidates = @("python", "python3", "py")
$PYTHON_BIN = $null

foreach ($p in $pythonCandidates) {
    if (Get-Command $p -ErrorAction SilentlyContinue) {
        $PYTHON_BIN = $p
        break
    }
}

if (-not $PYTHON_BIN) {
    Color "ERROR: Python 3.9+ not found. Install Python and try again." Red
    exit
}

Color "Using Python: $PYTHON_BIN" Green
Start-Sleep -Milliseconds 300

# If already installed → update + start
if ((Test-Path "venv") -and (Test-Path ".env")) {
    Color "Existing VITO installation detected." Yellow
    Color "Updating dependencies..." Blue

    & venv\Scripts\Activate.ps1
    pip install --upgrade pip
    pip install -r requirements.txt

    Color "Ensuring Playwright Chromium installed..." Blue
    & $PYTHON_BIN -m playwright install chromium

    Color "Starting VITO..." Green
    & $PYTHON_BIN main.py
    exit
}

# Create venv
Color "Creating virtual environment..." Blue
& $PYTHON_BIN -m venv venv
& venv\Scripts\Activate.ps1

# Install pip requirements
Color "Installing Python dependencies..." Blue
pip install --upgrade pip
pip install -r requirements.txt

# Install Playwright Chromium
Color "Installing Playwright Chromium..." Blue
& $PYTHON_BIN -m playwright install chromium

# Ask for Discord token + bot id
while ($true) {
    $DISCORD_TOKEN = Read-Host "Enter your Discord BOT TOKEN"
    $BOT_ID = Read-Host "Enter your Discord BOT ID (numeric)"

    Color "You entered:" Magenta
    Write-Host ("TOKEN: " + $DISCORD_TOKEN.Substring(0,6) + "... (hidden)")
    Write-Host "BOT ID: $BOT_ID"

    if ($BOT_ID -notmatch '^\d{17,20}$') {
        Color "BOT ID looks invalid (must be 17–20 digits)." Red
        continue
    }

    $confirm = Read-Host "Is this correct? (y/n)"
    if ($confirm -match '^[Yy]$') { break }
}

# Create .env
@"
DISCORD_TOKEN=$DISCORD_TOKEN
BOT_ID=$BOT_ID
"@ | Out-File -Encoding utf8 .env

Color ".env created." Green
Start-Sleep -Milliseconds 300

# Setup persistent context
Color "Creating persistent storage folder..." Blue
New-Item -ItemType Directory -Path "playwright_data" -Force | Out-Null

# Open Chromium for Gemini login
Color "Now we will open Chromium for Gemini login." Cyan
Color "Log in with your Google account, then close the browser window." Yellow

$choice = Read-Host "Open Chromium now? (y/n)"
if ($choice -match '^[Yy]$') {
$pythonCode = @"
from playwright.sync_api import sync_playwright
import os

os.makedirs("playwright_data", exist_ok=True)

with sync_playwright() as p:
    print("Opening persistent Chromium...")
    context = p.chromium.launch_persistent_context(
        user_data_dir="playwright_data",
        headless=False
    )
    page = context.new_page()
    page.goto("https://gemini.google.com/")
    print("Log in, then close the window to continue.")
    # keep browser alive until user closes it manually
    try:
        context.wait_for_event("close")
    except:
        pass
"@
    & $PYTHON_BIN -c $pythonCode
}

Color "Gemini login complete." Green
Start-Sleep -Milliseconds 400

Color "Starting VITO..." Green
& $PYTHON_BIN main.py
