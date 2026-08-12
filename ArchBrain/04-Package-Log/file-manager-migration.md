# File Manager Migration (Thunar -> Nautilus)

## Package Operations
- Uninstalled `thunar` and unused Xfce dependencies (`exo`, `libxfce4ui`, `libxfce4util`, `xfconf`) via `pacman -Rs thunar`.
- Confirmed `org.gnome.Nautilus` is installed as default file manager.

## Config Updates
- **`~/.config/hypr/variables.lua`**: Set `fileExplorer = "nautilus"`.
- **`~/.config/caelestia/hypr-user.lua`**: Updated `SUPER + E` shortcut to launch `nautilus`.
- **`~/.config/hypr/userprefs.conf`**: Updated `SUPER + E` binding to `nautilus`.
- **`~/.config/caelestia/shell.json`**: Set `org.gnome.Nautilus` as launcher favorite.
- **XDG Mime**: Executed `xdg-mime default org.gnome.Nautilus.desktop inode/directory`.

## Related Notes
- [[desktop-caelestia-hyprland]]
