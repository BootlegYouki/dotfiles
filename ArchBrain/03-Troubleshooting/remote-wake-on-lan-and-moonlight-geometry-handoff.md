# Remote Wake-on-LAN & Moonlight Geometry Architecture Handoff

Comprehensive system documentation covering the Raspberry Pi Pico W Wake-on-LAN Telegram bot deployment, Converge CGNAT bypass, and Sunshine multi-monitor display auto-toggle hooks.

---

## Complete Handoff Document
For full engineering specifications, disassembly evidence, and troubleshooting procedures, inspect:
- Root Project Handoff: [`/home/youki/PROJECT_HANDOFF_WOL_MOONLIGHT.md`](file:///home/youki/PROJECT_HANDOFF_WOL_MOONLIGHT.md)
- Private Git Repository: `https://github.com/BootlegYouki/pico-wake-on-lan`
- Standalone Deployment Guide: `01-Cheatsheets/remote-wake-on-lan-pico-w-telegram.md`

---

## Quick Reference Summary

### 1. Workstation & Network Profile
- **Target Desktop**: `youki` (CachyOS Linux, kernel `7.2.4-3-cachyos`, Hyprland v0.56.2 Lua)
- **Ethernet NIC**: Realtek RTL8168/8111 PCI Express Gigabit (`enp3s0`, MAC: `30:56:0f:04:0f:3c`, IP: `192.168.100.11`)
- **Gateway**: Huawei EchoLife EG8145V5 (`192.168.100.1`, Converge ICT FiberX CGNAT)
- **Pico W Node**: `192.168.100.93` (MAC: `28:cd:c1:10:3e:39`, 2.4GHz Wi-Fi `HUAWEI-2.4G-t5Rp`)

### 2. Verified Functionality
- **Remote Wake-on-LAN**: Operating. Telegram message `/wake` from `@yohkii` triggers Magic Packet broadcast and powers on the PC.
- **Sunshine Geometry Toggles**: Active via `prep-cmd` hooks in `~/.config/sunshine/apps.json` and `sunshine.conf`. Automatically disables secondary portrait display (`DP-1` at `1920x-420`) during streaming to maintain 1:1 cursor bounds, re-enabling upon session disconnect.
- **iOS Sideloading Protection**: Tailscale configured with "Override local DNS" disabled to preserve the native KhoiNDVN DoH profile (`ocsp.apple.com` sinkholed to `0.0.0.0`).

---

## Related Notes
- [[remote-wake-on-lan-pico-w-telegram]]
- [[streaming-tailscale-sunshine-moonlight]]
- [[multi-monitor-sleep-wake-hpd-and-quick-toggle-fix]]
- [[nexus-multi-monitor-geometry-overflow]]
