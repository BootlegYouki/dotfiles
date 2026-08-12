# 🐧 Linux & Arch Essential Commands Cheatsheet

A quick reference guide for essential Linux terminal commands, storage checks, process management, and Caelestia/Hyprland operations.

---

## 💾 Storage & System Info

| Task | Command | Description |
| :--- | :--- | :--- |
| **Disk Usage** | `df -h -T` | Show free/used space across mounted partitions in human-readable format |
| **Folder Size** | `du -sh <folder>` | Check total disk space used by a specific folder |
| **RAM Usage** | `free -h` | Display total, used, and available RAM |
| **Disk Partitions** | `lsblk` | List block devices and drive partitions |
| **Hardware Info** | `fastfetch` | Display OS, kernel, CPU, GPU, and system overview |

---

## 📦 Package Management (Arch / Pacman)

| Task | Command | Description |
| :--- | :--- | :--- |
| **System Update** | `sudo pacman -Syu` | Synchronize repositories and upgrade all packages |
| **Install Package** | `sudo pacman -S <pkg>` | Install a package from official repos |
| **Remove Package** | `sudo pacman -Rns <pkg>` | Remove a package along with its unneeded dependencies |
| **Search Repo** | `pacman -Ss <keyword>` | Search official repos for a package |
| **List Installed** | `pacman -Qe` | List explicitly installed user packages |
| **Clean Cache** | `sudo pacman -Sc` | Clear old cached package tarballs (`/var/cache/pacman/pkg`) |

---

## ⚙️ Process & Service Management

| Task | Command | Description |
| :--- | :--- | :--- |
| **System Monitor** | `btop` | Interactive process & resource monitor |
| **List Processes** | `ps aux \| grep <name>` | Find running process IDs by name |
| **Kill Process** | `kill -9 <PID>` | Force terminate a process by PID |
| **Kill by Name** | `pkill -9 <name>` | Force terminate processes matching a pattern |
| **User Logs** | `journalctl --user -n 50 --no-pager` | View recent systemd logs for user services |
| **User Service Status**| `systemctl --user status <unit>` | Check status of a user systemd service |

---

## 🎨 Caelestia & Hyprland Shortcuts

### Special Workspaces (Scratchpads)
* **`SUPER + C`** – Toggle **Dev Workspace** (`special:dev` with Zed/VS Code)
* **`SUPER + M`** – Toggle **Music Workspace** (`special:music` with Spotify/Feishin)
* **`SUPER + D`** – Toggle **Communication Workspace** (`special:communication` with Discord/WhatsApp)
* **`SUPER + R`** – Toggle **Todo Workspace** (`special:todo` with Todoist)
* **`SUPER + S`** – Toggle **General Scratchpad** (`special:special`)

### System Controls & Reloads
```bash
# Reload Hyprland configuration
hyprctl reload

# Restart Caelestia Shell
pkill -9 -f quickshell; rm -rf /run/user/1000/quickshell/*; systemd-run --user /usr/bin/qs -c caelestia

# Lock Screen
caelestia shell lock lock

# Quick Application Launcher
SUPER + Space (or Fuzzel)
```

---

## 📁 File Navigation & Search

```bash
# List files with details & hidden files
ls -la

# Search text inside files recursively
grep -rn "search_term" ~/.config/

# Find files by name pattern
find ~ -name "*.json"
```
