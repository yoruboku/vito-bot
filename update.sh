#!/usr/bin/env bash
set -euo pipefail
if [ -d ".git" ]; then git pull --rebase || true; fi
if [ -d "venv" ]; then
  source venv/bin/activate
  pip install --upgrade pip
  pip install -r requirements.txt
  python -m playwright install chromium
  python main.py
else
  echo "No venv found. Run install.sh first."
  exit 1
fi
