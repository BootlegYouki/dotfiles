# ⚡ SSD & I/O Responsiveness Troubleshooting (DRAMless SATA SSD Tuning)

## Diagnosis & Root Cause
During heavy disk write operations (downloads, file extractions, Btrfs Copy-on-Write writebacks), the desktop environment became unresponsive. Diagnostics revealed:

1. **Hardware Limitations (DRAMless SATA SSD)**:
   - Primary drive `/dev/sda` is a **Kingston SA400S37480G** (A400 DRAMless SATA SSD).
   - DRAMless SATA SSDs lack dedicated onboard DRAM cache and rely on a small internal SLC write cache. Once filled during sustained writes, latency spikes and NCQ queue congestion stalls I/O.

2. **CachyOS `dirty_bytes` Buffer Cap**:
   - CachyOS default config (`/usr/lib/sysctl.d/70-cachyos-settings.conf`) capped `vm.dirty_bytes` at **256 MB**.
   - On an 11–14 GB RAM system, a 256 MB dirty write buffer fills in fractions of a second during write tasks, immediately blocking application threads to flush directly to disk.

3. **I/O Scheduler (`mq-deadline`)**:
   - SATA SSDs defaulted to `mq-deadline`, which does not prioritize desktop UI interactive tasks over bulk background disk writes.

4. **Btrfs Chunk Saturation**:
   - Data chunks on `/dev/sda2` were **98.23% full**, increasing allocation overhead.

---

## Fixes Applied

### 1. RAM Dirty Write Ratios (`/etc/sysctl.d/99-disk-performance.conf`)
Overrode fixed 256MB dirty bytes with percentage ratios tailored for system RAM:
```sysctl
# Override CachyOS 256MB dirty_bytes limit with percentage ratios for RAM
vm.dirty_background_ratio = 5
vm.dirty_ratio = 15

# Writeback intervals
vm.dirty_expire_centisecs = 3000
vm.dirty_writeback_centisecs = 500
```
- **Result**: RAM dirty write buffer expanded from 256 MB to **~1.65 GB** before applications are forced to wait, absorbing burst writes smoothly in RAM.

### 2. BFQ I/O Scheduler Rule (`/etc/udev/rules.d/60-sata-ssd-scheduler.rules`)
```udev
# Use BFQ for SATA SSDs to prioritize desktop interactivity under I/O load
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"
```
- **Result**: **BFQ (Budget Fair Queueing)** prioritizes interactive desktop GUI processes (Hyprland, Quickshell, audio, input handling) so they are never blocked behind background disk writes.

### 3. Btrfs Chunk Rebalancing
Ran `sudo btrfs balance start -dusage=70 -musage=70 /` to clean up saturated data chunks and distribute storage across physical drives (`sda2` and `sdb1`).

---

## Related Notes
- [[btrfs-multi-device-drive-merge]]
- [[hardware-and-kernel]]
