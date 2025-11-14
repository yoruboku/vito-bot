#!/bin/bash
echo "=== ZOM BOT INSTALLER ==="

if [ ! -f ".env" ]; then
    echo "Enter your Discord Token:"
    read TOKEN
    echo "Enter your Bot ID:"
    read BOTID

    echo "DISCORD_TOKEN=$TOKEN" > .env
    echo "BOT_ID=$BOTID" >> .env
fi

echo "Creating virtual environment..."
python3 -m venv venv

echo "Installing dependencies..."
source venv/bin/activate
pip install -r requirements.txt

echo "Installing Playwright browsers..."
playwright install chromium

echo "Done!"
echo "Run the bot using:"
echo "source venv/bin/activate && python zom_bot.py"
