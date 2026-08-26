# k-blglaptop139 — De-bloat Log (2026-07-02)

Migrated verbatim from an unversioned Windows-side `.agents` (`DxO/SPECS.md` + `DxO/RECAP_OPTIMISATION_SYSTEME.md`), at real risk of loss before this migration. Dated log — paths below intentionally still say `C:\Users\ikamdem\Labs\...` (the workspace was later renamed to `KpihX-Labs`); this is a point-in-time snapshot, not a live reference, and is left as originally written.

Scripts referenced below are the real admin `.ps1` files, now at `k-blglaptop139/assets/` (originally at `KpihX-Labs/tmp/`, **not** `DxO/tmp/` as an earlier, incorrect Windows-side doc claimed).

## Resource snapshot before optimization

RAM total 32213 Mo; in-use ~14749 Mo; cache/standby ~8500 Mo; hardware reserved ~555 Mo; kernel pool ~2695 Mo; really-available ~16300 Mo. ~314-376 processes. GPU: Intel 0% util / ~128 MB VRAM; NVIDIA 61-89% util (before opt) / 784/12227 MB VRAM / 55°C / 17-19 W. CPU ~3% total.

**Top RAM processes:** opencode 1507 Mo (407s CPU); Cursor (main) 612 Mo (272s); dwm 581 Mo; explorer 407 Mo; EIConnector (ESET) 340 Mo; Cursor extensions 1600+ Mo total; TextInputHost 286 Mo; ekrn (ESET) 210 Mo.

## 1. Startup programs disabled

| Item | Location | RAM |
|---|---|---|
| Adobe Acrobat Synchronizer | HKCU Run | ~100 Mo |
| Microsoft Copilot | HKCU Run | ~150 Mo |
| Microsoft Edge auto-start | HKCU Run | ~200 Mo |
| GlobalProtect | HKLM Run | ~100 Mo |
| Bitwarden | StartupApproved | ~50 Mo |
| Google Drive File Stream | StartupApproved | ~100 Mo |
| OneDrive | StartupApproved | ~80 Mo |
| DxO PureRAW 5 | removed, verify RunOnce | ~100 Mo |

## 2. Services disabled — 22 services, ~550 MB RAM total

`AdobeARMservice` (~5MB), `DiagTrack` (52.7MB), `DolbyDAXAPI` (~10MB), `GameInputRedistService` (~5MB), `GamingServices` (44.4MB), `GamingServicesNet` (~20MB), `InventorySvc` (~5MB), `PcaSvc` (~10MB), `Spooler` (~5MB), `SysMain` (~100MB), `WpnService` (~10MB), `chromoting` (~5MB), `GameInputSvc` (~5MB), `lfsvc` (~5MB), `SessionEnv` (~5MB), `TermService` (~5MB), `PimIndexMaintenanceSvc` (~5MB), `UnistoreSvc` (~5MB), `UserDataSvc` (~5MB), `SQLWriter` (~5MB), `WSearch` (~100MB), `WpnUserService_85a508` (44.1MB).

Script: `assets/desactiver_services_admin.ps1` — looks each up via `Get-CimInstance Win32_Service`, skips if not found or if another service depends on it, stops it (2s wait), sets `StartupType Disabled`, verifies. Reversal: `Set-Service -StartupType Manual` + `Start-Service`.

Three of the above (`GamingServices`, `GamingServicesNet`, `PcaSvc`) needed a second, more forceful pass — `assets/disable_3_remaining_admin.ps1`. Seven stubborn ones (same three + `WpnUserService_85a508`, `PimIndexMaintenanceSvc_85a508`, `UnistoreSvc_85a508`, `UserDataSvc_85a508`) needed `sc.exe config <name> start= disabled` directly — `assets/force_disable_services_admin.ps1`. Three needed direct registry writes (`HKLM:\SYSTEM\CurrentControlSet\Services\<name>\Start = 4`, clearing `FailureActions`) — `assets/force_disable_store_services.ps1`. **The general 4-tier escalation technique (reusable on any Windows machine) is documented in `k-windows/references/windows-services.md`** — this log keeps only the specific service names for this machine.

**⚠️ Re-enablement done on purpose, same pass:** `chromoting` (Auto/Running) and `TermService`/`SessionEnv` (Manual/Running) were put back — see `assets/reconfig_chromoting_admin.ps1` and `assets/reconfig_rdp_admin.ps1` — plus `fDenyTSConnections = 0` (registry) and the "Remote Desktop" firewall rule group enabled, to keep Chrome Remote Desktop / RDP working. Chrome Remote Desktop Host was explicitly kept installed "for phone access." **General RDP/chromoting enable-disable mechanism → `k-windows/references/remote-desktop.md`.**

## 2b. Second pass (RECAP doc) — 13 more services + startup/scheduled-task cleanup

Dell/Killer/Intel services disabled: `DellTechHub`, `SupportAssistAgent`, `DellClientManagementService`, `Alienware SupportAssist Remediation`, `Alienware Digital Delivery Services`, `Killer Network Service`, `Killer Analytics Service`, `Killer Provider Data Helper Service`, `KNDBWM`, `KAPSService`, `XTUService`, `IgoAudioService`, `PhoneSvc`.

Scheduled task disabled: `Adobe Acrobat Update Task`. Widgets disabled (`IsWidgetServiceOn=0`, `TaskbarDa=0`).

**Processes force-stopped this pass (~4.5 GB freed):** Dell.TechHub + sub-agents ~1.8 GB; SupportAssistAgent ~330 MB; AlienFXSubAgent ~290 MB; AWCC sub-agents ~690 MB; Killer processes ~340 MB; XTUService ~210 MB; OCControl.Service ~110 MB; GameEyeApp ~75 MB; CrossDeviceService+Resume ~190 MB; PhoneExperienceHost ~195 MB; WidgetBoard ~150 MB; eServiceHost×2 ~115 MB. Script: `assets/desactiver_bloatware_admin.ps1` (original path recorded as `C:\Users\ikamdem\Labs\...`, per the dated-log rule above).

**24 executables permanently disabled by rename to `.exe.DEAD`** (irreversible unless renamed back):
- AWCC (9): `AWCC.exe`, `AWCCOverlay.exe`, `AWCC.SCSubAgent.exe`, `AWCC.UCSubAgent.exe`, `AlienFXSubAgent.exe`, `AWPerformance.SCSubAgent.exe`, `OCControl.Service.exe`, `AWPerformance.UCSubAgent.exe`, `GameEyeApp.exe`.
- Dell SupportAssist (14): `DellSupportAssistControlPanel.exe`, `DellSupportAssistRemedationService.exe`, `SupportAssist.exe`, `SupportAssistAgent.exe`, `SupportAssistAppWire.exe`, `SupportAssistDataMigration.exe`, `SupportAssistDataSanitization.exe`, `SupportAssistHardwareDiags.exe`, `SupportAssistSoftwareDiags.exe`, `Dell.SupportAssist.Client.ShowUIHelper.exe`, `SupportAssistInstaller.exe`, `SupportAssistOsRecovery.exe`, `DellDataManager.exe`, `DellUpdateSupportAssistPlugin.exe`.

**Kept on purpose:** Cursor, opencode, ESET (`ekrn` — PIDs may vary, it's the AV kernel, do not kill), Tailscale, Windows Defender/SecurityHealth, NVIDIA drivers, Killer network *driver* (only the bloatware *service* was removed), Realtek Audio, Intel Graphics, PowerToys, Office ClickToRun.

**The general uninstall-by-GUID and uninstall-by-DisplayName-pattern techniques (scripts below) are documented generically in `k-windows/references/software-removal.md`** — this log keeps only the specific app names/GUIDs found on this machine.

**Reversal recipe (general):** rename `.DEAD` → `.exe`, then `Set-Service -StartupType Manual` (or `Automatic`) + `Start-Service`.

## 3. Applications uninstalled — ~11.8 GB (2026-07-02 pass)

| Category | Total | Notable items |
|---|---|---|
| Dell bloatware | ~2.5 GB | SupportAssist, Core Services, AWCC Package, Digital Delivery, AW SupportAssist Remediation/OS Recovery |
| Remote Desktop unused | ~222 MB | NoMachine (215 MB), VNC Viewer (7 MB) — Chrome Remote Desktop Host explicitly **kept** |
| NVIDIA dev tooling | ~2.7 GB | Nsight Compute (1097 MB), Nsight Systems (1452 MB), Nsight VS Edition (152 MB) |
| Unused tools | ~3.5 GB | Log4View V2 (702 MB), Strawberry Perl (1020 MB), MSYS2 (317 MB), doxygen (164 MB), ImageJ (93 MB), ImageMagick (59 MB), GlobalProtect (124 MB), KDiff3 (76 MB), FileZilla (43 MB), WinMerge (30 MB) |
| Duplicate Python | ~130 MB | Python 3.12.0 (kept 3.12.10) |
| Old Windows SDK | ~2.4 GB | `22621` SDK (kept newer) |
| Killer suite | ~362 MB | Performance Driver Suite, XtuInstaller |

40 UWP apps purged by exact package ID (2 lots of 27 + 13): Dell/Killer/Bing/Xbox/Todos/PowerAutomate/DevHome/YourPhone/CrossDevice/Slack/intelliGo/Dolby/Optane/IntelGraphicsExperience/IntelArc/AdobeAcrobatReader families.

**Uninstall scripts (`assets/`):**
- `desinstaller_complet_admin.ps1` — 16 named tools by registry `DisplayName` match (Log4View, Strawberry Perl, doxygen, ImageJ, GPL Ghostscript, Graphviz, WinDirStat, WinMerge, KDiff3, HxD, IrfanView, FastStone, LockHunter, ezwinports, VNC Viewer, NoMachine) + Python 3.12.0 + old Windows SDK + NVIDIA Nsight + anything matching `*Killer*`.
- `desinstaller_dell_admin.ps1` — 7 Dell/Alienware apps by exact MSI GUID (SupportAssist `{5E5B7C3B-96BE-4A47-B28D-CAA7D87F95A8}`, Digital Delivery `{87310396-FD49-4108-BBBB-28E1C3EA85E9}`, SupportAssist Remediation `{2D452EA3-A8E6-4DF8-8135-6D8F2D61F693}`, SupportAssist OS Recovery `{BE92A615-4964-403F-B965-827881C7CE4D}`, AlienwareArena `{74234BCD-70C4-40EC-BC36-0D7C376F3EC3}`, Dell Command Update `{1243A8BB-4137-47B3-BAAE-783E7D662407}`, Dell Core Services `{7AF25A53-31D7-4E74-8D7C-B5D59B3A92C7}`), then force-deletes leftover `Alienware` directories under `ProgramFiles`/`ProgramFiles(x86)`/`ProgramData`.
- `desinstaller_nsight_sdk_admin.ps1` — Nsight Compute/Systems/VS Edition + Windows SDK `22621` match.
- `desinstaller_outils_admin.ps1` — 6 apps by exact GUID (Log4View `{3C1D7E0F-6D28-4C0D-B787-2F634E49891F}`, Strawberry Perl `{2331E434-70DE-4357-9D08-295A0B9F303D}`, Python 3.12.0 `{D2B580FC-6E22-469C-B141-0769B9888D37}`, Killer Driver Suite `{9FD727F9-376A-4834-B11D-0E36C1485C81}`, Nsight Systems `{1A7B91EF-6530-4B35-A646-22A1F069A7A5}`, Nsight Graphics `{2B5D154C-5E34-4C33-B59E-3F4C7B87A2A3}`), then cleans orphaned directories.
- `desinstaller_restante_admin.ps1` — NoMachine, VNC Viewer, WinDirStat, GPL Ghostscript, WinMerge, Killer Performance Driver Suite, ImageJ, a broad Dell/AWCC/Killer regex sweep, and Python 3.12.0 (regex-matched).

## 4. GPU / display optimization

`assets/optimiser_gpu_admin.ps1` / `assets/optimiser_gpu_final.ps1`: sets `HKCU:\Control Panel\Desktop\LogPixels=96` (100% scaling); forces `"editor.gpuAcceleration": "off"` in Cursor's `settings.json`; runs `nvidia-smi -pm 1 -i 0` (persistence mode); prints manual instructions for external-monitor refresh rate and forcing apps to the Intel GPU via Windows Graphics settings.

**nvidia-smi after optimization:** FB Memory Total 12227 MiB, Used 833 MiB (6.8%); GPU Utilization 15% (down from 61-89%); Temp 57°C; Power 16.59 W; Clocks 675/810 MHz.

**General dual-GPU diagnosis + mitigation technique → `k-windows/references/dual-gpu.md`** — this log keeps only this machine's exact numbers.

## Estimated total gains (2026-07-02 pass)

~550 MB RAM (services) + ~500 MB disk (UWP apps) + ~2.5 GB (Dell bloatware) + ~3.5 GB (unused tools) + ~4.7 GB (NVIDIA dev) + ~2.4 GB (old SDK) ≈ **~550 MB RAM / ~13.6 GB disk**, plus a further **~4-5 GB RAM** freed the same day from the startup/scheduled-task/service second pass (RECAP doc).

## Reference machine spec at the time of this log

CPU 24 threads; RAM ~32 GB; GPU RTX 5070 Ti Laptop, 12 GB VRAM — see the Hardware Specs table in `SKILL.md` for the current canonical values (this log's own figures match, confirmed consistent).

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-25 | [CLAUDE] | v1.0.0 — Created. Migrated verbatim from the unversioned Windows-side `DxO/SPECS.md` + `DxO/RECAP_OPTIMISATION_SYSTEME.md` (dated 2026-07-02), at real risk of loss (no git history at all on the source). Corrected the source's own wrong path claim (`DxO/tmp/` → real location was `KpihX-Labs/tmp/`, now `k-blglaptop139/assets/`). |
