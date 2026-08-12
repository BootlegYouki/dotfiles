# Hyprland Immediate Screenshot Saving & Single-Instance Keybinding Fix

## Overview & Architecture
Under Hyprland + Caelestia Shell, pressing **`Super + Shift + S`** (region screenshot) or **`Print`** (fullscreen screenshot) is configured to immediately save PNG image files to `~/Pictures/Screenshots/`, copy the image data to the system clipboard (`wl-copy`), and issue a desktop notification (`notify-send`).

## Issues Encountered & Resolved

### 1. Screenshots Only Copying to Clipboard (No File Saved)
- **Root Cause**: `Super + Shift + S` was invoking `caelestia:screenshotFreezeClip` which only stored screenshots in `~/.cache/caelestia/screenshots` and required interactive notification clicks to save to disk.
- **Fix**: Created [`~/.config/hypr/scripts/screenshot.sh`](file:///home/youki/.config/hypr/scripts/screenshot.sh) to handle direct timestamped file creation, clipboard copy, and desktop notification.

### 2. Double Screenshot Selection Prompt (Double Slurp)
- **Root Cause**: `Super + Shift + S` was registered simultaneously in `hypr-user.lua`, `userprefs.conf`, and `hyprland/keybinds.lua`. Pressing the shortcut executed multiple instances of `slurp` sequentially.
- **Fix**: Centralized keybindings strictly in [`keybinds.lua`](file:///home/youki/.config/hypr/hyprland/keybinds.lua#L158-L160) and added single-instance PID checks (`pidof -x slurp`) inside [`screenshot.sh`](file:///home/youki/.config/hypr/scripts/screenshot.sh).

### 3. Lua Runtime Error (`attempt to concatenate a nil value (global 'home')`)
- **Root Cause**: `home` variable was used in `hypr-user.lua` without local initialization.
- **Fix**: Added `local home = os.getenv("HOME")` at the top of [`hypr-user.lua`](file:///home/youki/.config/caelestia/hypr-user.lua#L2).

### 4. Screen Freeze (Pause) During Selection
- **Root Cause**: Raw `slurp` does not freeze the screen frame during region selection, allowing moving videos and animations to shift.
- **Fix**: Re-enabled Caelestia's native QuickShell screen freeze picker (`caelestia:screenshotFreezeClip` in `AreaPicker.qml`) and customized [`Picker.qml`](file:///home/youki/.config/quickshell/caelestia/modules/areapicker/Picker.qml#L74-L82) to automatically copy and save cropped images directly to `~/Pictures/Screenshots/Screenshot_YYYY-MM-DD_HH-MM-SS.png`.

---

## File Implementation

### 1. QuickShell Native Screen Freeze (`~/.config/quickshell/caelestia/modules/areapicker/Picker.qml`)
```qml
function save(): void {
    const tmpfile = Qt.resolvedUrl(`/tmp/caelestia-picker-${Quickshell.processId}-${Date.now()}.png`);
    CUtils.saveItem(screencopy, tmpfile, Qt.rect(Math.ceil(rsx), Math.ceil(rsy), Math.floor(sw), Math.floor(sh)), path => {
        Quickshell.execDetached(["sh", "-c", "mkdir -p ~/Pictures/Screenshots && file=$HOME/Pictures/Screenshots/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png && cp " + path + " \"$file\" && wl-copy --type image/png < \"$file\" && notify-send -i \"$file\" 'Screenshot Saved' \"Saved to ~/Pictures/Screenshots/$(basename \"$file\")\""]);
        closeAnim.start();
    });
}
```

### 2. Keybinding Registration (`~/.config/hypr/hyprland/keybinds.lua`)
```lua
create_bind(vars.kbScreenshot, hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/screenshot.sh fullscreen"), locked)
create_bind(vars.kbScreenshotFreeze, hl.dsp.global("caelestia:screenshotFreezeClip"))
create_bind(vars.kbScreenshotRegion, hl.dsp.global("caelestia:screenshotFreezeClip"))
```

> [!NOTE]
> Run `hyprctl reload` after modifying keybindings to refresh the desktop session.

---

## Related Notes
- [[desktop-caelestia-hyprland]]
- [[system-customizations-master-blueprint]]
- [[hyprland-workspace-hover-focus]]
