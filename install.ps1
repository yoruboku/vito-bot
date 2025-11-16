$ErrorActionPreference = "Stop"

function Banner {
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "          V I T O   I N S T A L L E R       " -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
}
Banner

# Python detection
$py = (Get-Command python, python3, py -ErrorAction SilentlyContinue | Select-Object -First 1).Source
if (-not $py) { Write-Host "Python not found. Install Python 3.11+" -ForegroundColor Red; exit }

Write-Host "Using Python: $py" -ForegroundColor Green

# Quick-run if installed
if (Test-Path "venv" -and Test-Path ".env") {
    Write-Host "Updating dependencies..." -ForegroundColor Yellow
    & $py -m pip install --upgrade pip
    & $py -m pip install -r requirements.txt
    & $py -m playwright install chromium
    Write-Host "Starting VITO..." -ForegroundColor Green
    & $py main.py
    exit
}

# New install
Write-Host "Creating virtual environment..." -ForegroundColor Blue
& $py -m venv venv
& "venv\Scripts\Activate.ps1"

Write-Host "Installing dependencies..." -ForegroundColor Blue
pip install --upgrade pip
pip install -r requirements.txt
& $py -m playwright install chromium

# Credentials
do {
    $token = Read-Host "Enter BOT TOKEN"
    $id = Read-Host "Enter BOT ID (numbers only)"
    Write-Host "TOKEN: $($token.Substring(0,8))...  BOT: $id" -ForegroundColor Magenta
    $ok = Read-Host "Is this correct? (y/n)"
} until ($ok -match "^[Yy]$")

# Owner mode
Write-Host "`nOwner Selection" -ForegroundColor Cyan
Write-Host "1) Default (only 'yoruboku')"
Write-Host "2) Custom Owners"
$choice = Read-Host ">"

$owners = ""
if ($choice -eq "2") {
    while ($true) {
        $n = Read-Host "Enter owner username"
        if ($owners -eq "") { $owners = $n } else { $owners += ",$n" }
        $m = Read-Host "Add another? (y/n)"
        if ($m -notmatch "^[Yy]$") { break }
    }
}

# Write .env
Set-Content ".env" "DISCORD_TOKEN=$token`nBOT_ID=$id`nOWNERS=$owners"

# Persistent login
Write-Host "`nLaunching Gemini...`n" -ForegroundColor Cyan

& $py - << 'EOF'
from playwright.sync_api import sync_playwright
import os
os.makedirs("playwright_data", exist_ok=True)
with sync_playwright() as p:
    ctx = p.chromium.launch_persistent_context("playwright_data", headless=False)
    pg = ctx.new_page()
    pg.goto("https://gemini.google.com")
    print("Login in browser, then *close browser* to continue.")
    ctx.wait_for_event("close")
EOF

Write-Host "Starting VITO..." -ForegroundColor Green
& $py main.py
