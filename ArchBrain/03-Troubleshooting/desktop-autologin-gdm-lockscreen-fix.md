# ⚡ Getty tty1 Autologin & Caelestia Lockscreen Setup

Documentation of the lightweight, 0-RAM Getty `tty1` autologin system replacing GDM.

---

## 🛑 Why GDM Was Replaced
- **GDM** consumed ~100MB of RAM and ran unnecessary GNOME background services even though autologin bypassed the GDM login screen.
- **Getty tty1 Autologin** uses systemd's built-in `agetty` (0 MB extra RAM) to automatically log in the user on `tty1` at boot and launch Hyprland via UWSM instantly.

---

## 🛠️ Configuration Details

### 1. Getty Autologin Override (`/etc/systemd/system/getty@tty1.service.d/autologin.conf`)
- **Desktop (`youki`)**:
  ```ini
  [Service]
  ExecStart=
  ExecStart=-/sbin/agetty -o "-p -f -- \u" --noclear --autologin youki %I $TERM
  ```
- **Laptop (`bootlegyouki`)**:
  ```ini
  [Service]
  ExecStart=
  ExecStart=-/sbin/agetty -o "-p -f -- \u" --noclear --autologin bootlegyouki %I $TERM
  ```

### 2. Auto-Start Hyprland via UWSM (`~/.config/fish/config.fish` & `~/.bash_profile`)
When `tty1` finishes autologin, UWSM launches the Wayland session automatically:

```fish
# Auto-start Hyprland via UWSM on tty1 login
if status is-login; and test -z "$DISPLAY"; and test "$(tty)" = "/dev/tty1"
    exec uwsm start hyprland-uwsm.desktop
end
```

### 3. Service Management
- **Disable GDM**: `sudo systemctl disable gdm`
- **Enable Getty tty1**: `sudo systemctl enable getty@tty1.service`

### 4. Caelestia Lockscreen on Boot (`~/.config/hypr/hyprland/execs.lua`)
Upon Hyprland startup, Caelestia Shell immediately locks the session via a high-speed IPC polling loop (polling every 10ms until Quickshell socket binds), preventing autostart apps (Discord, Spotify, Steam) from showing on screen before locking:
```lua
hl.on("hyprland.start", function()
    hl.exec_cmd("caelestia shell -d")
    hl.exec_cmd("until qs ipc -c caelestia call lock lock 2>/dev/null; do sleep 0.01; done")
end)
```

---

## 🔗 Related Notes
- [[desktop-caelestia-hyprland]]
- [[desktop-migration-guide]]
- [[systemd-services]]
