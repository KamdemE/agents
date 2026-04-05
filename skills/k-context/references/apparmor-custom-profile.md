# AppArmor Custom Profile for Electron Apps (Option B)

Once the system crashes from `unprivileged_userns` confinement have been stabilized via Option A (`aa-complain`), implement a permanent, granular solution using a custom AppArmor profile.

## Overview

Instead of running the entire `unprivileged_userns` profile in complain mode, create a custom profile that:
- Explicitly **whitelists** Bitwarden, Cursor, Antigravity, and GNOME Shell
- Grants the minimal required capabilities (`NET_ADMIN`, `SYS_ADMIN`, etc.)
- Remains restrictive for all other processes
- Is fully auditable and version-controlled

## Implementation Steps

### 1. Create Custom Profile

Create `/etc/apparmor.d/custom-kpihx-electron-apps`:

```bash
cat << 'PROFILE' | sudo tee /etc/apparmor.d/custom-kpihx-electron-apps
#include <tunables/global>

profile kpihx-electron-apps {
  #include <abstractions/base>
  #include <abstractions/dri-common>
  #include <abstractions/X>
  
  # Bitwarden
  /opt/Bitwarden/bitwarden-app mr,
  /opt/Bitwarden/** mr,
  
  # Cursor (if extracted)
  /home/kpihx/Applications/cursor-app/** mr,
  /home/kpihx/Applications/cursor-app/AppRun px -> kpihx-electron-apps,
  
  # Antigravity (native install)
  /usr/share/antigravity/** mr,
  /usr/share/antigravity/antigravity px -> kpihx-electron-apps,
  
  # Required capabilities
  capability net_admin,
  capability sys_admin,
  capability sys_boot,
  capability sys_ptrace,
  capability setfcap,
  capability dac_override,
  
  # Network access
  network inet stream,
  network inet dgram,
  network unix,
  
  # Namespace creation (required for sandbox)
  userns create,
  mqueue,
  /{proc,sys}/** r,
  /dev/tty rw,
  /dev/null rw,
  /dev/urandom r,
  /dev/zero rw,
  
  # User-specific dirs
  /home/kpihx/.config/** rw,
  /home/kpihx/.cache/** rw,
  /home/kpihx/.local/** rw,
  
  # GNOME Shell (if needed)
  /usr/bin/gnome-shell px -> kpihx-electron-apps,
}
PROFILE
```

### 2. Load and Test Profile

```bash
# Validate syntax
sudo apparmor_parser -d /etc/apparmor.d/custom-kpihx-electron-apps

# Load in enforce mode
sudo apparmor_parser -r /etc/apparmor.d/custom-kpihx-electron-apps

# Monitor logs (should see no denials for these apps)
journalctl -f | grep "apparmor.*DENIED"
```

### 3. Update Transition Rules

Modify `/etc/apparmor.d/unprivileged_userns` to transition to your custom profile instead of remaining confined:

```bash
profile unprivileged_userns {
    # ... existing rules ...
    
    # Transition Electron apps to custom profile
    /opt/Bitwarden/bitwarden-app px -> kpihx-electron-apps,
    /usr/share/antigravity/antigravity px -> kpihx-electron-apps,
    /home/kpihx/Applications/cursor-app/AppRun px -> kpihx-electron-apps,
}
```

### 4. Reload and Verify

```bash
sudo systemctl reload apparmor
aa-status 2>/dev/null | grep kpihx-electron-apps
```

## Notes & Maintenance

- **Never hardcode full paths** — use `<tunables/global>` and abstractions
- **Audit regularly** → check `/var/log/audit/audit.log` for new denials
- **Keep profile length minimal** → avoids future maintenance burden
- **Test in complain mode first** → use `apparmor_parser -C` before enforce
- **Version control** — add to the k-code/k-context workflow if needed

## Fallback

If this custom profile proves too complex, Option A (complain mode on `unprivileged_userns`) is sufficient for indefinite daily use.
