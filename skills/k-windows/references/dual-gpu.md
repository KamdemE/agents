# k-windows — Dual-GPU laptop: diagnosing and reducing dGPU idle load

> Generalized from a specific machine (`k-laptop`, Intel iGPU + NVIDIA dGPU) — the diagnostic method and mitigations below apply to any Windows laptop with two GPUs. Exact GPU model/VRAM/utilization numbers stay in that machine's `references/gpu.md`.

## Diagnosis: it's often a display-wiring problem, not a driver bug

On a laptop with both an integrated GPU (iGPU) and a discrete GPU (dGPU), if an external monitor's cable is physically wired to the dGPU's output, the desktop compositor (`dwm.exe`) and any GPU-accelerated app (notably Electron apps — VS Code/Cursor, Slack, Discord, …) rendering a window on that monitor run on the **dGPU by default** — keeping it at surprisingly high utilization even completely idle.

**Before chasing driver/power-plan settings**, check:
1. `nvidia-smi` (or the equivalent dGPU vendor tool) utilization at idle — high and stable "for no reason" is the tell.
2. Which physical port(s) on the laptop the dGPU actually drives — this is usually a hardware wiring decision (often the HDMI/DP ports are the dGPU, the internal panel is the iGPU), not something a driver setting controls.

## Mitigations (independently reusable, any laptop/GPU model)

**1. Lower display compositor work — force 100% DPI scaling:**
```powershell
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "LogPixels" -Value 96 -Type DWord
```

**2. Lower the external monitor's refresh rate / resolution** — no API for this; Settings → System → Display → Advanced display settings (manual step).

**3. Force a specific app onto a specific GPU** — a built-in Windows 10/11 feature, not laptop-specific:
Settings → System → Display → Graphics → pick the app → "Power saving" (forces iGPU) or "High performance" (forces dGPU).

**4. Toggle an Electron app's own internal GPU-acceleration flag** (check if the GPU-heavy app has one before assuming Windows-level settings are the only lever). Two safe ways to edit its JSON/JSONC settings file from a script:

- **Full JSON round-trip** (fine for plain `.json`, will strip comments from `.jsonc`):
  ```powershell
  $json = Get-Content $settingsPath -Raw | ConvertFrom-Json
  $json | Add-Member -NotePropertyName "editor.gpuAcceleration" -NotePropertyValue "off" -Force
  $json | ConvertTo-Json -Depth 10 | Set-Content $settingsPath
  ```
- **Regex text edit** (safer for `.jsonc` files with comments a full parse/re-serialize would destroy):
  ```powershell
  $content = Get-Content $settingsPath -Raw
  if ($content -match '"editor\.gpuAcceleration"\s*:\s*"[^"]*"') {
      $content = $content -replace '"editor\.gpuAcceleration"\s*:\s*"[^"]*"', '"editor.gpuAcceleration": "off"'
  } else {
      $content = $content -replace '\{', "{`n  `"editor.gpuAcceleration`": `"off`",", 1
  }
  Set-Content -Path $settingsPath -Value $content
  ```
  (`editor.gpuAcceleration` is a VS Code/Cursor-family key specifically — the *technique* of checking whether a GPU-heavy Electron app exposes its own accel toggle, and editing its config file safely, is the reusable part.)

**5. Enable NVIDIA persistence mode** (generic NVIDIA GPU management, unrelated to any specific laptop):
```powershell
nvidia-smi -pm 1 -i <gpu-index>
```

