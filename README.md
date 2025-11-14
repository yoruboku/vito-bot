# **AIDC-Bot (Zom Bot)**  
### AI-powered Discord assistant using Gemini + Playwright automation  
Created by **yoruboku**  
Contact: **omenboku@gmail.com**

![Logo](logo.png)

---

## 🌌 Overview

AIDC-Bot (codename **Zom**) is a Discord bot that sends user prompts to **Google Gemini** using a real automated browser powered by **Playwright**, waits for the entire response to finish, and then replies cleanly back into Discord.

It supports normal chatting, creating new chats, and fully isolating each user’s Gemini session.  
Designed to be fast, stable, and easy for anyone to host.

---

## ⚠️ Legal & Service Notice

- This project automates **Gemini’s public web interface**, which Google may update at any time.  
- If the UI changes, selectors might break and require updates.  
- This project has **no affiliation** with Google or Discord.  
- You must comply with Google’s ToS, Discord’s bot rules, and all applicable laws.  
- Do not use this bot for spam, abuse, or harmful automation.

---

# 📁 Project Structure

```
├── zom_bot.py
├── requirements.txt
├── install.sh
├── install.ps1
├── .env.example
├── .gitignore
└── README.md
```

---

# 🎯 Features

- Works with Google Gemini through real browser automation  
- Replies **only after Gemini finishes generating fully**  
- Commands for normal prompts and fresh chat resets  
- Automatic queue system (no overlapping responses)  
- Fully cross-platform installer (Windows, macOS, Linux, Termux)  
- Easy `.env` configuration  
- No personal data stored in the repo  
- Works with Playwright Chromium (headless or visible)

---

# 🧪 Requirements

- Python **3.9+**  
- Discord Bot Token  
- Basic terminal or PowerShell access  

---

# 🚀 Discord Bot Setup (new UI)

### 1. Open Developer Portal  
https://discord.com/developers/applications

### 2. Create new application  
**New Application → Name it → Create**

### 3. Add a bot  
Left panel → **Bot → Add Bot**

### 4. Enable intents  
Under *Privileged Gateway Intents* enable:

- **Message Content Intent**

### 5. Get your bot token  
Bot → Token → **Reset Token → Copy**

Place it inside `.env`.

### 6. Invite bot to your server  
Go to:

**OAuth2 → URL Generator**

Enable:  
**Scopes**
- `bot`

**Bot Permissions**
- `Send Messages`  
- `Read Message History`

Open the generated URL → Add to server.

---

# 🔧 Installation

Clone the repo:
```
git clone https://github.com/yoruboku/aidc-bot
cd aidc-bot
```

Create your `.env`:
```
cp .env.example .env
```

Add your bot token:
```
DISCORD_BOT_TOKEN=YOUR_TOKEN_HERE
```

---

# 🪟 Windows Installation

### Automatic:
```
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

### Manual:
```
python -m venv venv
venv\Scriptsctivate
pip install -r requirements.txt
playwright install chromium
python zom_bot.py
```

---

# 🐧 Linux (Ubuntu, Debian, Fedora, Arch, etc.)

### Automatic:
```
chmod +x install.sh
./install.sh
```

### Manual:
```
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
playwright install chromium
python3 zom_bot.py
```

---

# 📱 Termux (Android)

```
pkg update
pkg install python git chromium
git clone https://github.com/yoruboku/aidc-bot
cd aidc-bot
chmod +x install.sh
./install.sh
python zom_bot.py
```

---

# 🍎 macOS

```
brew install python
git clone https://github.com/yoruboku/aidc-bot
cd aidc-bot
chmod +x install.sh
./install.sh
python3 zom_bot.py
```

---

# 🤖 Discord Commands

### Ask something:
```
@zom ask "your question here"
```

### Start a fresh Gemini chat:
```
@zom newchat "your question here"
```

The bot then:

- Sends the message to Gemini  
- Waits for complete generation  
- Sends the full reply back to Discord  
- Keeps session open for the next message  

---

# ❓ Troubleshooting

### Bot not responding?
Check for:

- Incorrect token  
- Missing message content intent  
- Missing permissions  
- Playwright not installed  

### Gemini UI changed?
Selectors may need updating inside `zom_bot.py`.

---

# 🤝 Contributing

Pull requests and improvements are welcome.

---

# 🧘 Credits

Created by **yoruboku**  
Contact: **omenboku@gmail.com**

---

# 📄 License

This project is released under the **MIT License**.
