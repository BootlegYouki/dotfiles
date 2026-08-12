# Live Btrfs Partition Expansion & Shrinking Guide (512GB SSD)

## System Storage Status
- **Physical Drive**: `/dev/nvme0n1` (465.8 GiB / 500-512 GB Kingston NVMe SSD).
- **Partitioning**:
  - `/dev/nvme0n1p1`: 2 GiB `/boot`
  - `/dev/nvme0n1p2`: 463.8 GiB `btrfs` (`/` and `/home`)

---

## Live Expansion Steps (Zero Downtime / No Reboot Required)

```bash
# 1. Expand Partition 2 to use 100% of physical drive
sudo parted /dev/nvme0n1 resizepart 2 100%

# 2. Live expand the Btrfs filesystem online
sudo btrfs filesystem resize max /
```

---

## Live Shrinking Steps (Recreating Unallocated Space)
Btrfs supports **live online shrinking** without rebooting or data loss.

### Workflow:
1. **Shrink Btrfs Filesystem First**:
   ```bash
   # Shrink Btrfs filesystem by 100GB (or set fixed size like 350G)
   sudo btrfs filesystem resize -100G /
   ```
2. **Shrink Partition End Sector**:
   ```bash
   # Shrink partition 2 to match new filesystem boundary (e.g. 360GB)
   sudo parted /dev/nvme0n1 resizepart 2 360GB
   ```

*Note*: Ensure the shrink target leaves at least 50–100 GB of free buffer space above current used disk space. Perform shrinking operations after large game downloads complete.

---

## Related Notes
- [[genshin-download-disk-full]]
- [[gaming-genshin-impact-cachyos]]
- [[cachyos-features-and-tools]]
