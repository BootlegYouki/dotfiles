# ❄️ Caelestia Desktop Dotfiles & System Installer

A complete, turnkey setup and private backup of my custom CachyOS / Hyprland desktop environment, Caelestia shell widgets, SDDM display manager, background daemons, and system documentation.

---

## 🚀 Fresh Installation (Turnkey Setup for CachyOS / Arch Minimal)

On a freshly installed CachyOS system with **no Desktop Environment (CLI only)**:

```bash
# 1. Clone repository
git clone https://github.com/BootlegYouki/dotfiles.git

# 2. Run the automated installer
cd dotfiles
./install.sh
```

The installer will automatically:
1. Update mirrors and install build essentials (`base-devel`, `git`, `yay`).
2. Detect your GPU (NVIDIA / AMD / Intel) and install proper drivers.
3. Install Hyprland, PipeWire audio, Ghostty, fonts, and utilities.
4. Install and configure **SDDM with the Caelestia Locklike theme**.
5. Install Quickshell and the Caelestia desktop shell.
6. Deploy all configs, wallpapers, custom binary tools, and services.
7. Set your default shell to **Fish** with the Starship prompt.

Once complete, reboot with `sudo reboot` to enter the Caelestia SDDM login screen!

---

## 🔄 Daily Updates
To pull the latest changes and re-sync configurations on an existing system:
```bash
./update.sh
```

---

## 📁 Repository Structure

*   **`install.sh`**: Turnkey installer for fresh minimal CachyOS/Arch installations.
*   **`update.sh`**: Incremental config updater.
*   **`.config/hypr/`**: Core Hyprland window manager configurations and keybindings.
*   **`.config/quickshell/caelestia/`**: QML/JavaScript source code for widgets (top bar, lock screen, widgets, lyrics).
*   **`system/etc/sddm.conf.d/`**: SDDM display manager configuration (Caelestia theme).
*   **`bin/`**: Custom scripts and utilities (`dotfiles-sync`, `caelestia-romaji`, `backup-system`, etc.).
*   **`ArchBrain/`**: Complete Obsidian documentation vault (system notes, guides, cheatsheets).

---

## ⚡ How to Manage the Services

### 1. Romaji & Lyrics Translation Daemon
Runs as a user-level service to Romanize and translate Spotify lyrics in real time:
```bash
systemctl --user status caelestia-romaji.service
systemctl --user restart caelestia-romaji.service
```

### 2. Genshin Impact Loot Macro
Automates looting when active in the game window:
```bash
sudo systemctl status genshin-f-macro
sudo systemctl restart genshin-f-macro
```
