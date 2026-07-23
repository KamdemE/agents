import os
import subprocess
import time
import requests
import logging

# Configuration
TOKEN = os.getenv("TELEGRAM_UBUNTU_TOKEN")
ALLOWED_CHAT_IDS = os.getenv("CHAT_ID", "").split(",")
KSH_PATH = os.path.expandvars("$HOME/.agents/skills/k-ubuntu/scripts/ksh.sh")

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger("ubuntu_bot")

if not TOKEN:
    logger.error("❌ TELEGRAM_UBUNTU_TOKEN is missing!")
    exit(1)

def run_command(cmd_args):
    """Executes a command and returns formatted output."""
    try:
        # We ensure it's executed as ksh
        full_cmd = ["bash", KSH_PATH] + cmd_args
        result = subprocess.run(full_cmd, capture_output=True, text=True, timeout=300)
        output = result.stdout.strip() or result.stderr.strip() or "Success (No output)."
        return f"```\n{output[:3500]}\n```" # Markdown code block + limit for Telegram
    except Exception as e:
        return f"❌ Error: {str(e)}"

def poll_updates():
    offset = 0
    logger.info("🚀 Ubuntu Bot Listener (ksh) started...")
    while True:
        try:
            url = f"https://api.telegram.org/bot{TOKEN}/getUpdates"
            params = {"timeout": 30, "offset": offset}
            response = requests.get(url, params=params, timeout=35)
            response.raise_for_status()
            updates = response.json().get("result", [])
            
            for update in updates:
                msg = update.get("message", {})
                chat_id = str(msg.get("chat", {}).get("id"))
                text = msg.get("text", "").strip()
                offset = update["update_id"] + 1

                if not text.startswith("/"):
                    continue

                if chat_id not in ALLOWED_CHAT_IDS:
                    logger.warning(f"🚫 Unauthorized attempt from {chat_id}")
                    continue

                cmd = text.split()[0].replace("@k_ubuntu_bot", "").lower()
                logger.info(f"📥 Received {cmd} from {chat_id}")

                if cmd == "/status":
                    reply = run_command(["status"])
                elif cmd == "/clean":
                    reply = "🧹 Starting Ubuntu cleanup..."
                    requests.post(f"https://api.telegram.org/bot{TOKEN}/sendMessage", json={"chat_id": chat_id, "text": reply})
                    reply = run_command(["clean"])
                elif cmd == "/backup":
                    reply = "💾 Starting Ubuntu Workstation Backup..."
                    requests.post(f"https://api.telegram.org/bot{TOKEN}/sendMessage", json={"chat_id": chat_id, "text": reply})
                    reply = run_command(["backup"])
                elif cmd == "/vault":
                    reply = run_command(["bw", "status"])
                else:
                    reply = "❓ Unknown command. Available: /status, /clean, /backup, /vault"

                requests.post(f"https://api.telegram.org/bot{TOKEN}/sendMessage", json={
                    "chat_id": chat_id, 
                    "text": reply, 
                    "parse_mode": "Markdown"
                })

        except Exception as e:
            logger.error(f"⚠️ Polling error: {e}")
            time.sleep(10)

if __name__ == "__main__":
    poll_updates()
