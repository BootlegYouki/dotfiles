# User System Services

Currently running user-level systemd services (`systemctl --user list-units --type=service --state=active`).

## Hyprland / Caelestia Specific
- **`caelestia-romaji.service`**: Caelestia Romaji Lyrics integration.
- **`hypr-gnome-mouse-sync.service`**: Syncs GNOME Settings Mouse configuration with Hyprland to ensure unified sensitivity.
- **`hypr-kdeconnect-portal.service`**: KDE Connect RemoteDesktop portal for Hyprland.
- **`wayland-wm@hyprland-uwsm.service`**: Main service for Hyprland running under UWSM (Universal Wayland Session Manager).

## Applets & Desktop Integration
- **`app-arch-update-tray.service`**: Cachy-Update Systray Applet for tracking Arch/CachyOS updates.
- **`app-blueman@autostart.service`**: Blueman Applet for Bluetooth management.
- **`app-org.kde.kdeconnect.daemon.service`**: KDE Connect daemon for phone integration.

## Audio & Media
- **`pipewire.service`**: PipeWire Multimedia Service.
- **`pipewire-pulse.service`**: PipeWire PulseAudio compatibility layer.
- **`wireplumber.service`**: Multimedia Service Session Manager.

## Portals & Core Services
- **`xdg-desktop-portal-hyprland.service`**: Portal service (Hyprland implementation).
- **`xdg-desktop-portal-gtk.service`**: Portal service (GTK/GNOME implementation).
- **`xdg-desktop-portal.service`**: Core XDG portal service.
- **`dbus-broker.service`**: D-Bus User Message Bus.
- **`ydotool.service`**: Starts ydotoold service for generic input automation.

## Related Notes
- [[caelestia-hyprland]]
- [[custom-scripts]]
