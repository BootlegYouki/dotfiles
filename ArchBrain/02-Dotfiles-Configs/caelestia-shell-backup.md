---
title: Caelestia Shell Full Backup
date: 2026-08-11
---

# Caelestia Shell Backup

I have created a full backup of the Caelestia shell configuration and the Romaji lyrics daemon we built.

**Backup File:** `caelestia-full-backup.tar.gz` (located in the same directory as this note: `~/ArchBrain/02-Dotfiles-Configs/`).

## Contents
The backup contains:
1. `~/.config/quickshell/caelestia/` - The entire Caelestia shell configuration and UI.
2. `~/.local/bin/caelestia-romaji-daemon` - The multithreaded Python daemon for translation and romanization.
3. `~/.config/systemd/user/caelestia-romaji.service` - The systemd service to manage the daemon.

## How to Restore
To restore this backup at any time, run the following command from your home directory:

```bash
tar -xzvf ~/ArchBrain/02-Dotfiles-Configs/caelestia-full-backup.tar.gz -C ~/
```

This will extract and overwrite the files in their correct original paths (`~/.config/quickshell/caelestia`, `~/.local/bin/`, etc.).

After restoring, you may want to restart the Caelestia shell and the Romaji daemon:
```bash
systemctl --user daemon-reload
systemctl --user restart caelestia-romaji.service
# And reload your Caelestia shell
```
