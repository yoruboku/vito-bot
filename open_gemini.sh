#!/usr/bin/env bash
set -euo pipefail
PY=""
for p in python3 python py python; do
  if command -v "$p" >/dev/null 2>&1; then PY="$p"; break; fi
done
[ -z "$PY" ] && { echo "Python not found"; exit 1; }

# Activate the virtual environment
source venv/bin/activate

mkdir -p playwright_data
$PY - <<'PY'
from playwright.sync_api import sync_playwright
import os

os.makedirs("playwright_data", exist_ok=True)

p = sync_playwright().start()

context = p.chromium.launch_persistent_context(
    "playwright_data",
    headless=False,
)
page = context.new_page()
page.goto("https://gemini.google.com/")

print("Open. When you are done, close the browser window to exit.")
# Wait for the user to close the browser context...
context.wait_for_event("close")

# ...then stop the playwright process.
p.stop()
PY
