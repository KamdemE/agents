# S25 — Wireless ADB (two ports, Tailscale, eduroam)

## Two different ports (mandatory)

Android 11+ wireless debugging uses **two** TCP ports:

| Step | Where on phone | Command on PC |
|------|----------------|---------------|
| **1. Pair** | *Pair device with pairing code* dialog | `adb-s25-pair PAIRING_PORT` or `adb pair IP:PAIRING_PORT` |
| **2. Connect** | Main *Wireless debugging* → **IP address & port** | `adb-s25 DEBUG_PORT` or `adb connect IP:DEBUG_PORT` |

**PAIRING_PORT ≠ DEBUG_PORT** (IP is often the same `100.125.54.1` on Tailscale).

Using the main-screen port (`46677`, `34503`, …) with **`adb pair`** → `protocol fault (couldn't read status message)`.

## Tailscale vs « same network »

- Phone may show **Tailscale IP** (`100.125.54.1`) — pairing over Tailscale **can work** when step 1 uses the **pairing** port ([reference](https://catg.kghs.net/2024/10/wireless_dbg/)).
- Message *« make sure devices are on the same network »* = Android generic text; on **eduroam**, **client isolation** blocks phone↔laptop on **campus Wi‑Fi** even if both are on eduroam + Tailscale.
- **TCP open + `adb connect` failed** without successful **pair** on the pairing port = fix pairing first, not another `adb-s25` on the same port.

## Recommended flows

### A — Tailscale (campus / anywhere)

```bash
# Phone: open « Pair device with pairing code » → note PAIRING_PORT + 6-digit code
adb-s25-pair PAIRING_PORT
# enter code when prompted

# Phone: main Wireless debugging screen → DEBUG_PORT
adb-s25 DEBUG_PORT
adb devices -l
```

**If `adb devices` is empty after `Successfully paired`:** pairing used `PAIRING_PORT` (e.g. `41183`) — you still must **`adb-s25 DEBUG_PORT`** from the **main** wireless debugging screen (debug port is usually different).

### B — Phone hotspot (when A fails)

1. S25 **mobile hotspot** ON → Ubuntu connects to it (not eduroam for this step).
2. Wireless debugging shows **Wi‑Fi IP** (often `192.168.x.x:port`) — use **that** IP for pair + connect.
3. Same two-port rule.

### C — Legacy `adb tcpip 5555` (USB once per reboot)

1. USB cable → `adb devices` → `adb tcpip 5555`
2. `adb connect 100.125.54.1:5555` over Tailscale ([gist pattern](https://gist.github.com/shehbajdhillon/2ddcd702ed41fc1fa45bfc0075918c12))

Less secure; use only on personal tailnet.

## Eduroam note

Both machines on **eduroam** does **not** mean « same L2 network » for ADB. Prefer **hotspot B** or **Tailscale pair flow A** with correct ports.

## SSH without ADB

`ssh s25` (Termux `sshd` on `:8022`) does not depend on wireless-debug ports — use when ADB is blocked.
