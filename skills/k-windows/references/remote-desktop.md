# k-windows — Remote access services (RDP, Chrome Remote Desktop) + the corporate VPN+RDP pattern

> Generalized from a specific machine's setup (`k-blglaptop139`) — pure Windows OS mechanism below, zero company-specific content. The company-specific *target* (which machine, whose account, what VPN portal) belongs in that company's own skill (e.g. `k-dxo`).

## The generic corporate remote-access pattern

A common shape at almost any employer, independent of vendor: install the company's VPN client (Cisco AnyConnect, Palo Alto GlobalProtect, a generic OpenConnect-compatible SSL VPN, etc.), connect with MFA, and only then does RDP/SSH into internal machines become reachable. On Windows this is trivial (download the vendor's native client, install with defaults, connect to the portal URL with your corporate credentials) — see `k-dxo` for a filled-in example (GlobalProtect). The one non-obvious piece of depth in that example lives on the **Linux** side (running the VPN client as a systemd service with correct desktop-keyring routing for SAML MFA) — that's not Windows content, so it isn't generalized here; it doesn't have a generic home yet if a second company ever needs the same Linux trick.

One tenant-agnostic fact worth knowing regardless of employer: `https://myapplications.microsoft.com` is Microsoft's own generic Entra ID/Microsoft 365 self-service portal for MFA enrollment (Authenticator app setup, etc.) — the same URL works for any organization using default Microsoft 365/Entra ID, it's not specific to one company's tenant.

## Native Windows RDP (Remote Desktop)

**Enable:**
```powershell
sc.exe config TermService start= demand    # Remote Desktop Services
sc.exe config SessionEnv start= demand     # Remote Desktop Configuration
Start-Service -Name TermService
Start-Service -Name SessionEnv
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0 -Type DWord
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
```

**Disable** (inverse — see `references/windows-services.md` for the general service-disable technique if either service resists):
```powershell
Set-Service -Name TermService -StartupType Disabled
Set-Service -Name SessionEnv -StartupType Disabled
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 1 -Type DWord
Disable-NetFirewallRule -DisplayGroup "Remote Desktop"
```
(Stopping the two services alone is usually sufficient in practice; setting `fDenyTSConnections=1` and disabling the firewall rule group is the belt-and-suspenders version.)

## Ubuntu client (Remmina) — RDP to a Windows+WSL machine

Generalized from a real Remmina profile (`k-blglaptop139`, `k-dxo`, `k-ubuntu`) — the fields below are the mechanism; the actual hostname/domain/account belong in the company or machine skill that owns that connection.

| Field | Value / guidance |
|---|---|
| Server | `<hostname-or-ip>` (FQDN if domain-joined, else the bare hostname/IP — e.g. Tailscale MagicDNS name) |
| Username | `<username>` |
| Domain | `<domain>` — leave blank if the account isn't domain-joined |
| Resolution | "Use client resolution" |
| Multi-monitor | Edit → Advanced → "Span screen over multiple monitors" (optional) |
| Audio | `sound=local`, `microphone=local` |

Saved profile lives at `~/.local/share/remmina/<profile-name>.remmina` on the Ubuntu client — Remmina names the file from the connection group/server when saved through the GUI, no manual editing needed for a first setup. If the target is behind a corporate VPN, RDP is only reachable once that VPN is connected (see "The generic corporate remote-access pattern" above).

## Chrome Remote Desktop ("chromoting")

The Chrome Remote Desktop Host's Windows service is always named `chromoting`, regardless of machine or company.

**Enable:**
```powershell
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\chromoting" -Name "Start" -Value 2 -Type DWord   # 2 = Automatic
sc.exe config chromoting start= auto
Start-Service -Name chromoting
# fallback if Start-Service didn't bring it up:
net start chromoting
```

**Disable:** standard service-disable (`references/windows-services.md`), target name `chromoting`.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-25 | [CLAUDE] | v1.0.0 — Created. Generalized the RDP and Chrome Remote Desktop enable/disable mechanisms from `k-blglaptop139`'s de-bloat scripts, plus a short note on the generic corporate-VPN+RDP pattern (Windows side only — the Linux-side systemd/keyring depth from `k-dxo` doesn't have a generic home yet). |
