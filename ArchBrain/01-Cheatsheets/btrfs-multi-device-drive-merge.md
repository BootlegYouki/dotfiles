# Btrfs Multi-Device Drive Pooling

## System Configuration
- **Drive 1 (`/dev/sda2`)**: 445.13 GiB Btrfs system volume (`/`, `/home`).
- **Drive 2 (`/dev/sdb1`)**: 223.57 GiB Btrfs secondary drive.
- **Combined Storage**: ~669 GiB unified single Btrfs filesystem pool.

## Operations Performed
1. Unmounted `/dev/sdb1` from `/home/youki/Games`.
2. Expanded root Btrfs volume online:
   ```bash
   sudo btrfs device add -f /dev/sdb1 /
   ```
3. Removed separate `/dev/sdb1` mount entry from `/etc/fstab`.
4. Executed `sudo systemctl daemon-reload`.

> [!WARNING]
> Multi-device Btrfs pooling without RAID1 redundancy means if either physical disk (`sda` or `sdb`) fails, data across the volume can be impacted. Ensure critical files are backed up.

## Related Notes
- [[btrfs-live-partition-expansion]]
