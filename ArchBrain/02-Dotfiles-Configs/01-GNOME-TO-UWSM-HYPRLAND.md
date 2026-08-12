---
title: Removing GNOME/GDM and Using UWSM
date: 2026-08-11
---

# Removing GNOME & Switching to UWSM + Hyprland

If you are migrating from a standard GNOME setup and want to boot directly into the Caelestia/Hyprland shell using UWSM (Universal Wayland Session Manager), follow these exact steps. This is the recommended approach to ensure background systemd services and Wayland environments load cleanly without GDM overhead.

## 1. Disable the GNOME Display Manager (GDM)
First, you need to stop GDM from taking over the boot sequence.
```bash
sudo systemctl disable gdm.service
```
*(Note: Do not uninstall gnome entirely unless you are sure you don't need gnome-keyring or polkit tools, but disabling GDM is sufficient to bypass the login screen).*

## 2. Restore UWSM Configuration
The environment variables needed for Hyprland to run flawlessly under UWSM are backed up in the `~/uwsm` directory. Ensure they are in place:
```bash
# Our backup places them in ~/uwsm. UWSM typically looks in ~/.config/uwsm.
# If they are not already linked:
mkdir -p ~/.config/uwsm
cp -r ~/uwsm/* ~/.config/uwsm/
```

## 3. Enable Auto-Login to TTY1 (Optional but recommended)
To avoid typing your password into a black screen every time you boot, you can enable auto-login for your user on TTY1:
```bash
sudo systemctl edit getty@tty1.service
```
Add the following lines:
```ini
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --autologin youki %I $TERM
```

## 4. Launch UWSM on Login
You must configure your shell to automatically start UWSM when you log into TTY1.

**If you use Fish (which we configured in this setup):**
Add this to the very end of your `~/.config/fish/config.fish`:
```fish
if status is-login
    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
        exec uwsm start hyprland
    end
end
```

**If you use Bash (`~/.bash_profile`):**
```bash
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
    exec uwsm start hyprland
fi
```

## 5. Reboot!
Once configured, restart the system. It will drop you into TTY1 (or auto-login), instantly execute UWSM, and boot directly into your fully configured Caelestia Hyprland desktop.
