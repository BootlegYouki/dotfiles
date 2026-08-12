# Laptop Thermal Management & Heat Breakdown

## System Diagnostics
- **CPU / GPU Temp**: ~58°C – 61°C (Normal idle/load range for Ryzen 5 5500U is up to 85°C–95°C under heavy load).
- **Power Draw**: ~21W package power draw.
- **Power Profile**: `power-saver` via `power-profiles-daemon`.

---

## Causes of Laptop Heat

### 1. Active Heavy Background Processes
- **Steam & SteamWebHelper**: Active package indexing / shader caching pulling high CPU (~110%+ CPU utilization).
- **Background Apps**: Sunshine streaming daemon, Brave browser, and Hyprland running concurrently.

### 2. Battery Charging Heat
- Charging a Lithium-Ion battery converts electrical energy into chemical energy, generating significant internal heat.
- Combining battery charging heat with CPU/GPU power draw makes the bottom chassis feel noticeably warm/hot.

### 3. Slim Laptop Thermal Design
- HP 15-ef2xxx series uses a single fan and compact heatsink. Heat dissipates through the keyboard deck and bottom ventilation.

---

## Quick Solutions to Reduce Heat

1. **Quit Unused Heavy Apps**:
   - Close Steam when not in use (`pkill steam`).
   - Stop background streaming services like Sunshine if not currently streaming.
2. **Elevate the Laptop**: Ensure the bottom fan intakes are not blocked (use a hard desk surface or laptop stand).
3. **Set Battery Limit (80%)**: Reduces battery charging heat significantly when plugged in.

---

## Related Notes
- [[laptop-power-and-battery-pass-through]]
- [[gaming-steam-overwatch2]]
