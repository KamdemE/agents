#!/usr/bin/env zsh
# Deploy Termux sshd persistence + ubuntu SSH block. Run from Ubuntu when ssh s25 works.
# Skill: k-phones — see references/s25-termux-sshd.md

set -euo pipefail

readonly SKILL_ASSETS="${HOME}/.agents/skills/k-phones/assets"
readonly REMOTE='s25'
readonly MARKER='# k-phones sshd autostart'
readonly REMOTE_SNIPPET='.kphones-remote.zsh'
readonly UBUNTU_MARKER='# k-phones ubuntu host'

echo "==> openssh on Termux"
ssh "$REMOTE" 'command -v sshd >/dev/null || pkg install -y openssh'

echo "==> ~/.kphones-remote.zsh (ubuntu alias + sshd autostart)"
{
  cat "${SKILL_ASSETS}/termux-zshrc-snippet.sh"
  echo
  cat "${SKILL_ASSETS}/termux-sshd-autostart.sh"
} | ssh "$REMOTE" "cat > ~/${REMOTE_SNIPPET} && chmod 644 ~/${REMOTE_SNIPPET}"

echo "==> ~/.zshrc hook"
ssh "$REMOTE" "ZSHRC=\$HOME/.zshrc; touch \"\$ZSHRC\"
grep -qF 'kphones-remote.zsh' \"\$ZSHRC\" 2>/dev/null || echo '[[ -f ~/.kphones-remote.zsh ]] && . ~/.kphones-remote.zsh' >> \"\$ZSHRC\""

echo "==> ~/.ssh/config Host ubuntu (Tailscale IP, single block)"
scp "${SKILL_ASSETS}/termux-ssh-ubuntu.conf" "${REMOTE}:.ssh/kphones-ubuntu.conf"
ssh "$REMOTE" 'python3 << "PY"
import re
from pathlib import Path

cfg = Path.home() / ".ssh" / "config"
frag = Path.home() / ".ssh" / "kphones-ubuntu.conf"
marker = "# k-phones ubuntu host"
block = marker + "\n" + frag.read_text().strip() + "\n"
text = cfg.read_text() if cfg.exists() else ""
text = re.sub(r"\n# k-phones ubuntu host\n.*?(?=\nHost |\Z)", "\n", text, flags=re.S)
text = re.sub(r"\nHost ubuntu\n.*?(?=\nHost |\Z)", "\n", text, flags=re.S)
text = re.sub(r"^Host ubuntu\n.*?(?=\nHost |\Z)", "\n", text, flags=re.S)
cfg.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
cfg.write_text(text.strip() + "\n\n" + block)
print("Host ubuntu blocks:", len(re.findall(r"^Host ubuntu", cfg.read_text(), re.M)))
PY'

echo "==> termux-boot script (install Termux:Boot from F-Droid + open app once)"
ssh "$REMOTE" 'mkdir -p ~/.termux/boot'
scp "${SKILL_ASSETS}/termux-boot-sshd" "${REMOTE}:.termux/boot/sshd"
ssh "$REMOTE" 'chmod +x ~/.termux/boot/sshd'

echo "==> termux-api wake-lock (optional, helps sshd survive Doze)"
ssh "$REMOTE" 'pkg install -y termux-api 2>/dev/null || true'

echo "==> start sshd now"
ssh "$REMOTE" 'pgrep -x sshd >/dev/null 2>&1 || sshd; pgrep -x sshd >/dev/null || { echo "sshd failed to start"; exit 1; }'

echo "==> smoke: phone → PC"
ssh "$REMOTE" 'ssh -o BatchMode=yes -o ConnectTimeout=8 ubuntu "echo OK-PHONE-TO-PC"'

echo "==> done"
echo "    Android: install Termux:Boot from F-Droid, open it once, allow startup permission."
echo "    PC: ssh s25  |  Termux: ubuntu"
