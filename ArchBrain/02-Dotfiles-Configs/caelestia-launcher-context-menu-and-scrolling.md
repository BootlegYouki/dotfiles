# Caelestia Launcher Context Menu & Smooth Scrolling

## Overview
Custom extensions and bug fixes applied to the Caelestia App Launcher (`quickshell-git` / `caelestia-shell` QML).

---

## 1. Right-Click Context Menu for Apps
In `~/.config/quickshell/caelestia/modules/launcher/items/AppItem.qml`:
- Right-clicking any application entry opens a Material 3 context menu:
  - **Run**: Launches the app (`Apps.launch`) and dismisses the launcher.
  - **Locate Folder**: Invokes `caelestia-app-action locate <app-id>`, which opens Nautilus with the `.desktop` file highlighted and selected.
  - **Uninstall**: Invokes `ghostty -e caelestia-app-action uninstall <app-id>`, which detects package ownership (Pacman/AUR vs Flatpak vs local shortcut) and prompts for uninstallation.
- Single active menu coordinator: Right-clicking a second app closes the previous app's menu automatically.

---

## 2. Smooth Mouse Wheel Scrolling Fix
In `~/.config/quickshell/caelestia/modules/launcher/AppList.qml`:
- **Root Cause of Sluggishness**: `highlightRangeMode: ListView.ApplyRange` was forcing the selected item (index 0) to stay within the visible screen area, fighting mouse wheel scrolls and snapping `contentY` back to the top.
- **Fix Applied**:
  - Set `highlightRangeMode: ListView.NoHighlightRange` to eliminate scroll resistance.
  - Added smooth cubic animation on `contentY` (`duration: 120`, `Easing.OutCubic`).
  - Set mouse wheel scroll step to 3 full items (~170px) per notch with active menu dismissal.

---

## 3. Associated Scripts & Entries
- **Helper Script**: `~/.local/bin/caelestia-app-action`
- **Windows 10 Entry**: `~/.local/share/applications/windows-10.desktop`
- **Default File Manager**: Nautilus (`Super + E`)

---

## Related Notes
- [[caelestia-hyprland]]
- [[windows-testing-quickemu]]
- [[launching-apps]]
