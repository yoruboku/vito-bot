Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Banner {
    Clear-Host
    Write-Host "██╗   ██╗██╗████████╗ ██████╗ " -ForegroundColor Magenta
    Write-Host "██║   ██║██║╚══██╔══╝██╔═══██╗" -ForegroundColor Magenta
    Write-Host "██║   ██║██║   ██║   ██║   ██║" -ForegroundColor Magenta
    Write-Host "██║   ██║██║   ██║   ██║   ██║" -ForegroundColor Magenta
    Write-Host "╚██████╔╝██║   ██║   ╚██████╔╝" -ForegroundColor Magenta
    Write-Host " ╚═════╝ ╚═╝   ╚═╝    ╚═════╝ " -ForegroundColor Magenta
    Write-Host "         V I T O   I N S T A L L E R" -ForegroundColor Cyan
    Write-Host ""
}

function Detect-Python {
    $py = Get-Command python, python3, py -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $py) {
        Write-Host "Python 3 not found." -ForegroundColor Red
        exit 1
    }
    $script:PY = $py.Source
}

function Chmod-Helpers {
    # Windows equivalent is just ensuring scripts exist; nothing to chmod
    # Kept for symmetry with Linux.
    return
}

function Install-Or-Reinstall {
    Banner
    Detect-Python

    Write-Host "[*] Creating virtual env and installing dependencies..." -ForegroundColor Cyan
    & $PY -m venv venv
    & venv\Scripts\Activate.ps1
    pip install --upgrade pip | Out-Null
    pip install -r requirements.txt | Out-Null
    & $PY -m playwright install chromium

    # credentials with confirm loop
    while ($true) {
        Write-Host "`nDiscord credentials:" -ForegroundColor Cyan
        $token = Read-Host "Bot Token"
        $bid = Read-Host "Application/Bot ID"

        Write-Host "`nYou entered:" -ForegroundColor Yellow
        Write-Host ("  TOKEN: {0}..." -f ($token.Substring(0, [Math]::Min(8, $token.Length))))
        Write-Host ("  ID   : {0}" -f $bid)
        $ok = Read-Host "Is this correct? (y/n)"
        if ($ok -match '^[Yy]') { break }
    }

    Write-Host "`nOpening Chromium. Log into Gemini, then close the browser..." -ForegroundColor Cyan

    $code = @"
from playwright.sync_api import sync_playwright
import os
os.makedirs('playwright_data', exist_ok=True)
with sync_playwright() as p:
    ctx = p.chromium.launch_persistent_context('playwright_data', headless=False)
    page = ctx.new_page()
    page.goto('https://gemini.google.com')
    print('Log in to Gemini in the opened browser.')
    print('When login is complete, close the browser window.')
    ctx.wait_for_event('close', timeout=900000)
"@

    & $PY -c $code

    Write-Host "Gemini login saved." -ForegroundColor Green

    # Owner config
    Write-Host "`nOwner configuration:" -ForegroundColor Cyan
    Write-Host "  1) Default (only 'yoruboku' has special priority)"
    Write-Host "  2) Set one extra owner username"
    $choice = Read-Host "Select [1-2] (Enter = 1)"
    if ($choice -eq "") { $choice = "1" }

    $ownerUsername = ""
    if ($choice -eq "2") {
        $ownerUsername = Read-Host "Owner's Discord username (global username)"
    }

    @"
DISCORD_TOKEN=$token
BOT_ID=$bid
OWNER_USERNAME=$ownerUsername
"@ | Out-File -Encoding UTF8 .env

    Chmod-Helpers

    Write-Host "`nInstallation complete. Starting VITO..." -ForegroundColor Green
    & $PY main.py
}

function Start-Vito {
    Detect-Python
    if (-not (Test-Path "venv") -or -not (Test-Path ".env")) {
        Write-Host "No installation detected. Run Install/Reinstall first." -ForegroundColor Red
        exit 1
    }
    & venv\Scripts\Activate.ps1
    & $PY main.py
}

# ---- main menu ----
Banner
Write-Host "1) Install / Reinstall"
Write-Host "2) Start VITO"
$sel = Read-Host "Select"

switch ($sel) {
    "1" { Install-Or-Reinstall }
    "2" { Start-Vito }
    default { Write-Host "Invalid choice." -ForegroundColor Red }
}
