# Dynamic Wi-Fi, Ethernet, and Bluetooth Status & Quick Toggle Buttons Fix

## Issue Description
On laptops or systems running Caelestia Shell (QuickShell), the top status bar and the Quick Toggles card in the sidebar did not show Wi-Fi or Bluetooth status icons properly:
1. **Wi-Fi / Ethernet Button**: The Quick Toggle for `wifi` was statically configured to only interact with Ethernet interfaces (`Nmcli.activeEthernet`), leaving laptop Wi-Fi users without a functional Wi-Fi toggle or showing Ethernet icons even when on Wi-Fi.
2. **Top Bar Status Icons**: `StatusIcons.qml` had `active: false` hardcoded on the Wi-Fi (`network`) loader and Bluetooth (`bluetooth`) loader, preventing Wi-Fi signal and Bluetooth status indicators from rendering on the top bar.
3. **Hardware Detection**: Bluetooth toggle did not check whether Bluetooth adapter hardware existed on the system (`Bluetooth.defaultAdapter !== null`), remaining visible on machines without Bluetooth or missing when initialized dynamically.

---

## Technical Solution

### 1. Dynamic Quick Toggles (`~/.config/quickshell/caelestia/modules/utilities/cards/Toggles.qml`)
- **Wi-Fi & Network Toggles**: Updated delegate choices `wifi` and `network` to dynamically evaluate:
  - If Ethernet is connected (`Nmcli.activeEthernet !== null`): Displays `"lan"` icon and toggles Ethernet connection.
  - If Wi-Fi is active/available (`Nmcli.active !== null` or Wi-Fi interface present): Displays dynamic signal icon (`Icons.getNetworkIcon`) or `"wifi"` / `"wifi_off"`, and toggles Wi-Fi radio power (`Nmcli.enableWifi`).
- **Bluetooth Hardware Filter**: Added `item.id === "bluetooth"` filter condition to `quickToggles` property array:
  - Returns `false` when `Bluetooth.defaultAdapter === null` (hardware lacks Bluetooth).
  - Dynamically renders when `Bluetooth.defaultAdapter` is active.

### 2. Top Bar Status Icons (`~/.config/quickshell/caelestia/modules/bar/components/StatusIcons.qml`)
- **Network Status Loader**: Changed `active` from `false` to:
  ```qml
  active: (Config.bar?.status?.showNetwork ?? true) && (!Nmcli.activeEthernet || Nmcli.active !== null || Nmcli.wirelessInterfaces.length > 0)
  ```
- **Bluetooth Status Loader**: Changed `active` from `false` to:
  ```qml
  active: (Config.bar?.status?.showBluetooth ?? true) && (Bluetooth.defaultAdapter !== null)
  ```

---

## Related Notes
- [[caelestia-ui-fixes]]
- [[quickshell-entrylist-filter-fix]]
- [[desktop-caelestia-hyprland]]
