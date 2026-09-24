# System Services & Timers

Authoritative log of active systemd system-level services, user-level daemons, and automated background timers.

---

## 1. Automated User Timers (`systemctl --user list-timers`)
- **`archbrain-sync.timer`**: Triggers `archbrain-sync.service` every 15 minutes to synchronize `/home/youki/ArchBrain` to Google Drive (`gdrive:ArchBrain-Desktop`) using `rclone`. Excludes `.obsidian/**`.
- **`dotfiles-sync.timer`**: Triggers `dotfiles-sync.service` daily to synchronize configuration changes into `~/dotfiles`.
- **`arch-update.timer`**: Triggers `arch-update.service` daily to check for Arch/CachyOS updates.

---

## 2. Active User Services (`systemctl --user`)

### Desktop Environment & Session
- **`wayland-wm@hyprland-uwsm.service`**: Hyprland compositor running inside UWSM (Universal Wayland Session Manager).
- **`hypr-gnome-mouse-sync.service`**: Daemon syncing GNOME dconf mouse settings into Hyprland.
- **`caelestia-romaji.service`**: Transliteration daemon for fast Caelestia launcher search.
- **`hypr-kdeconnect-portal.service`**: RemoteDesktop portal connecting KDE Connect to Hyprland.
- **`genshin-warp-auto.service`**: Lifecycle daemon automatically connecting Cloudflare WARP when `GenshinImpact.exe` launches and disconnecting upon game exit.

### Applets & Integrations
- **`app-arch-update-tray.service`**: CachyOS / Arch update status indicator tray.
- **`app-blueman@autostart.service`**: Blueman Bluetooth management tray.
- **`app-org.kde.kdeconnect.daemon.service`**: KDE Connect Android/PC device synchronization.

### Audio & Portals
- **`pipewire.service`**: Core multimedia audio graph.
- **`pipewire-pulse.service`**: PulseAudio server emulation.
- **`wireplumber.service`**: PipeWire session and device policy manager.
- **`xdg-desktop-portal-hyprland.service`**: Wayland screen capture and window picker.
- **`xdg-desktop-portal-gtk.service`**: File chooser and GTK dialogs.
- **`xdg-desktop-portal.service`**: Master XDG D-Bus portal.
- **`ydotool.service`**: Virtual input device automation daemon.

---

## 3. Active System-Level Services (`systemctl list-unit-files`)
- **`sddm.service`**: Qt6 display manager loading the Pixie theme.
- **`ananicy-cpp.service`**: Automated CachyOS dynamic process priority / renicing optimizer.
- **`tailscaled.service`**: Tailscale mesh VPN daemon.
- **`proton.VPN.service`**: Proton VPN background connection service.
- **`ufw.service`**: Uncomplicated Firewall protecting local ports.
- **`warp-svc.service`**: Cloudflare WARP daemon for gaming routing optimization and ISP detour bypass.
- **`genshin-f-macro.service`**: Event-driven background macro daemon.
- **`systemd-resolved.service`**: Local caching DNS stub resolver.
- **`systemd-timesyncd.service`**: Network Time Protocol (NTP) clock synchronization.
- **`bluetooth.service`**: BlueZ Bluetooth daemon.
- **`NetworkManager.service`**: System network connection manager.
- **`sshd.service`**: Secure Shell server daemon.

---

## Related Notes
- [[caelestia-hyprland]]
- [[custom-scripts]]
- [[sddm-pixie-display-manager]]
- [[audio-recovery-and-taskbar-widget]]
