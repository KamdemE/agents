# S25 — ADB vs SSH (what each channel can do)

## Termux username (`u0_a417`)

Android assigns one Unix user per app UID. **You cannot rename it to `kpihx`** — SSH must keep `User u0_a417` in `assets/ssh-kpihx-phones.conf`.

Cosmetic options **inside Termux** (`~/.bashrc` or `~/.zshrc`):

```bash
export PS1='kpihx@s25:\w\$ '
# or: export USER=kpihx   # prompt only — real id remains u0_a417
```

PC side: use host alias **`ssh s25`** / **`kpihx-s25`** — that is already the friendly name.

## ADB connected — what works from Ubuntu

| Action | Via ADB | Notes |
|--------|---------|--------|
| Android shell | `adb shell` | User `shell` — **not** Termux `$HOME`, not your packages |
| List / launch apps | `adb shell pm list packages`, `am start -n …` | Open Termux UI, Settings, etc. |
| Files on shared storage | `adb push` / `adb pull` `/sdcard/…` | |
| Screenshot / logcat | `adb exec-out screencap`, `adb logcat` | |
| **Run command inside Termux env** | ⚠️ Hard | `adb shell` **cannot** use Termux `RUN_COMMAND` intent (no `RUN_COMMAND` permission) |
| **Full Termux shell (uv, git, agents)** | ✅ **`ssh s25`** after `sshd` | Preferred sovereign path |

## Termux from ADB (advanced, limited)

Requires in Termux `~/.termux/termux.properties`:

```properties
allow-external-apps=true
```

Even then, plain **`adb shell am startservice … RUN_COMMAND`** usually **fails** unless the caller holds `com.termux.permission.RUN_COMMAND` (shell user does not). Workarounds: **SSH**, root, or Termux GitHub debug + `run-as` (see Termux wiki *RUN_COMMAND Intent*).

**Practical split:**

- **ADB** — device maintenance, apps, storage, debug, automation hooks.
- **SSH (`s25`)** — real Termux/Linux workflow (same as on Ubuntu).

## Open Termux from PC (ADB)

```bash
adb shell am start -n com.termux/.app.TermuxActivity
```

Does not replace SSH for running scripts in Termux home.
