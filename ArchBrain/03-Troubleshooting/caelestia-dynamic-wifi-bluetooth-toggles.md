# Dynamic Wi-Fi, Ethernet, Bluetooth, and Dual Monitor Quick Toggle Buttons Fix

## Issue Description
On laptops or systems running Caelestia Shell (QuickShell), the top status bar and the Quick Toggles card in the sidebar did not show Wi-Fi or Bluetooth status icons properly:
1. **Wi-Fi / Ethernet Button**: The Quick Toggle for `wifi` was statically configured to only interact with Ethernet interfaces (`Nmcli.activeEthernet`), leaving laptop Wi-Fi users without a functional Wi-Fi toggle or showing Ethernet icons even when on Wi-Fi.
2. **Top Bar Status Icons**: `StatusIcons.qml` had `active: false` hardcoded on the Wi-Fi (`network`) loader and Bluetooth (`bluetooth`) loader, preventing Wi-Fi signal and Bluetooth status indicators from rendering on the top bar.
3. **Hardware Detection**: Linux BlueZ creates dummy D-Bus manager objects even on desktops without Bluetooth hardware. Using `rfkill list bluetooth` via `Quickshell.Io` reliably hides the Bluetooth toggle when no physical Bluetooth chip exists.
4. **Desktop 2nd Monitor Toggle**: Added a dynamic 2nd Monitor toggle (`display` / `monitor`) that turns the secondary screen (`DP-1`) on/off via `hyprctl eval "hl.dsp.dpms(...)"`.

---

## Technical Solution

### 1. Dynamic Quick Toggles (`~/.config/quickshell/caelestia/modules/utilities/cards/Toggles.qml`)
- **Wi-Fi & Network Toggles**: Updated delegate choices `wifi` and `network` to dynamically evaluate:
  - If Ethernet is connected (`Nmcli.activeEthernet !== null`): Displays `"lan"` icon and toggles Ethernet connection.
  - If Wi-Fi is active/available (`Nmcli.active !== null` or Wi-Fi interface present): Displays dynamic signal icon (`Icons.getNetworkIcon`) or `"wifi"` / `"wifi_off"`, and toggles Wi-Fi radio power (`Nmcli.enableWifi`).
- **Bluetooth Hardware Filter**: Uses `Quickshell.Io` `Process` executing `rfkill list bluetooth`:
  - Returns `false` when no physical Bluetooth adapter exists on desktop.
  - Dynamically renders when Bluetooth hardware is present on laptop.
- **2nd Display Toggle**: Added `display` / `monitor` delegate choice to toggle DPMS power on `DP-1` with 1 click:
  ```qml
  DelegateChoice {
      roleValue: "display"
      delegate: Toggle {
          icon: "desktop_windows"
          checked: sec ? sec.dpmsStatus : true
          onClicked: Hypr.dispatch(`eval hl.dsp.dpms({ action = '${action}', monitor = '${sec.name}' })`)
      }
  }
  ```

### 2. System-Wide XDG Sync (`/etc/xdg/quickshell/caelestia/`)
- Synced updated QML files (`Toggles.qml`, `StatusIcons.qml`) to `/etc/xdg/quickshell/caelestia/` so Quickshell system-wide launcher loads the updated code immediately.

---

## Related Notes
- [[caelestia-ui-fixes]]
- [[quickshell-entrylist-filter-fix]]
- [[desktop-caelestia-hyprland]]
