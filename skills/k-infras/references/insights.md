# k-infras Insights

> Runtime memory: durable lessons, mistakes to avoid, validated fixes.

## 2026-06-11 — Interrupted ntfsresize recovery

- **Don't Ctrl+C ntfsresize during relocation even at 100%:** data relocation completes before the volume header is updated. The MFT is correct but the boot sector total-sectors field (offset 0x28) still holds the old value.
- **ntfs-3g v2022.10.3 --force is misleading:** it only skips the dirty-volume check, NOT the consistency check. After interrupted resize, `--force` alone is not enough — you must fix the boot sector header first.
- **Recovery sequence that works:** parted resizepart → dd boot sector fix → mount -o force. No Windows chkdsk needed.
- **Backup boot sector is NOT needed** for ntfs-3g -o force to mount after primary header fix.
- **Always calculate new total sectors as (new_partition_sectors - 1)** — the field at offset 0x28 is the number of sectors in the volume, stored as a 64-bit little-endian integer.

