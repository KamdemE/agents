# Ubuntu — Deleted file recovery (ext4, GNOME)

> **Canonical reference** for KπX workstation image recovery after Trash empty / manual delete.
> **Skill owner:** `k-optim` (Ubuntu scope). **Living copy / Docsify:** `$HOME/Work/techskills/ubuntu-deleted-files-recovery.md`.
> **Validated:** 2026-05-26 — `Downloads/RAS` (VeniceAI PNG) + `Downloads/Telegram Desktop` (JPG), ~1–2 weeks after deletion.

---

## When to use

| Situation | Start here |
|-----------|------------|
| File still in Trash (`~/.local/share/Trash/files/`) | Restore from Trash — no tools |
| Trash emptied, need **fast partial recovery** without sudo | **Tier A** (thumbnails + xbel) |
| Need **full-resolution** carve from free space | **Tier B** (PhotoRec + sudo via tmux) |
| Need **original paths + names** from inode metadata | **Tier C** (extundelete) — only if FS **unmounted** or live USB |

**Stop writing** to the affected partition first (no big downloads, no `clean -p`, minimal new files in `~/Downloads`).

---

## Strategy overview (tiered)

```
Trash? ──yes──► restore from ~/.local/share/Trash/
   │
   no
   ▼
Tier A (no sudo)          Tier B (sudo, tmux)           Tier C (offline)
────────────────          ───────────────────           ────────────────
recently-used.xbel        PhotoRec /cmd freespace       extundelete
    │                         │                         (partition UNMOUNTED)
    ▼                         ▼
GNOME thumbnail cache     carve jpg/png/gif/tif/bmp
~256–512 px previews      anonymous fNNNNNNN.ext
original filenames        full resolution possible
```

### Tier A — Thumbnail + recent-files journal (no sudo)

**Why it works:** GNOME Files generates hashed previews under `~/.cache/thumbnails/` when you open or browse images. The Freedesktop **recently-used** database (`~/.local/share/recently-used.xbel`) often keeps **original paths and filenames** even after the file is gone.

**Steps:**

1. List deleted targets from xbel:
   ```bash
   grep -oP 'file:///home/kpihx/Downloads/[^<"]+' \
     ~/.local/share/recently-used.xbel | sort -u
   ```

2. Map each basename to thumbnail hash (GNOME uses MD5 of absolute `file://` URI):
   ```python
   import hashlib
   from pathlib import Path
   uri = "file:///home/kpihx/Downloads/RAS/example.png"
   h = hashlib.md5(uri.encode()).hexdigest()
   for size in ("x-large", "large", "normal"):
       p = Path.home() / ".cache/thumbnails" / size / f"{h}.png"
       if p.exists():
           print(size, p)
   ```

3. Copy hits to a recovery folder with **original names**:
   ```bash
   RECUP=~/Recovery_candidates_$(date +%Y-%m-%d)/from_thumbnails
   mkdir -p "$RECUP"
   # (automate via script — see session 2026-05-26 MANIFEST.txt)
   ```

**KπX 2026-05-26 result:** **103 files** (~13 MiB) — **13/13** `VeniceAI_*.png` (RAS), **~90** `photo_2026-05-*.jpg` (Telegram Desktop). Quality: **previews only** (max edge ~512 px), not originals.

**Limits:** No thumbnail if the file was never opened in a GNOME app; xbel entries expire; WebP/HEIC may only exist as PNG thumbs.

---

### Tier B — PhotoRec free-space carve (sudo, ext4 mounted OK)

**Why it works:** Carves **file signatures** from **unallocated** ext4 blocks (`freespace`). Survives Trash empty if clusters were not overwritten.

**Agent rule:** Run `sudo` only in **shared tmux** (`default:0.0` — pane already used for recovery). **Do not** `tmux split-window` for sudo. See `k-tmux` / `k-workspace` → Shared interactive gate.

**Scripts (session templates):**

| File | Role |
|------|------|
| `~/Recovery_PhotoRec_2026-05-26/run_photorec_only.sh` | PhotoRec batch, output under `$HOME` |
| `~/Recovery_PhotoRec_2026-05-26/match_recovered.sh` | Post-scan inventory vs xbel names |
| `~/Recovery_PhotoRec_2026-05-26/recovery_photorec.log` | Tee log |

**Launch (tmux pane `default:0.0`):**

```bash
sudo bash ~/Recovery_PhotoRec_2026-05-26/run_photorec_only.sh
```

**Correct PhotoRec 7.2 `/cmd` (single line — no line breaks after commas):**

```bash
photorec /log /d "$PHOTO" /cmd "$PART" \
  partition_none,options,mode_ext2,fileopt,everything,disable,\
  jpg,enable,png,enable,gif,enable,tif,enable,bmp,enable,freespace,search
```

**Invalid / rejected in 7.2 batch mode (silent or immediate exit):**

| Token | Issue |
|-------|--------|
| `jpeg,enable` | Use `jpg,enable` only |
| `webp,enable` / `heic,enable` | Syntax error at `webp` |
| Line breaks inside `/cmd` in shell scripts | Shell splits on commas → broken sub-commands |

**Output layout gotcha:** If `~/Recovery_.../photorec` already exists, PhotoRec writes to `photorec.1`, `photorec.2`, … — adjust `find` and `match_recovered.sh` to search `photorec*`, not only `photorec/`.

**sudo + `$HOME`:** `sudo bash script.sh` sets `HOME=/root` unless overridden. Scripts must set `KPihX_HOME=/home/kpihx` explicitly for output paths.

**KπX 2026-05-26 result:** Scan ~**1 min** on NVMe (partial freespace pass); **~1534** carved images under `photorec.1`–`photorec.3` (anonymous names). Cross-match with xbel + file size + visual review.

**Duration:** Full-partition carve can take **30+ minutes to hours** depending on free space and disk activity.

---

### Tier C — extundelete (directory restore)

```bash
extundelete /dev/nvme0n1p4 --restore-directory "Downloads/RAS"
```

**Fails on mounted root:** `Mounted filesystem detected` — extundelete refuses ext4 while mounted (`/` on `nvme0n1p4`).

**Options:** Boot live USB, mount disk read-only elsewhere, or unmount (not practical on active workstation). Prefer Tier A + B on daily driver.

---

### Tier D — App-specific (Telegram)

Telegram Desktop (snap) stores encrypted `tdata/` — not a folder of loose JPGs. If media still exists in cloud chats: re-export from Telegram app (Saved Messages / chat → export media).

---

## Post-recovery workflow

1. **Inventory carved files:**
   ```bash
   find ~/Recovery_PhotoRec_*/photorec* -type f \( -iname '*.jpg' -o -iname '*.png' \) | wc -l
   bash ~/Recovery_PhotoRec_2026-05-26/match_recovered.sh
   ```

2. **Cross-reference** xbel target list (original names) with carved set (size, dimensions, EXIF dates).

3. **Keep** `Recovery_candidates_*/from_thumbnails/` as quick wins; **promote** full-res matches to `Gdrive/` or project dirs per `k-optim` home media policy.

4. **Log** incident in `k-context/references/issues.md` if part of a broader optim/deletion event.

---

## Prevention (k-optim alignment)

- `Downloads/` is a **transit zone** — empty after each session (`k-optim` → Home Media Directories).
- Before aggressive `clean_work.sh -p` or Trash empty: check xbel + thumbnails if unsure.
- Workstation backup (`ksh backup run`) captures user data — not a substitute for undelete, but limits disaster scope.

---

## Quick reference commands

```bash
# Filesystem
df -T / && lsblk -f /dev/nvme0n1p4

# Trash
ls ~/.local/share/Trash/files/ ~/.local/share/Trash/info/

# Thumbnail cache size
du -sh ~/.cache/thumbnails/

# PhotoRec running?
pgrep -a photorec
tail -f ~/Recovery_PhotoRec_2026-05-26/recovery_photorec.log
```

---

## Changelog

| Date | Notes |
|------|--------|
| 2026-05-26 | Initial doc from RAS + Telegram Desktop recovery session |
