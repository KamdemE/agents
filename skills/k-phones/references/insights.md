# k-phones — insights

## 2026-05-25 — [CURSOR] S25 ADB + SSH bootstrap

- **SSH key:** `~/.ssh/config` referenced missing `id_ed25519_tel`; actual key is **`id_ed25519_s25`** — fixed in `assets/ssh-kpihx-phones.conf`.
- **ADB over Tailscale:** Wireless debugging can show **`100.125.54.1:PORT`** (stable IP, **ephemeral port**). Pairing **`kpihx@KpihX-Ubuntu`** persists; only `adb connect` + port refresh needed.
- **ADB connect failure** while TCP succeeds (`failed to connect` but port OPEN): wireless-debug **session stale** — port number on a **TG screenshot can match an old session** that no longer accepts ADB; toggle debug OFF/ON and use **live** port from phone screen (not archive photo).
- **Termux SSH:** port **8022**; requires **`sshd` running** on phone (`Connection refused` if Termux not started or sshd stopped).
- **Do not** use VS Code Remote SSH **into** Termux (bionic) — SSH **from** PC **to** Termux is correct.
- **OpenSSH Include:** `Include` for phone fragment must be **near the top** of `$HOME/.ssh/config` — an `Include` at the file tail was ignored on OpenSSH 10.2.
- **`adb pair` on debug port:** `adb pair 100.125.54.1:46677` with code from pairing dialog but **46677 = main-screen debug port** → `protocol fault`. Use **PAIRING_PORT** from the pairing dialog only (`adb-s25-pair`).
- **Eduroam:** both on eduroam + Tailscale ≠ same L2 network for Android’s message; TCP to TS IP can be open while TLS ADB fails until pair+connect ports are correct, or use **hotspot**.
- **Tool location:** `adb-s25`, `adb-s25-pair`, `phones.ksh` live in **`k-phones/assets/`** (not `Work/sh/`); `.kshrc` sources `assets/phones.ksh`.
- **Termux on S25 (2026-05-25):** `107` pkg, zsh+oh-my-zsh, python/git/openssh, `~/homelab/homelab_finder.sh`, `~/storage/*` → `/sdcard`, outbound SSH keys to ubuntu/pve; **no** `tailscale` pkg in Termux (Tailscale = separate Android app `com.tailscale.ipn`).
- **ADB live:** `SM-S938B` Android 16 / SDK 36 @ `100.125.54.1:46677`; `adb shell` cannot read Termux `$HOME` without `run-as` (denied on retail build).
- **Lebara eSIM (2026-05-25):** Samsung `dumpsys econtroller` is the diagnostic source (`dumpsys euicc` → *Can't find service*). Failures show **`SVR_8.2.5/4.3`** at **ES9_AUTHENTICATE_CLIENT** to `leb.prod.ondemandconnectivity.com` — matches UI *Checking SIM information → An error occurred*. **25+** `ProfileDownloadStart` attempts in one day; **`Embedded subscriptions: []`** in `dumpsys isub`. SM-DP+ HTTPS reachable from Termux (TLS OK). Escalate to **Lebara** with order ref + EID (Settings → About → eSIM status), not more QR scans.
- **Orphan subscriptions (subId 2/3/4):** visible in `dumpsys isub` (`simSlotIndex=-1`) but **not** in Samsung SIM manager UI (`getAvailableSubscriptionInfoList: [1]` only). ADB `cmd phone disable-physical-subscription` → **Permission denied** (shell lacks telephony privs; root not advised on retail S25). **Do not** use network reset if **eduroam** must stay — ghosts are DB-only and harmless in UI.
- **Pairing code:** always use a **fresh** 6-digit code from the pairing dialog — old codes fail silently or with protocol errors.
- **Phone → PC tmux (2026-05-25):** Termux `ubuntu` = `ssh ubuntu -t tmux attach -t default` — join PC session **`default`**, never spawn session `ubuntu` on PC. Termux local `tmux` stays separate. Doc triad: `SKILL.md` + `phone-to-ubuntu.md` + `termux-tmux.md`.
- **`phones.ksh`:** never `readonly` + re-`source` — use `_KPHONES_PHONES_KSH_SOURCED` guard (zsh: `read-only variable: KPHONES_ASSETS`).
- **Termux deploy:** install **`termux-api`** for clipboard; avoid macOS `sed -i''` — use `grep -v` + `~/.kphones-remote.zsh` drop-in.
