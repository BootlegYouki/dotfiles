# ⚙️ Systemd & Service Management Cheatsheet

Quick reference for managing services, daemons, and logs in Arch Linux.

---

## 🔧 Managing System Services

```bash
sudo systemctl start <service>    # Start a service immediately
sudo systemctl stop <service>     # Stop a running service
sudo systemctl restart <service>  # Restart a service
sudo systemctl status <service>   # Check status and recent logs

sudo systemctl enable <service>   # Enable service at boot
sudo systemctl disable <service>  # Disable service from starting at boot
sudo systemctl enable --now <service> # Enable and start immediately
```

---

## 👤 User Services (No `sudo` required)

```bash
systemctl --user status <service>
systemctl --user start <service>
systemctl --user enable --now <service>
```

---

## 📜 Journalctl (Reading System Logs)

```bash
sudo journalctl -u <service> -b     # View logs for a specific service since last boot
sudo journalctl -f                  # Follow live system log feed
sudo journalctl -p err..emerg -b   # View only errors and emergency logs for current boot
```

---

## ☁️ Active Background Timers

### ArchBrain Google Drive Sync (`archbrain-sync.timer`)
Syncs `/home/bootlegyouki/ArchBrain/` to Google Drive (`gdrive:ArchBrain`) every **15 minutes**.

- **Sync Tool:** **`rclone`** (`/home/bootlegyouki/.local/bin/rclone`) — configured with remote destination `gdrive:ArchBrain`
- **Scheduler Tool:** **`systemd user timer`** (`archbrain-sync.timer`) — triggers the sync task every 15 minutes
- **Timer unit:** [`archbrain-sync.timer`](file:///home/bootlegyouki/.config/systemd/user/archbrain-sync.timer) (`OnUnitActiveSec=15min`)
- **Service unit:** [`archbrain-sync.service`](file:///home/bootlegyouki/.config/systemd/user/archbrain-sync.service)
- **Exact Command Executed:**
  ```bash
  /home/bootlegyouki/.local/bin/rclone sync /home/bootlegyouki/ArchBrain gdrive:ArchBrain --exclude ".obsidian/**" --quiet
  ```
- **Check Status / Logs:**
  ```bash
  systemctl --user status archbrain-sync.timer
  systemctl --user status archbrain-sync.service
  journalctl --user -u archbrain-sync.service
  ```
