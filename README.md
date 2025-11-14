BOKU AIDC - Discord AI Bot

💬 Overview

BOKU AIDC is a self-hosted Discord AI bot powered by Google Gemini. It uses Playwright to automate a real browser, allowing it to interact with the Gemini web interface directly.

It automatically answers questions in your server when mentioned (e.g., @zom), supports new chat sessions, maintains separate chat contexts for each user, and intelligently handles common errors like rate limits.

⚠️ Disclaimer: This bot interacts with the Gemini web UI, which can change at any time and potentially break the bot's functionality. Use responsibly and in accordance with Google's and Discord's Terms of Service.

✨ Features

✨ Mention-Based: Responds only when mentioned (@zom).

🔄 Per-User Sessions: Every user has their own independent, persistent chat session with Gemini.

🆕 Chat Reset: Supports a newchat command to clear a user's session and start fresh.

🚦 Request Queue: All prompts are processed one-by-one in a queue to prevent browser conflicts and manage rate limits.

🍪 Persistent Login: Automatically saves and reuses your Google login session, so you only need to log in once during setup.

🚨 Error Handling: Detects and reports common Gemini errors like rate limits or "Try again" prompts.

🖥️ Cross-Platform Installer: Includes styled, automated installer scripts for Windows, Linux, and macOS.

⚙️ How It Works

This bot is not an "official" API integration. It works by:

Launching a Browser: Using Playwright, the bot launches a headless Chromium browser in the background.

Persistent Context: It saves your Google login cookies and session data in the playwright_data directory.

Scraping: When you mention the bot, it opens a page (or finds the existing page for your user ID), types your prompt into the text box, submits it, and waits for the response to appear.

Returning the Answer: It scrapes the text from the final response block and sends it back to your Discord channel.

📋 Requirements

🐍 Python 3.11+

🔑 Discord Bot Token & Application ID

☁️ Git

🌐 Internet access (for Gemini login and bot operation)

🚀 Installation & Setup

Follow these steps in order to get your bot running.

Step 1: Get Discord Credentials (Prerequisite)

You must do this before running the installer.

Go to the Discord Developer Portal.

Click "New Application" and give it a name (e.g., "BOKU AIDC").

Go to the "Bot" tab.

Under "Privileged Gateway Intents", enable the MESSAGE CONTENT INTENT.

Click "Reset Token" to get your Bot Token (save this securely).

Go to the "OAuth2" > "General" tab. Copy your APPLICATION ID (this is your BOT_ID).

Go to the "OAuth2" > "URL Generator" tab.

Select the following scopes:

bot

applications.commands

Select the following Bot Permissions:

Send Messages

Read Message History

View Channels

Copy the Generated URL at the bottom, paste it into your browser, and invite the bot to your server.

Step 2: Clone the Repository

git clone [https://github.com/yoruboku/aidc-bot.git](https://github.com/yoruboku/aidc-bot.git)
cd aidc-bot


Step 3: Run the Installer

The installer automates everything. It checks if you're already set up. If not, it will guide you through the full installation. If you are set up, it just updates and starts the bot.

On Linux / macOS / Termux:

# Make the script executable
chmod +x unified_install.sh

# Run the installer
./unified_install.sh


On Windows (using PowerShell):

# You may need to update your execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process

# Run the installer
.\install.ps1


First-Time Setup:
The installer will:

Create a Python virtual environment (venv).

Install all required dependencies from requirements.txt.

Prompt you for the DISCORD_TOKEN and BOT_ID (Application ID) you got in Step 1.

Create your .env file with these credentials.

Launch a Chromium window. You must log in to gemini.google.com with your Google account.

After you are logged in, return to the terminal, type done, and press Enter.

The script will save your session and automatically start the bot.

🎮 How to Use

Once the bot is running and in your server, you can interact with it.

Ask a Question:
Mention the bot followed by your prompt.

@zom What is the capital of Japan?


Start a New Chat:
To clear your conversation history with Gemini and start fresh, use the newchat command.

@zom newchat


Start a New Chat with a Prompt:
You can also provide a prompt immediately after starting a new chat.

@zom newchat Tell me a story about a robot.


🔧 Managing the Bot

Updating

To pull the latest code from GitHub and update your dependencies:

On Linux / macOS / Termux:

./update.sh


On Windows (using PowerShell):

.\update.ps1


Running Manually

If you stop the bot and want to restart it after installation:

On Linux / macOS:

# Activate the virtual environment
source venv/bin/activate

# Run the bot
python3 zom_bot.py


On Windows (using PowerShell):

# Activate the virtual environment
.\venv\Scripts\Activate.ps1

# Run the bot
python zom_bot.py


📄 License & Contact

This project is licensed under the MIT License.
Copyright (c) 2025 Yoruboku

Contact: omenboku@gmail.com
