# k-phones — insights

## 2026-05-26 — [CURSOR] S25 hardware reference

- **Canonical specs:** `references/s25-hardware.md` — SoC/RAM/GPU/storage, Termux limits, compute vs PC routing. Read before proposing on-device LLM or heavy batch jobs.
- **Termux cores:** `nproc` => **4** on S25 while `adb shell nproc` => **8** — do not assume full SoC in Termux cgroup.

## 2026-05-25 — [CURSOR] S25 ADB + SSH bootstrap

- **SSH key:** `~/.ssh/config` referenced missing `id_ed25519_tel`; actual key is **`id_ed25519_s25`** — fixed in `k-ssh/assets/ssh.conf`.
- **ADB over Tailscale:** Wireless debugging can show **`100.125.54.1:PORT`** (stable IP, **ephemeral port**). Pairing **`mail@workstation`** persists; only `adb connect` + port refresh needed.
- **ADB connect failure** while TCP succeeds (`failed to connect` but port OPEN): wireless-debug **session stale** — port number on a **TG screenshot can match an old session** that no longer accepts ADB; toggle debug OFF/ON and use **live** port from phone screen (not archive photo).
- **Termux SSH:** port **8022**; requires **`sshd` running** on phone (`Connection refused` if Termux not started or sshd stopped).
- **Do not** use VS Code Remote SSH **into** Termux (bionic) — SSH **from** PC **to** Termux is correct.
- **OpenSSH Include:** `Include` for phone fragment must be **near the top** of `$HOME/.ssh/config` — an `Include` at the file tail was ignored on OpenSSH 10.2.
- **`adb pair` on debug port:** `adb pair 100.125.54.1:46677` with code from pairing dialog but **46677 = main-screen debug port** → `protocol fault`. Use the pairing dialog's **PAIRING_PORT** only.
- **Eduroam:** both on eduroam + Tailscale ≠ same L2 network for Android’s message; TCP to TS IP can be open while TLS ADB fails until pair+connect ports are correct, or use **hotspot**.
- **ADB interface transition (2026-08-20):** use raw `adb`; no skill-local ADB scripts or PATH symlinks are supported.
- **Termux on S25 (2026-05-25):** `107` pkg, zsh+oh-my-zsh, python/git/openssh, `~/homelab/homelab_finder.sh`, `~/storage/*` → `/sdcard`, outbound SSH keys to ubuntu/pve; **no** `tailscale` pkg in Termux (Tailscale = separate Android app `com.tailscale.ipn`).
- **ADB live:** `SM-S938B` Android 16 / SDK 36 @ `100.125.54.1:46677`; `adb shell` cannot read Termux `$HOME` without `run-as` (denied on retail build).
- **Lebara eSIM (2026-05-25):** Samsung `dumpsys econtroller` is the diagnostic source (`dumpsys euicc` → *Can't find service*). Failures show **`SVR_8.2.5/4.3`** at **ES9_AUTHENTICATE_CLIENT** to `leb.prod.ondemandconnectivity.com` — matches UI *Checking SIM information → An error occurred*. **25+** `ProfileDownloadStart` attempts in one day; **`Embedded subscriptions: []`** in `dumpsys isub`. SM-DP+ HTTPS reachable from Termux (TLS OK). Escalate to **Lebara** with order ref + EID (Settings → About → eSIM status), not more QR scans.
- **Lebara eSIM (2026-05-26):** Support imposed **30-day wait** (prior eSIM history on device) before rescanning kept QR **`ML045066180`**. Canonical PDF paths + hash in **`$HOME/Downloads/lebara-esim/CANONICAL-PDF.md`** (Drive SOT). **`ML045067164`** cancelled/refunded — PDF in `archive-cancelled/`. TickTick `6a1491488f08dbc9d7a14fbc` due **2026-06-25**.
- **Orphan subscriptions (subId 2/3/4):** visible in `dumpsys isub` (`simSlotIndex=-1`) but **not** in Samsung SIM manager UI (`getAvailableSubscriptionInfoList: [1]` only). ADB `cmd phone disable-physical-subscription` → **Permission denied** (shell lacks telephony privs; root not advised on retail S25). **Do not** use network reset if **eduroam** must stay — ghosts are DB-only and harmless in UI.
- **Pairing code:** always use a **fresh** 6-digit code from the pairing dialog — old codes fail silently or with protocol errors.
- **Phone → PC tmux (2026-05-25):** Termux `ubuntu` = `ssh ubuntu -t tmux attach -t default` — join PC session **`default`**, never spawn session `ubuntu` on PC. Termux local `tmux` stays separate. Doc triad: `SKILL.md` + `phone-to-ubuntu.md` + `termux-tmux.md`.
- **Termux deploy:** install **`termux-api`** for clipboard; use the canonical `k-tmux` configuration rather than a local deployment wrapper.
- **Phone `ubuntu` → password (2026-05-25):** Termux SSH showed `workstation (129.104.201.11)` — **campus/public IP**, not Tailscale **`100.82.95.70`**. Host-key churn + password prompt = wrong resolver and/or pubkey not offered (`IdentityFile` missing). Fix: Tailscale app **Connected** on S25, then `HostName 100.82.95.70` in Termux `~/.ssh/config` + `IdentityFile ~/.ssh/id_ed25519_ubuntu`; verify `termux-s25` on PC `authorized_keys`. **`ping workstation` can succeed while SSH still uses a bad resolver** — prefer explicit Tailscale IP in `HostName`.
- **PC `ssh s25` → Connection refused (2026-05-25):** Usually **Termux `sshd` not running** (app closed / Android killed Termux), not DNS. MagicDNS → IP in `k-ssh/assets/ssh.conf` fixes wrong-host only. Persistence uses `scripts/k_phones_sshd_autostart.sh` and `~/.termux/boot/sshd`; autostart uses **`pgrep -x sshd`**. Termux:Boot may need `verifier_verify_adb_installs=0` before `pm install` on Samsung. Never save a wireless-debug port.

## 2026-08-20 — [COLAB] Phone interface transition

- **Transition:** the prior skill name and its ADB/PVE helper interfaces were purged. Use `k-phones`, raw `adb`, and the live Wireless Debugging port; never persist a debug port or recreate wrappers.
- **SSHD script:** the S25 shell source is `assets/kshrc`, which sources `scripts/k_phones_sshd_autostart.sh`.
