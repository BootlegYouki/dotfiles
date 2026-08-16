# SSD Maintenance & Automatic TRIM (`fstrim.timer`) Guide

This guide documents the SSD performance optimization, background garbage collection, and automated TRIM service (`fstrim.timer`) configured on this Arch Linux / CachyOS installation.

---

## 1. Overview: Why TRIM is Essential

Solid State Drives (SSDs) store data on NAND flash memory cells organized in **pages** and **blocks**. Unlike mechanical hard drives:
- SSDs **cannot overwrite** existing data in-place; they must first erase an entire NAND block before writing new pages.
- When files are deleted in the OS, the filesystem removes the pointer, but the physical flash cells remain marked as occupied until told otherwise.
- Without TRIM, writing new files triggers a slow **read-erase-modify-write** cycle (causing severe write latency and **Write Amplification**).

> [!NOTE]
> **TRIM** informs the SSD controller which memory blocks belong to deleted files. The drive's internal garbage collection (GC) then clears and resets those flash blocks ahead of time during system idle periods.

---

## 2. Automated Weekly TRIM (`fstrim.timer`)

Systemd provides an integrated timer that automatically runs `fstrim` once per week across all mounted filesystems supporting the discard operation.

### Checking Timer Status
```bash
systemctl status fstrim.timer
```

### Enabling / Starting the Timer
If the timer is ever disabled, re-enable it with:
```bash
sudo systemctl enable --now fstrim.timer
```

### Viewing Upcoming Execution Schedule
```bash
systemctl list-timers fstrim.timer
```

---

## 3. Manual Immediate TRIM

To manually trigger a TRIM sweep across all mounted storage partitions (e.g. after deleting large games or cache directories):

```bash
sudo fstrim -av
```
* `-a` / `--all`: Trims all mounted filesystems that support discard.
* `-v` / `--verbose`: Prints the amount of trimmed storage space per partition.

> [!TIP]
> On this machine's multi-device **Btrfs pool** spanning `/dev/sda2` (Kingston 480GB) and `/dev/sdb1` (SKIHOTAR 240GB), a single run of `sudo fstrim -av` trims both underlying SSDs simultaneously.

---

## 4. SSD Health & Wear Leveling Best Practices

1. **Keep 15–20% Free Space:**
   - SSD controllers use unallocated free space as a high-speed **pseudo-SLC write buffer**. If a drive is >85% full, this buffer shrinks and speeds plummet.
2. **Periodic SMART Health Checks:**
   ```bash
   # Inspect drive temperature, health status, and life remaining:
   sudo smartctl -i -H -A /dev/sda
   sudo smartctl -i -H -A /dev/sdb
   ```
3. **Never Run Defragmentation (`defrag`):**
   - Defragmenting flash storage provides zero performance gain (SSDs have 0ms seek time) and burns through NAND write endurance cycles.

---

## Related Notes
- [[linux-basics-guide]]
- [[custom-scripts]]
