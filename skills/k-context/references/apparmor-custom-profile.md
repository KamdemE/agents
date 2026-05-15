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
sui -r "Write the custom AppArmor profile for Electron apps" tee /etc/apparmor.d/custom-kpihx-electron-apps > /dev/null <<'PROFILE'
#include <tunables/global>

profile kpihx-electron-apps {
  #include <abstractions/base>
  #include <abstractions/dri-common>
  #include <abstractions/X>
  
  # Bitwarden
  /opt/Bitwarden/bitwarden-app mr,
  /opt/Bitwarden/** mr,
  
  # Cursor (.deb)
  /usr/share/cursor/** mr,
  /usr/share/cursor/cursor px -> kpihx-electron-apps,
  /usr/bin/cursor rm,
  
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
  $HOME/.config/** rw,
  $HOME/.cache/** rw,
  $HOME/.local/** rw,
  
  # GNOME Shell (if needed)
  /usr/bin/gnome-shell px -> kpihx-electron-apps,
}
PROFILE
```

### 2. Load and Test Profile

```bash
# Validate syntax
sui -r "Validate the custom AppArmor profile syntax" apparmor_parser -d /etc/apparmor.d/custom-kpihx-electron-apps

# Load in enforce mode
sui -r "Load the custom AppArmor profile" apparmor_parser -r /etc/apparmor.d/custom-kpihx-electron-apps

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
    /usr/share/cursor/cursor px -> kpihx-electron-apps,
}
```

### 4. Reload and Verify

```bash
sui -r "Reload AppArmor after custom profile update" systemctl reload apparmor
aa-status 2>/dev/null | grep kpihx-electron-apps
```

## Notes & Maintenance

- **Do not keep hardcoded home paths in the reference doc** — materialize `$HOME` to the actual home path only when installing the profile
- **Audit regularly** → check `/var/log/audit/audit.log` for new denials
- **Keep profile length minimal** → avoids future maintenance burden
- **Test in complain mode first** → use `apparmor_parser -C` before enforce
- **Version control** — add to the k-code/k-context workflow if needed

## Fallback

If this custom profile proves too complex, Option A (complain mode on `unprivileged_userns`) is sufficient for indefinite daily use.
