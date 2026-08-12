# Dell Battery Health & Charging Thresholds (CCTK)

On modern Dell laptops (like the Inspiron 16 7640 2-in-1), standard Linux ACPI tools (`/sys/class/power_supply/BAT0/charge_control_end_threshold`) and WMI sysfs (`/sys/class/firmware-attributes/dell-wmi-sysman/`) are **hardware-locked** or require a BIOS Admin password. This causes the GNOME GUI battery health toggle to revert silently on unplug/reboot.

To correctly enforce a battery charge limit (e.g., 75-80%) and stop severe battery degradation, you must bypass the standard tools and use Dell's proprietary tools.

## Prerequisites & Survival
1. Standard tools (`libsmbios-bin` / `smbios-battery-ctl`) are **deprecated** and missing from Ubuntu 26.04/24.04 repositories.
2. Dell's apt repository is dead, and their CDN download links are hidden behind Javascript.
3. **Source of Truth:** To guarantee survival, the official installer is permanently preserved in this skill at `assets/command-configure_5.1.0-6.ubuntu24_amd64.tar.gz`.

## The BIOS Password Trap (QWERTY vs AZERTY)
If a BIOS password is set on the machine, `cctk` requires it to make EEPROM changes. 
**CRITICAL:** The layout in the pre-boot BIOS is **QWERTY**. The password typed into the Linux terminal string must map exactly to what the QWERTY BIOS expects (e.g., typing 'q' instead of 'a' on an AZERTY keyboard). If you type your normal AZERTY string, the firmware will reject it as `Setup Password is required to change the setting`.

## Installation

```bash
# Extract the preserved asset
mkdir -p /tmp/cctk && cd /tmp/cctk
tar -zxvf ~/.agents/skills/k-ubuntu/assets/command-configure_5.1.0-6.ubuntu24_amd64.tar.gz

# Install the packages in exact order
sudo dpkg -i srvadmin-hapi_*.deb
sudo dpkg -i command-configure_*.deb
```

## Enforcing the Threshold (75-80%)

Run the `cctk` command passing the combined start-stop range. If you have a BIOS password, pass the QWERTY-mapped string.

```bash
sudo /opt/dell/dcc/cctk --PrimaryBattChargeCfg=Custom:75-80 --ValSetupPwd='<QWERTY_MAPPED_BIOS_PASSWORD>'
```

To verify the threshold stuck at the hardware level:
```bash
sudo /opt/dell/dcc/cctk --PrimaryBattChargeCfg
```
