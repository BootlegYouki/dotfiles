# ArchBrain Vault

> [!IMPORTANT]
> This vault is the authoritative, synchronized second brain for Youki's workstation. It documents what is **currently running, installed, and configured** on this machine. Whenever making system changes, updating configs, or resolving issues, keep this vault updated.

---

## Live System & Hardware Profile

| Category | Specification / Configuration |
| :--- | :--- |
| **OS** | **CachyOS Linux** (Arch Linux rolling, kernel `7.2.4-3-cachyos`) |
| **CPU** | **AMD Ryzen 5 5600G** (6 cores / 12 threads @ 3.90–4.40 GHz) |
| **GPU / Graphics** | Integrated **AMD Radeon Vega Cezanne Graphics** (`amdgpu` driver) |
| **Memory** | 16 GB DDR4 RAM + 13.5 GB `zram0` dynamic swap |
| **Filesystem / Storage** | Single-device **Btrfs** on `sda2` (445.1 GB) + 2 GB `/boot` FAT32; dedicated Windows SSD on `sdb` (223.6 GB) |
| **Primary Display** | `HDMI-A-1`: ASUS VA24E 24" 1920x1080 @ 75Hz (0x0, landscape) |
| **Secondary Display** | `DP-1`: Dell P2219H 22" 1920x1080 @ 60Hz (1920x-420, portrait / 270° rotated, `transform = 3`, workspace 11) |
| **Display Manager** | **SDDM** (Qt6) with **Pixie** theme (`/usr/share/sddm/themes/pixie`), dynamic wallpaper sync |
| **Session Wrapper** | **UWSM** (`uwsm start -e -D Hyprland hyprland.desktop`) |
| **Window Manager** | **Hyprland** (configured via Lua: `~/.config/hypr/hyprland.lua` & `hyprland/*.lua`) |
| **Desktop Shell** | **Caelestia Shell** via **Quickshell QML** (`qs -c caelestia -n -d`) with inotify auto-reloader |
| **Terminal & Prompt** | **Ghostty** (Monochrome Caelestia scheme) + **Fish 4.x** + **Starship** + Zoxide + Direnv |
| **Input Daemon** | **`keyd`** (`/etc/keyd/default.conf`) for universal Mac/Windows `Super+C`/`Super+V`/`Super+X` |
| **Backup & Cloud Sync**| **`archbrain-sync.timer`** (hourly `rclone` sync to `gdrive:ArchBrain-Desktop`) + `~/dotfiles` repo |

---

## Vault Navigation Index

### 01. Cheatsheets & Guides (`01-Cheatsheets/`)
- [[custom-scripts]]: Complete catalogue of scripts in `~/.local/bin/` and `~/dotfiles/bin/`.
- [[launching-apps]]: UWSM application execution protocols and desktop entry rules.
- [[linux-basics-guide]]: Core package management, systemctl, disk tools, and shell commands.
- [[ssd-trim-and-maintenance]]: Btrfs balance, fstrim timer, and SSD health routines.
- [[streaming-tailscale-sunshine-moonlight]]: Headless/remote game streaming and VPN setup.
- [[macos-quickemu-expo-ipa-build]]: macOS headless virtualization for iOS Expo/React Native builds.

### 02. Dotfiles & Configurations (`02-Dotfiles-Configs/`)
- [[caelestia-hyprland]]: Hyprland Lua settings, window rules, gaps, blur, and keyboard shortcuts.
- [[sddm-pixie-display-manager]]: SDDM configuration, Pixie theme setup, and dynamic wallpaper color hooks.
- [[shell-terminal-config]]: Ghostty terminal, Fish shell abbreviations, and Starship prompt configurations.
- [[quickshell-caelestia-auto-reload]]: Inotify live-reloading daemon for Caelestia shell widgets.
- [[quickshell-popouts-camera-nightlight]]: Quick toggles, camera popout, and nightlight integration.
- [[restore-setup-script]]: Full recovery script documentation for fresh machine restoration.

### 03. Troubleshooting & Solved Issues (`03-Troubleshooting/`)
- [[multi-monitor-sleep-wake-hpd-and-quick-toggle-fix]]: DisplayPort sleep/wake HPD dropouts and toggle fixes.
- [[multi-monitor-sleep-and-proton-idle-inhibit]]: Sleep inhibition during gaming and media playback.
- [[nexus-multi-monitor-geometry-overflow]]: Vertical secondary monitor coordinate math and bar overflow fixes.
- [[audio-recovery-and-taskbar-widget]]: PipeWire/WirePlumber recovery and fast audio restart script.
- [[microphone-noise-and-gain-clipping]]: Input volume, filter chains, and noise suppression.
- [[vlc-default-player-and-recursion-fix]]: Solving wrapper recursion when VLC is set as default player.
- [[wireless-mouse-phantom-drift]]: Mouse wake drift and GNOME/Hyprland sync daemon.
- [[super-f-fullscreen-window-transparency]]: Fixing opacity bleeding on maximized/fullscreen windows.
- [[network-dns-timeouts-and-speedtest-latency]]: DNS latency fixes and fast speedtest utility.
- [[boot-time-optimization-and-systemd-boot-timeout]]: Optimizing systemd-boot timeouts and loader entries.
- [[moonlight-rtsp-handshake-error-110]]: Resolving Sunshine firewall and RTSP handshake timeouts.

### 04. Packages & System Services (`04-Package-Log/`)
- [[core-packages]]: Comprehensive log of explicitly installed packages and repositories.
- [[system-services]]: Enabled system and user-level systemd daemons and timers.
- [[gui-software-managers]]: Pamac, Octopi, and CachyOS package manager setups.
- [[brave-origin-browser]]: Brave browser flags, extensions, and Wayland flags.
- [[android-sdk-emulator]]: Android SDK, ADB, emulator, and React Native tooling.
- [[canva-desktop-app]]: Canva desktop PWA/Electron integration.

---

## Maintenance Guidelines
1. **Always edit notes in place**: When a configuration changes in `~/.config/` or a new script is added to `~/.local/bin/`, update the corresponding note.
2. **Synchronize to dotfiles**: Mirror changes made in `/home/youki/ArchBrain/` into `/home/youki/dotfiles/ArchBrain/` so version control tracks the knowledge base.
