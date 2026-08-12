# ArchBrain Google Drive Automatic Sync Setup (`rclone`)

## Overview
`ArchBrain` (`/home/youki/ArchBrain/`) is configured to synchronize to a dedicated desktop folder (`gdrive:ArchBrain-Desktop`) on Google Drive to isolate desktop configurations from laptop environments.

---

## Configuration & Files

### 1. `rclone` Remote Target
- Desktop Target: `gdrive:ArchBrain-Desktop`
- Local Path: `/home/youki/ArchBrain`

---

### 2. Systemd Service Unit (`~/.config/systemd/user/archbrain-sync.service`)
```ini
[Unit]
Description=Sync ArchBrain to Google Drive via rclone (Desktop)
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/home/youki/.local/bin/rclone sync /home/youki/ArchBrain gdrive:ArchBrain-Desktop --exclude ".obsidian/**" --quiet
```

---

### 3. Systemd Timer Unit (`~/.config/systemd/user/archbrain-sync.timer`)
- **Status**: Enabled & Active (`systemctl --user enable --now archbrain-sync.timer`).
- **Interval**: Runs automatically every **15 minutes**.

---

## Helpful Commands

```bash
# Check status of sync timer
systemctl --user status archbrain-sync.timer

# Check logs of recent sync runs
journalctl --user-unit archbrain-sync.service -n 20

# Run a manual one-time sync right now
/home/youki/.local/bin/rclone sync /home/youki/ArchBrain gdrive:ArchBrain-Desktop --exclude ".obsidian/**" -P
```

---

## Related Notes
- [[cachyos-features-and-tools]]
- [[desktop-migration-guide]]
