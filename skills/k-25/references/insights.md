# k-25 — insights

## 2026-05-26 — [CURSOR] S25 hardware reference

- **Canonical specs:** `references/s25-hardware.md` — SoC/RAM/GPU/storage, Termux limits, compute vs PC routing. Read before proposing on-device LLM or heavy batch jobs.
- **Termux cores:** `nproc` => **4** on S25 while `adb shell nproc` => **8** — do not assume full SoC in Termux cgroup.

## 2026-05-25 — [CURSOR] S25 ADB + SSH bootstrap

- **SSH key:** `~/.ssh/config` referenced missing `id_ed25519_tel`; actual key is **`id_ed25519_s25`** — fixed in `k-ssh/assets/ssh.conf`.
- **ADB over Tailscale:** Wireless debugging can show **`100.125.54.1:PORT`** (stable IP, **ephemeral port**). Pairing **`kpihx@KpihX-Ubuntu`** persists; only `adb connect` + port refresh needed.
- **ADB connect failure** while TCP succeeds (`failed to connect` but port OPEN): wireless-debug **session stale** — port number on a **TG screenshot can match an old session** that no longer accepts ADB; toggle debug OFF/ON and use **live** port from phone screen (not archive photo).
- **Termux SSH:** port **8022**; requires **`sshd` running** on phone (`Connection refused` if Termux not started or sshd stopped).
- **Do not** use VS Code Remote SSH **into** Termux (bionic) — SSH **from** PC **to** Termux is correct.
- **OpenSSH Include:** `Include` for phone fragment must be **near the top** of `$HOME/.ssh/config` — an `Include` at the file tail was ignored on OpenSSH 10.2.
- **`adb pair` on debug port:** `adb pair 100.125.54.1:46677` with code from pairing dialog but **46677 = main-screen debug port** → `protocol fault`. Use **PAIRING_PORT** from the pairing dialog only (`adb-s25-pair`).
- **Eduroam:** both on eduroam + Tailscale ≠ same L2 network for Android’s message; TCP to TS IP can be open while TLS ADB fails until pair+connect ports are correct, or use **hotspot**.
- **Tool location:** `adb-s25`, `adb-s25-pair`, `phones.ksh` live in **`k-25/assets/`** (not `.agents/skills/k-ubuntu/scripts/`); `.kshrc` sources `assets/phones.ksh`.
- **Termux on S25 (2026-05-25):** `107` pkg, zsh+oh-my-zsh, python/git/openssh, `~/homelab/homelab_finder.sh`, `~/storage/*` → `/sdcard`, outbound SSH keys to ubuntu/pve; **no** `tailscale` pkg in Termux (Tailscale = separate Android app `com.tailscale.ipn`).
- **ADB live:** `SM-S938B` Android 16 / SDK 36 @ `100.125.54.1:46677`; `adb shell` cannot read Termux `$HOME` without `run-as` (denied on retail build).
- **Lebara eSIM (2026-05-25):** Samsung `dumpsys econtroller` is the diagnostic source (`dumpsys euicc` → *Can't find service*). Failures show **`SVR_8.2.5/4.3`** at **ES9_AUTHENTICATE_CLIENT** to `leb.prod.ondemandconnectivity.com` — matches UI *Checking SIM information → An error occurred*. **25+** `ProfileDownloadStart` attempts in one day; **`Embedded subscriptions: []`** in `dumpsys isub`. SM-DP+ HTTPS reachable from Termux (TLS OK). Escalate to **Lebara** with order ref + EID (Settings → About → eSIM status), not more QR scans.
- **Lebara eSIM (2026-05-26):** Support imposed **30-day wait** (prior eSIM history on device) before rescanning kept QR **`ML045066180`**. Canonical PDF paths + hash in **`$HOME/Downloads/lebara-esim/CANONICAL-PDF.md`** (Drive SOT). **`ML045067164`** cancelled/refunded — PDF in `archive-cancelled/`. TickTick `6a1491488f08dbc9d7a14fbc` due **2026-06-25**.
- **Orphan subscriptions (subId 2/3/4):** visible in `dumpsys isub` (`simSlotIndex=-1`) but **not** in Samsung SIM manager UI (`getAvailableSubscriptionInfoList: [1]` only). ADB `cmd phone disable-physical-subscription` → **Permission denied** (shell lacks telephony privs; root not advised on retail S25). **Do not** use network reset if **eduroam** must stay — ghosts are DB-only and harmless in UI.
- **Pairing code:** always use a **fresh** 6-digit code from the pairing dialog — old codes fail silently or with protocol errors.
- **Phone → PC tmux (2026-05-25):** Termux `ubuntu` = `ssh ubuntu -t tmux attach -t default` — join PC session **`default`**, never spawn session `ubuntu` on PC. Termux local `tmux` stays separate. Doc triad: `SKILL.md` + `phone-to-ubuntu.md` + `termux-tmux.md`.
- **`phones.ksh`:** never `readonly` + re-`source` — use `_K25_PHONES_KSH_SOURCED` guard (zsh: `read-only variable: K25_ASSETS`).
- **Termux deploy:** install **`termux-api`** for clipboard; avoid macOS `sed -i''` — use `grep -v` + `~/.k25-remote.zsh` drop-in.
- **Phone `ubuntu` → password (2026-05-25):** Termux SSH showed `kpihx-ubuntu (129.104.201.11)` — **campus/public IP**, not Tailscale **`100.82.95.70`**. Host-key churn + password prompt = wrong resolver and/or pubkey not offered (`IdentityFile` missing). Fix: Tailscale app **Connected** on S25, then `HostName 100.82.95.70` in Termux `~/.ssh/config` + `IdentityFile ~/.ssh/id_ed25519_ubuntu`; verify `termux-s25` on PC `authorized_keys`. **`ping kpihx-ubuntu` can succeed while SSH still uses a bad resolver** — prefer explicit Tailscale IP in `HostName`.
- **PC `ssh s25` → Connection refused (2026-05-25):** Usually **Termux `sshd` not running** (app closed / Android killed Termux), not DNS. MagicDNS → IP in `k-ssh/assets/ssh.conf` fixes wrong-host only. **Persistence (deployed 2026-05-25):** `~/.k25-remote.zsh` + `~/.termux/boot/sshd`; autostart uses **`pgrep -x sshd`**. **Termux:Boot** installed via ADB (`termux-install-boot.sh`): Samsung may need `verifier_verify_adb_installs=0` before `pm install` — else `INSTALL_FAILED_VERIFICATION_FAILURE`. Save live wireless-debug port (e.g. `38399`) in `$HOME/.config/kpihx/phones/s25-adb-port`.
