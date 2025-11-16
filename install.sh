#!/usr/bin/env bash
set -euo pipefail

# Colors
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
MAGENTA="\033[1;35m"
CYAN="\033[1;36m"
RED="\033[1;31m"
RESET="\033[0m"

BANNER() {
  echo -e "${CYAN}"
  echo "====================================================="
  echo "      V I T O   —   A I  D I S C O R D   B O T"
  echo "====================================================="
  echo -e "${RESET}"
}

confirm_yesno() {
  while true; do
    read -rp "$1 [y/n]: " yn
    case "${yn,,}" in
      y|yes) return 0;;
      n|no) return 1;;
      *) echo "Please answer y or n.";;
    esac
  done
}

# Pick python binary
PYTHON_BIN=""
for p in python3 python py python; do
  if command -v "$p" >/dev/null 2>&1; then
    PYTHON_BIN="$p"
    break
  fi
done

BANNER

if [ -z "$PYTHON_BIN" ]; then
  echo -e "${RED}Python 3 not found. Install Python 3.9+ and re-run.${RESET}"
  exit 1
fi

echo -e "${GREEN}Using Python: $PYTHON_BIN${RESET}"

# If installed already
if [ -d "venv" ] && [ -f ".env" ]; then
  echo -e "${YELLOW}Existing installation detected. Update or start?${RESET}"
  if confirm_yesno "Update dependencies and start VITO now?"; then
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
    $PYTHON_BIN -m playwright install chromium
    exec $PYTHON_BIN main.py
  else
    echo "Exiting."
    exit 0
  fi
fi

# Create venv
echo -e "${BLUE}Creating virtual environment...${RESET}"
$PYTHON_BIN -m venv venv
source venv/bin/activate

echo -e "${BLUE}Installing dependencies...${RESET}"
pip install --upgrade pip
pip install -r requirements.txt

echo -e "${BLUE}Installing Playwright Chromium...${RESET}"
$PYTHON_BIN -m playwright install chromium

# Discord token / bot id
while true; do
  read -rp "Enter your Discord Bot TOKEN: " DISCORD_TOKEN
  read -rp "Enter your Discord BOT ID (numeric): " BOT_ID
  echo
  echo -e "${MAGENTA}You entered:${RESET}"
  if [ "${#DISCORD_TOKEN}" -ge 8 ]; then
    echo "DISCORD_TOKEN: ${DISCORD_TOKEN:0:6}... (hidden)"
  else
    echo "DISCORD_TOKEN: (too short; double-check)"
  fi
  echo "BOT_ID: $BOT_ID"
  if confirm_yesno "Is this correct?"; then
    break
  fi
done

# Owner configuration menu
echo
echo "Owner configuration:"
echo "1) Default — only built-in priority owner 'yoruboku' will have absolute priority"
echo "2) Set Owner A (single additional owner username)"
echo "3) Set Owner A + Owner B (multiple owners, comma-separated)"
read -rp "Choose an option [1/2/3]: " OWNER_CHOICE

OWNER_MAIN=""
OWNER_EXTRA=""

if [ "$OWNER_CHOICE" = "2" ]; then
  read -rp "Enter Owner A global username (exact, e.g. yoruboku): " OWNER_MAIN
elif [ "$OWNER_CHOICE" = "3" ]; then
  read -rp "Enter Owner A global username: " OWNER_MAIN
  read -rp "Enter additional Owner B usernames (comma separated): " OWNER_EXTRA
fi

# Confirm owner inputs
echo
echo -e "${MAGENTA}Owner settings:${RESET}"
if [ -z "$OWNER_MAIN" ] && [ -z "$OWNER_EXTRA" ]; then
  echo "Using default: priority owner 'yoruboku' only."
else
  echo "OWNER_MAIN: $OWNER_MAIN"
  echo "OWNER_EXTRA: $OWNER_EXTRA"
fi
if ! confirm_yesno "Save these settings to .env?"; then
  echo "Aborting as requested."
  exit 1
fi

# Write .env
cat > .env <<EOF
DISCORD_TOKEN=$DISCORD_TOKEN
BOT_ID=$BOT_ID
OWNER_MAIN=$OWNER_MAIN
OWNER_EXTRA=$OWNER_EXTRA
PRIORITY_OWNER=yoruboku
EOF
chmod 600 .env
echo -e "${GREEN}.env created.${RESET}"

# Create playwright_data and open persistent browser for Gemini login
mkdir -p playwright_data
echo -e "${BLUE}Next: open Chromium to log in to Gemini.${RESET}"
echo -e "${YELLOW}When done logging in, type 'done' in this terminal to continue.${RESET}"

if confirm_yesno "Open Chromium now to log in?"; then
  $PYTHON_BIN - <<PYCODE
from playwright.sync_api import sync_playwright
import os
os.makedirs("playwright_data", exist_ok=True)
with sync_playwright() as p:
    context = p.chromium.launch_persistent_context(user_data_dir="playwright_data", headless=False)
    page = context.new_page()
    page.goto("https://gemini.google.com/")
    print("Log in to Gemini in the opened browser. Type 'done' here when finished.")
    try:
        while True:
            if input().strip().lower() == "done":
                break
    except KeyboardInterrupt:
        pass
    context.storage_state(path="playwright_data/state.json")
    context.close()
PYCODE
else
  echo "You can log in later with ./open_gemini.sh"
  if ! confirm_yesno "Continue without logging in now? (you'll need to log in before running the bot)"; then
    echo "Exiting."
    exit 0
  fi
fi

echo -e "${GREEN}Login saved. Starting VITO...${RESET}"
exec $PYTHON_BIN main.py
