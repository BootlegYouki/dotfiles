# ⚡ Genshin Impact Rapid F-Spam Macro

## Overview
A lightweight custom background daemon that intercepts the physical `F` key and outputs rapid `F` key down/up clicks (~10 times per second) while held down. 

It runs silently in the background and uses Hyprland's UNIX IPC socket to detect the active window. It automatically activates **only** when Genshin Impact has window focus, allowing you to type and use keyboard shortcuts normally everywhere else.

---

## Files Installed
- **Python Script:** [`genshin_f_macro.py`](file:///home/youki/genshin_f_macro.py)
- **Systemd Service:** `/etc/systemd/system/genshin-f-macro.service` (Enabled to start on boot)

---

## How to Control the Macro
The macro starts automatically when you boot your system and requires zero manual interaction. However, you can manage the daemon using these commands:

```bash
# Disable macro entirely (prevents auto-start on boot)
sudo systemctl disable --now genshin-f-macro

# Enable macro (restores auto-start on boot)
sudo systemctl enable --now genshin-f-macro

# Stop the macro daemon temporarily
sudo systemctl stop genshin-f-macro

# Check background daemon logs and status
sudo systemctl status genshin-f-macro
```

> [!NOTE]
> When active, the background daemon handles all keyboards and modifiers (Shift, Ctrl, Super) transparently by merging their hardware capabilities into a single virtual input device. If you ever experience keyboard issues, running `sudo systemctl stop genshin-f-macro` will instantly release all hardware grabs.

---

## Related Notes
- [[gaming-genshin-impact-cachyos]]
- [[systemd-services]]
