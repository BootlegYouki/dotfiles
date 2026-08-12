# Laptop Power Pass-Through & Battery Management Guide

## Why HP 15-ef2xxx Doesn't Have a Manual 80% Option
- **HP Consumer Laptop Firmware**: On HP 15-ef2xxx consumer laptops, HP omits the manual "Battery Health Manager / 80% Charge Limit" menu (which is exclusive to HP business lines like EliteBook/ZBook).
- **Automated Hardware Management**: Instead, HP bakes an automated **Adaptive Battery Optimizer** directly into the motherboard Embedded Controller (EC) hardware.
  - It automatically manages charge voltage, thermal limits, and AC bypass without requiring manual user configuration in BIOS.

---

## How Power Delivery Works When Plugged In
1. When plugged into the wall charger, once the battery hits 100%, the motherboard PMIC hardware automatically stops charging the battery.
2. Power is routed **directly from the wall charger** to the CPU, GPU, display, and components.
3. The battery sits in a standby pass-through state.

---

## Related Notes
- [[laptop-thermal-management]]
- [[gaming-steam-overwatch2]]
- [[cachyos-features-and-tools]]
