#!/usr/bin/env bash
set -euo pipefail

GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RESET="\033[0m"

echo -e "${GREEN}Updating repository and dependencies...${RESET}"

if [ -d .git ]; then
  git pull --rebase
else
  echo -e "${YELLOW}Not a git repo; skipping git pull.${RESET}"
fi

if [ -d venv ]; then
  source venv/bin/activate
  pip install --upgrade pip
  pip install -r requirements.txt
  python -m playwright install chromium
  echo -e "${GREEN}Update complete.${RESET}"
  python main.py
else
  echo -e "${YELLOW}No venv found. Run ./unified_install.sh first.${RESET}"
  exit 1
fi
