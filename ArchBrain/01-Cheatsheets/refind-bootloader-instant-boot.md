# rEFInd Bootloader Instant Boot & Timeout Configuration

## Overview
CachyOS uses **rEFInd** (`local/refind`) as its primary UEFI boot manager. By default, rEFInd displays a boot menu countdown.

You cannot remove the bootloader completely because UEFI motherboard firmware requires an EFI boot manager to launch the Linux kernel (`vmlinuz-linux-cachyos`). However, you can set the **timeout to 0** so it boots into CachyOS **instantly without waiting or showing a boot screen**.

---

## Setting Instant Boot (0-Second Countdown)

1. Open `/boot/EFI/refind/refind.conf` (or `/boot/loader/loader.conf`):
   ```bash
   sudo micro /boot/EFI/refind/refind.conf
   ```
2. Locate the `timeout` line and change it to:
   ```ini
   timeout 0
   ```
   *(Or `timeout -1` to skip the menu entirely).*
3. Save and exit.

---

## How to Access Boot Menu in Emergency
If you set `timeout 0` and ever need to access the boot menu in the future:
- Hold **Spacebar** or **Shift** immediately after pressing the power button. rEFInd will pause and display the menu.

---

## Related Notes
- [[cachyos-features-and-tools]]
- [[btrfs-live-partition-expansion]]
