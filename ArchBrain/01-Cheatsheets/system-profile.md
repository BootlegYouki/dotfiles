# 💻 System Profile: CachyOS + Caelestia + UWSM

System information and specific environment setup for this Arch Linux installation.

---

## 🔗 Quick Links to System Notes
- ⚡ Hardware & Specs: [[hardware-and-kernel]]
- 🎨 Desktop Shell & Hyprland: [[desktop-caelestia-hyprland]]
- 🎵 Audio & Streaming: [[audio-pipewire-sunshine]]
- 📦 Software & App Inventory: [[installed-applications]]
- 🚀 CachyOS Features & Ecosystem: [[cachyos-features-and-tools]]

---

## 🚀 Distribution: CachyOS
- **Base**: Arch Linux (performance-focused derivative)
- **Kernel**: `linux-cachyos` (utilizes BORE / EEVDF schedulers and x86-64-v3/v4 micro-architecture packages)
- **Package Managers**: `pacman`, `paru`
- **CachyOS Repositories**: High-performance CPU architecture optimized repositories (`x86-64-v3`, `x86-64-v4`).

### Useful CachyOS Commands
```bash
cachyos-rate-mirrors         # Rate & rank fastest CachyOS mirrors
sudo pacman -Syu             # Sync system with optimized CachyOS repos
```

---

## 🛡️ Session Manager: UWSM (Universal Wayland Session Manager)
**UWSM** handles the graphical session under systemd, providing clean scope separation, environment variable inheritance, and proper shutdown signals for Wayland compositors.

### Key UWSM Commands
```bash
uwsm status                  # Check current session & systemd units
uwsm check                   # Check if environment is ready for Wayland session
uwsm stop                    # Stop current Wayland session cleanly
uwsm app -- <app_command>   # Launch application wrapped in a dedicated systemd app unit
```

---

## 🎨 Shell & Desktop: Caelestia (Hyprland Environment)
- **Compositor**: Hyprland v0.56.2 (managed via UWSM)
- **Desktop Shell**: Caelestia framework & shell widgets (via Quickshell)
- **Launcher**: Fuzzel
- **Config Paths**:
  - `~/.config/hypr/` (Hyprland keybinds, window rules, monitors, lua configs)
  - `~/.config/caelestia/` (Shell configuration & theme settings)
  - `~/.config/uwsm/` (UWSM session startup variables & unit drops)
  - `~/.config/fish/` (Fish shell & Starship prompt)

---

## 🎯 Important Rules for AI Troubleshooting
When resolving system issues on this machine:
1. Always respect **UWSM** session management (use `uwsm app -- <cmd>` when launching background GUI daemons or autostart items).
2. When configuring Hyprland or Caelestia keybindings, check `~/.config/hypr/` or `~/.config/caelestia/` before adding overlapping shortcuts.
3. Use `cachyos` repositories and kernels when upgrading hardware drivers or kernel modules.
