#!/usr/bin/env bash
set -euo pipefail

# Activate the virtual environment
if [ -f "venv/bin/activate" ]; then
  source venv/bin/activate
else
  echo "Virtual environment not found. Please run install.sh first."
  exit 1
fi

PY=""
for p in python3 python py python; do
  if command -v "$p" >/dev/null 2>&1; then PY="$p"; break; fi
done
[ -z "$PY" ] && { echo "Python not found"; exit 1; }
mkdir -p playwright_data
$PY - <<'PY'
from playwright.sync_api import sync_playwright
import os
os.makedirs("playwright_data", exist_ok=True)
with sync_playwright() as p:
    context = p.chromium.launch_persistent_context(user_data_dir="playwright_data", headless=False)
    page = context.new_page()
    page.goto("https://gemini.google.com/")
    print("Open. Close window to exit.")
    context.wait_for_event("close")
PY
