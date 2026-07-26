# NTFS shrink + boot sector recovery — Windows dual-boot prep

> **Canonical reference** for shrinking an NTFS partition from Linux, recovering from interrupted `ntfsresize` via manual boot sector fix, freeing space for Windows 11 dual-boot, and configuring GRUB for dual-boot.
> **Skill owner:** `k-infras` (infrastructure master map).
> **Validated:** 2026-06-11 — NVMe KIOXIA 1024GB, ntfs-3g v2022.10.3, Ubuntu 24.04, Windows 11.

---

## When to use

| Situation | Start here |
|-----------|------------|
| Need to shrink NTFS (Datas) to make room for Windows | Full procedure below |
| `ntfsresize` interrupted mid-shrink → `cluster accounting mismatches` | **Recovery only** (boot sector fix) |
| Windows installer sees no free space | Check `parted print free` |

---

## Safety rules

- **Always use tmux pane** (`default:0.2` or dedicated) for all `sudo` commands — never raw sudo in agent shell.
- **Unmount** the NTFS partition before shrinking (`umount /mnt/datas`).
- **Verify alignment** — new partition end must be 2048-sector aligned (1 MiB).
- **Edit system files with `sudoedit`** (ou `sudo nvim`) — jamais `nvim /etc/...` (readonly trap + InsertLeave autocommands crash).

---

## Full procedure

### 1. Check current layout

```bash
sudo parted /dev/nvme0n1 unit s print free
df -h /mnt/datas
```

Identify target partition (e.g. `p3` = KpihX-Datas on `nvme0n1`).

### 2. Unmount

```bash
sudo umount /mnt/datas
```

### 3. Shrink NTFS filesystem

Calculate target size. If partition is 650G and you want 150G free:

- New filesystem size = 650 - 150 = ~500G
- Use `--size 520G` for safety margin

```bash
sudo ntfsresize --size 520G --verbose /dev/nvme0n1p3
```

**Expect:** ~5-10 min on NVMe, relocating ~86 GB of data from tail to head.

**If interrupted** (Ctrl+C, crash) → go to **Recovery** section below.

### 4. Shrink partition (parted)

Once filesystem is shrunk, truncate the partition to match.

Calculate aligned end sector:

- New end = current start + (new size in sectors) - 1
- Align down to nearest 2048 boundary

```bash
sudo parted /dev/nvme0n1 resizepart 3 1685751807s
# Reply Yes to the confirmation prompt
```

Verify:

```bash
sudo parted /dev/nvme0n1 unit s print free
```

Expected: free space of ~150 GiB after p3.

### 5. Mount and verify

```bash
sudo mount -t ntfs-3g -o force /dev/nvme0n1p3 /mnt/datas
df -h /mnt/datas
ls /mnt/datas/
```

### 6. Install Windows

- Boot from Windows 11 USB
- Select the **unallocated space** (~150G) at end of disk
- Windows creates its own partitions (MSR, Recovery, C:)
- The existing EFI partition (p1) is reused

### 7. Configure GRUB for dual-boot (after Windows install)

After Windows install, GRUB might boot straight to Linux (default) or Windows may take over boot. Fix:

```bash
# 1. Enable os-prober in GRUB config
sudo sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub

# 2. Regenerate GRUB config (detects Windows Boot Manager)
sudo update-grub
```

Expected output includes:
```
Found Windows Boot Manager on /dev/nvme0n1p1@/EFI/Microsoft/Boot/bootmgfw.efi
Adding boot menu entry for UEFI Firmware Settings ...
```

If Windows doesn't appear, check:
```bash
sudo efibootmgr -v                     # verify EFI entries exist
sudo grub-install /dev/nvme0n1         # reinstall GRUB to ESP
```

**Note:** Edit `/etc/default/grub` with `sudoedit` or `sudo nvim` — never `nvim /etc/...` (readonly trap causes nvim autocommand crashes on save).

---



## Recovery: interrupted ntfsresize

**Symptom:**

```
ntfsresize v2022.10.3
...
Relocating needed data ... 100.00 percent completed
^C  (interrupted)
```

Subsequent `ntfsresize` fails with:

```
Filesystem check failed! Totally 42095456 cluster accounting mismatches.
ERROR: NTFS is inconsistent. Run chkdsk /f on Windows then reboot it TWICE!
```

**Root cause:** Data relocation completed (MFT updated), but the volume header was not updated and bitmap is orphaned. `--force` does not bypass consistency check in ntfs-3g 2022.10.3 — only skips dirty-volume check.

**Recovery steps:**

### 1. Resize partition with parted first

Truncate the partition to the intended size. The data is already relocated within this boundary.

```bash
sudo parted /dev/nvme0n1 resizepart 3 <new_end_sector>s
```

### 2. Fix NTFS boot sector header

The volume header still stores the old total sector count. Read the old value:

```bash
sudo xxd -s 0x28 -l 8 /dev/nvme0n1p3
```

Write the new total sectors (partition size in sectors - 1) at offset 0x28:

```bash
# Old: 0x51432E2F → New: 0x414D587F (example values)
printf '\x7f\x58\x4d\x41\x00\x00\x00\x00' | \
  sudo dd of=/dev/nvme0n1p3 bs=1 seek=40 count=8 conv=notrunc
```

Verify:

```bash
sudo xxd -s 0x28 -l 8 /dev/nvme0n1p3
```

### 3. Mount with -o force

```bash
sudo mount -t ntfs-3g -o force /dev/nvme0n1p3 /mnt/datas
```

### 4. Verify data integrity

```bash
df -h /mnt/datas
ls /mnt/datas/
```

### 5. Proceed with Windows install

Free space at end of disk is now visible to Windows installer.

---

## NTFS boot sector layout

| Offset | Size | Field | Notes |
|--------|------|-------|-------|
| 0x00 | 3 | Jump instruction | `EB 52 90` |
| 0x03 | 8 | OEM ID | `NTFS    ` |
| 0x0B | 2 | Bytes per sector | `00 02` = 512 |
| 0x0D | 1 | Sectors per cluster | `08` = 4096 bytes |
| 0x28 | 8 | **Total sectors** (QWORD LE) | **Modify this** |
| 0x30 | 8 | MFT cluster number | Do not touch |
| 0x38 | 8 | MFT mirror cluster | Do not touch |
| 0x48 | 8 | Volume serial number | Do not touch |

The backup boot sector (last sector of volume) is NOT required for `ntfs-3g -o force` to mount after a header fix — ntfs-3g only validates the primary sector.

---

## Quick reference

```bash
# Layout
sudo parted /dev/nvme0n1 unit s print free
sudo lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,LABEL

# NTFS header
sudo xxd -s 0x28 -l 8 /dev/nvme0n1p3         # read total sectors
printf '\x00\x00\x00\x00\x00\x00\x00\x00' |   # write new value
  sudo dd of=/dev/nvme0n1p3 bs=1 seek=40 count=8 conv=notrunc

# Mount
sudo mount -t ntfs-3g -o force /dev/nvme0n1p3 /mnt/datas

# Partition shrink (after ntfsresize)
sudo parted /dev/nvme0n1 resizepart 3 <end_sector>s

# Partition info check
sudo ntfsinfo -mf /dev/nvme0n1p3 | grep -E 'Volume|Cluster|Sector|Device|Free'

# GRUB dual-boot (after Windows install)
sudo sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
sudo update-grub
sudo efibootmgr -v
```

---

## Changelog

| Date | Notes |
|------|-------|
| 2026-06-11 | Initial doc from KpihX-Ubuntu dual-boot prep session (interrupted ntfsresize recovery + parted shrink) |
