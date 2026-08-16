# Linux & Arch OS Survival Guide for Beginners

This guide is designed to help you navigate, manage, and understand your Arch Linux / CachyOS system natively. If you've never used a Linux terminal before, these concepts will let you operate the OS confidently without relying on an AI.

---

## 1. Navigating the Filesystem

In Linux, everything is a file, and there are no "C:" or "D:" drives. The entire system starts at the "root" folder, which is simply `/`.

### Important Directories
- **`/` (Root):** The very base of the filesystem. Don't touch files here manually unless you know what you're doing.
- **`/home/your_username/` (`~`):** Your personal sandbox. All your downloads, documents, and configuration files live here.
- **`~/.config/`:** A hidden folder in your home directory where almost every application (like Hyprland, Ghostty, or Fish) stores its settings.
- **`/etc/`:** System-wide configuration files (e.g., networking, bootloader, systemd).
- **`/usr/bin/`:** Where installed applications and commands are actually located.

### Moving Around in the Terminal
- `pwd` -> Print Working Directory. Shows you exactly where you are.
- `cd ~/Downloads` -> Change directory to your Downloads folder.
- `cd ..` -> Go up one folder.
- `ls -la` -> List all files in the current folder, including hidden files (files starting with a `.`).

---

## 2. File Operations

- **Create a folder:** `mkdir my_folder`
- **Create an empty file:** `touch my_file.txt`
- **Move/Rename a file:** `mv my_file.txt ~/Documents/new_name.txt`
- **Copy a file:** `cp my_file.txt backup.txt`
- **Copy a folder:** `cp -r my_folder/ backup_folder/`
- **Delete a file:** `rm my_file.txt`
- **Delete a folder:** `rm -r my_folder/` *(Use with caution!)*

---

## 3. Package Management (Installing Software)

Because this is an Arch-based system, software is installed via **Pacman** (the official package manager) or **Paru** (the community/AUR package manager).

> [!WARNING]
> Never download random `.exe` or `.deb` files from the internet. Always use your package manager!

### Pacman (Official Repositories)
- **Update your entire system:** `sudo pacman -Syu` *(Do this regularly!)*
- **Install an app:** `sudo pacman -S firefox`
- **Remove an app:** `sudo pacman -Rns firefox` (The `-Rns` flag ensures orphaned dependencies are also cleaned up).
- **Search for an app:** `pacman -Ss "web browser"`

### Paru (Arch User Repository - AUR)
The AUR contains community-maintained software (like Spotify, Discord mods, or specific themes).
- **Update AUR apps:** `paru -Sua`
- **Install an AUR app:** `paru -S spotify`
- *(Note: Never run `paru` with `sudo`. It will prompt you for a password when it needs one).*

---

## 4. Managing Background Services (Systemd)

Linux uses `systemd` to manage background services (like Bluetooth, audio, or your custom macros).

### System-Wide Services (Requires Sudo)
- **Check if Bluetooth is running:** `systemctl status bluetooth`
- **Start a service:** `sudo systemctl start bluetooth`
- **Enable a service to start on boot:** `sudo systemctl enable bluetooth`
- **Do both at once:** `sudo systemctl enable --now bluetooth`
- **SSD Auto-TRIM Timer:** `systemctl status fstrim.timer` (See [[ssd-trim-and-maintenance]])

### User-Level Services (No Sudo)
For services that only run when *you* are logged in (like `caelestia-romaji.service`):
- `systemctl --user status caelestia-romaji`
- `systemctl --user restart caelestia-romaji`

---

## 5. Troubleshooting & Logs

When something breaks, Linux logs exactly why. You don't have to guess.

- **View system logs:** `journalctl -xe`
- **View logs for a specific service:** `journalctl -u bluetooth`
- **View logs for user-level services:** `journalctl --user -u caelestia-romaji`
- **Follow logs in real-time:** Add `-f` to any journalctl command (e.g., `journalctl -f`). Press `Ctrl+C` to exit.

---

## 6. Process Management (When Apps Freeze)

If an application freezes, you can force it to close.

1. **Find the app:** Run `btop` in your terminal. This is your visual Task Manager. You can click on processes and press `k` to kill them.
2. **Terminal way:** Use `pgrep` to find the process ID (PID):
   `pgrep firefox`
3. **Kill it:**
   `killall firefox` (Kills all processes named firefox)
   *or*
   `kill -9 1234` (Force kills a specific PID)

---

## 7. Permissions and Sudo

If you try to edit a file in `/etc/` or install an app, you'll get a "Permission Denied" error. 
- **`sudo`:** "SuperUser DO". Put `sudo` before a command to run it as the administrator (root). 
- Example: `sudo micro /etc/locale.conf` allows you to edit system language settings.

## 8. Getting Help Natively
You don't always need to search the web or ask AI.
- **The `man` command:** Type `man pacman` to read the official manual for the pacman command. Press `q` to quit the manual.
- **The `--help` flag:** Almost every command accepts `--help` (e.g., `pacman --help`) for a quick list of options.
