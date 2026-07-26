#!/usr/bin/env python3
"""tg-bot.py — Telegram bot for Ubuntu workstation commands.
Listens for commands via polling and dispatches via ksh.
Source: .agents/skills/k-ubuntu/scripts/tg-bot.py
"""

import logging
import os
import subprocess
import sys
import time

import requests

TOKEN = os.getenv("TELEGRAM_UBUNTU_TOKEN")
ALLOWED_CHAT_IDS = os.getenv("TELEGRAM_CHAT_ID", "").split(",")
KSH_PATH = os.path.expandvars("$HOME/.agents/skills/k-ubuntu/scripts/ksh.sh")

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger("tg-bot")

if not TOKEN:
    logger.error("TELEGRAM_UBUNTU_TOKEN is missing!")
    sys.exit(1)

BASE = f"https://api.telegram.org/bot{TOKEN}"


def run_ksh(args):
    try:
        full = ["bash", KSH_PATH] + args
        r = subprocess.run(
            full, capture_output=True, text=True, timeout=300, check=False
        )
        return r.stdout.strip() or r.stderr.strip() or "Done."
    except subprocess.TimeoutExpired:
        return "Command timed out."


def send(chat_id, text):
    try:
        requests.post(
            f"{BASE}/sendMessage", json={"chat_id": chat_id, "text": text}, timeout=10
        )
    except requests.exceptions.RequestException as e:
        logger.error(f"Send failed: {e}")


def handle(cmd, args):
    mapping = {
        "clean": ["clean"] + args,
        "status": ["status"],
        "backup": ["backup"] + (args if args else ["--preview"]),
        "help": [],
    }
    return run_ksh(mapping.get(cmd, ["help"]))


def poll():
    offset = 0
    while True:
        try:
            r = requests.get(
                f"{BASE}/getUpdates",
                params={"timeout": 30, "offset": offset},
                timeout=35,
            )
            for u in r.json().get("result", []):
                offset = u["update_id"] + 1
                msg = u.get("message", {})
                chat_id = str(msg.get("chat", {}).get("id", ""))
                if chat_id not in ALLOWED_CHAT_IDS:
                    send(chat_id, "Unauthorized.")
                    continue
                text = msg.get("text", "").strip()
                if not text.startswith("/"):
                    continue
                parts = text[1:].split()
                cmd, args = parts[0], parts[1:]
                logger.info(f"Command: /{cmd} from {chat_id}")
                output = handle(cmd, args)
                send(chat_id, output[:4000])
        except (requests.exceptions.RequestException, OSError) as e:
            logger.error(f"Polling error: {e}")
            time.sleep(30)


if __name__ == "__main__":
    poll()
