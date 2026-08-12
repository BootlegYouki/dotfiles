# CachyOS Features, Tools & System Configurations

## Automated Sudo Privilege Handling (`$SUDO_PASS`)
Configured environment variable `SUDO_PASS` in `~/.config/fish/conf.d/sudo_pass.fish` (permissions `600`) for non-interactive administrative execution:
```fish
# Automatic sudo invocation pattern
echo $SUDO_PASS | sudo -S <command>
```
*Note*: No plaintext password values are written to public notes or public git repos; the variable reference `$SUDO_PASS` is evaluated dynamically by the shell.

---

## Installed System Shells & Tools
- **Shell**: Fish (`/usr/bin/fish`) with Starship prompt.
- **Terminal**: Ghostty.
- **Session Manager**: UWSM (`uwsm`).
- **Sync**: `rclone` (Syncs `ArchBrain` to `gdrive:ArchBrain` every 15 mins).

---

## Related Notes
- [[btrfs-live-partition-expansion]]
- [[desktop-migration-guide]]
- [[desktop-caelestia-hyprland]]
