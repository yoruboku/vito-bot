#!/usr/bin/env bash
set -euo pipefail

# VITO - Neon Arch-style installer

GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RED="\033[1;31m"
MAGENTA="\033[1;35m"
CYAN="\033[1;36m"
RESET="\033[0m"

banner() {
  echo -e "${MAGENTA}"
  echo "██╗   ██╗██╗████████╗ ██████╗ "
  echo "██║   ██║██║╚══██╔══╝██╔═══██╗"
  echo "██║   ██║██║   ██║   ██║   ██║"
  echo "██║   ██║██║   ██║   ██║   ██║"
  echo "╚██████╔╝██║   ██║   ╚██████╔╝"
  echo " ╚═════╝ ╚═╝   ╚═╝    ╚═════╝ "
  echo -e "${CYAN}         VITO · AI CORE INSTALLER${RESET}"
  echo
}

# -------- low-level TUI (arrow menu) --------

menu_choice() {
  # usage: menu_choice "title" "opt1" "opt2" "opt3" ...
  local title="$1"; shift
  local options=("$@")
  local selected=0
  local key

  while true; do
    clear
    banner
    echo -e "${CYAN}${title}${RESET}"
    echo

    for i in "${!options[@]}"; do
      if [ "$i" -eq "$selected" ]; then
        # highlighted line
        echo -e "${BLUE}> ${options[$i]}${RESET}"
      else
        echo "  ${options[$i]}"
      fi
    done

    # read one key (arrow or enter)
    # save terminal state
    old_stty_cfg=$(stty -g)
    stty -icanon -echo min 1 time 0
    IFS= read -rsn1 key 2>/dev/null || true
    # restore
    stty "$old_stty_cfg"

    # handle arrows / enter
    if [[ "$key" == $'\x1b' ]]; then
      # possible arrow key, read the rest
      old_stty_cfg=$(stty -g)
      stty -icanon -echo min 2 time 0
      IFS= read -rsn2 key2 2>/dev/null || true
      stty "$old_stty_cfg"
      key+="$key2"
      case "$key" in
        $'\x1b[A') # up
          ((selected--))
          if [ "$selected" -lt 0 ]; then
            selected=$((${#options[@]} - 1))
          fi
          ;;
        $'\x1b[B') # down
          ((selected++))
          if [ "$selected" -ge "${#options[@]}" ]; then
            selected=0
          fi
          ;;
      esac
    elif [[ "$key" == "" || "$key" == $'\n' || "$key" == $'\r' ]]; then
      # enter
      echo "$selected"
      return
    fi
  done
}

# -------- Python detection --------

banner
echo -e "${CYAN}[*] Scanning environment...${RESET}"

PYTHON_BIN=""
for p in python3 python py; do
  if command -v "$p" >/dev/null 2>&1; then
    PYTHON_BIN="$p"
    break
  fi
done

if [ -z "$PYTHON_BIN" ]; then
  echo -e "${RED}[!] Python 3.11+ not found. Install Python first.${RESET}"
  exit 1
fi

echo -e "${GREEN}[✓] Using Python:${RESET} $PYTHON_BIN"

# -------- helper: chmod scripts --------

set_exec_perms() {
  echo -e "${CYAN}[*] Setting execute bit on helper scripts...${RESET}"
  for f in install.sh update.sh open_gemini.sh; do
    if [ -f "$f" ]; then
      chmod +x "$f"
      echo -e "   ${GREEN}[✓]${RESET} $f"
    fi
  done
}

# -------- run bot --------

run_bot() {
  echo -e "${CYAN}[*] Starting VITO...${RESET}"
  # shellcheck disable=SC1091
  source venv/bin/activate
  "$PYTHON_BIN" main.py
}

# -------- install path --------

do_install() {
  clear
  banner
  echo -e "${BLUE}▶ STEP 1: Virtual environment${RESET}"
  "$PYTHON_BIN" -m venv venv
  # shellcheck disable=SC1091
  source venv/bin/activate

  echo -e "${BLUE}▶ STEP 2: Python dependencies${RESET}"
  pip install --upgrade pip
  pip install -r requirements.txt

  echo -e "${BLUE}▶ STEP 3: Playwright Chromium${RESET}"
  "$PYTHON_BIN" -m playwright install chromium

  echo -e "${BLUE}▶ STEP 4: Discord credentials${RESET}"
  local DISCORD_TOKEN BOT_ID
  while true; do
    read -rp "Discord BOT TOKEN: " DISCORD_TOKEN
    read -rp "Discord BOT ID (numeric): " BOT_ID

    if ! [[ "$BOT_ID" =~ ^[0-9]+$ ]]; then
      echo -e "${RED}[!] BOT ID must be numeric.${RESET}"
      continue
    fi

    echo -e "${MAGENTA}You entered:${RESET}"
    echo "  TOKEN: ${DISCORD_TOKEN:0:8}..."
    echo "  BOT ID: $BOT_ID"
    read -rp "Is this correct? (y/n): " ok
    [[ "$ok" == [Yy]* ]] && break
  done

  echo -e "${BLUE}▶ STEP 5: Owner configuration${RESET}"
  echo
  echo "  1) Default (only priority 'yoruboku')"
  echo "  2) Set main owner + extra owners"
  echo "  3) No extra owners"
  read -rp "Select [1-3] (Enter = 1): " ow_choice
  ow_choice=${ow_choice:-1}

  local OWNER_MAIN OWNER_EXTRA
  OWNER_MAIN=""
  OWNER_EXTRA=""

  case "$ow_choice" in
    2)
      read -rp "Main owner username (global): " OWNER_MAIN
      echo "Enter extra owners (comma-separated, optional):"
      read -rp "Extra owners: " OWNER_EXTRA
      ;;
    3)
      OWNER_MAIN=""
      OWNER_EXTRA=""
      ;;
    *)
      OWNER_MAIN=""
      OWNER_EXTRA=""
      ;;
  esac

  echo -e "${MAGENTA}Final owners:${RESET} MAIN='${OWNER_MAIN:-<none>}' EXTRA='${OWNER_EXTRA:-<none>}'"

  echo -e "${BLUE}▶ STEP 6: Writing .env${RESET}"
  cat > .env <<EOF
DISCORD_TOKEN=$DISCORD_TOKEN
BOT_ID=$BOT_ID
OWNER_MAIN=$OWNER_MAIN
OWNER_EXTRA=$OWNER_EXTRA
PRIORITY_OWNER=yoruboku
EOF
  chmod 600 .env
  echo -e "${GREEN}[✓] .env created${RESET}"

  set_exec_perms

  echo -e "${BLUE}▶ STEP 7: Gemini login${RESET}"
  echo -e "${CYAN}[*] Launching Chromium persistent profile...${RESET}"
  "$PYTHON_BIN" << 'PYCODE'
from playwright.sync_api import sync_playwright
import os

os.makedirs("playwright_data", exist_ok=True)

with sync_playwright() as p:
    ctx = p.chromium.launch_persistent_context("playwright_data", headless=False)
    page = ctx.new_page()
    page.goto("https://gemini.google.com")
    print("\n────────────────────────────────────────────")
    print("  Log in to GEMINI in the opened browser.")
    print("  Take your time. 2FA, password, everything.")
    print("  When completely logged in, close the browser.")
    print("────────────────────────────────────────────\n")
    # big timeout (15 minutes) to avoid premature close
    ctx.wait_for_event("close", timeout=900000)
PYCODE

  echo -e "${GREEN}[✓] Gemini login stored${RESET}"
  run_bot
}

# -------- main flow --------

HAS_INSTALL=0
if [[ -d "venv" && -f ".env" ]]; then
  HAS_INSTALL=1
fi

if [ "$HAS_INSTALL" -eq 1 ]; then
  # menu: Run / Install / Exit
  idx=$(menu_choice "Select action:" "Run VITO" "New install / reinstall" "Exit")
  case "$idx" in
    0) run_bot ;;
    1) do_install ;;
    2) echo -e "${YELLOW}Exiting VITO installer.${RESET}"; exit 0 ;;
    *) run_bot ;;
  esac
else
  echo -e "${YELLOW}[!] No existing installation detected. Running full install...${RESET}"
  do_install
fi
