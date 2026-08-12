# 🚀 CachyOS Hyprland + Caelestia Complete Installation & Restoration Master Guide

This guide is your step-by-step blueprint for a clean reinstall of CachyOS with Caelestia Shell and Hyprland.

---

# 📖 Part 1: CachyOS Calamares Installer Step-by-Step Guide

### Step 1: Booting the Live ISO
1. Insert your CachyOS USB installation drive into your laptop/PC.
2. Power on and press your motherboard's boot menu key (`F12`, `F11`, `F8`, or `Del`).
3. On the CachyOS bootloader screen:
   - For **Nvidia GPUs**: Select `Boot CachyOS (Nvidia Driver)`.
   - For **AMD / Intel GPUs**: Select `Boot CachyOS (Default)`.

---

### Step 2: Calamares Installer Setup
Once the CachyOS Live Desktop loads, the Welcome App will pop up:
1. Click **Launch Installer**.
2. Select **Online Installation** *(Ensures latest package versions)*.

---

### Step 3: Calamares Screen-by-Screen Settings

#### 1. Welcome / Language
- **Language**: English (or your preferred language) -> Click **Next**.

#### 2. Region & Timezone
- **Region**: Select your region (e.g. `Asia`).
- **Zone**: Select your city (e.g. `Manila`). Click **Next**.

#### 3. Keyboard
- Default: `English (US)` -> Click **Next**.

#### 4. Partitioning
- **Target Storage Device**: Select your SSD/NVMe drive.
- **Option**: Choose **Erase Disk**.
- **Filesystem**: Select **`BTRFS`** *(Crucial for snapshot backups and fast subvolume support)*.
- **Swap Option**: Select **`Swap to ZRAM`** *(Default for CachyOS performance)*.
- Click **Next**.

#### 5. Package Selection Screen (CRITICAL)
When you reach the **Packages** selection list screen:
- ✅ **CHECK**: `CachyOS Packages`
- ✅ **CHECK**: `CachyOS shell configuration`
- ✅ **CHECK**: `Base-devel + Common packages`
- ❌ **UNCHECK ALL DESKTOPS**: Leave `KDE`, `GNOME`, `Cosmic`, `Hyprland`, `Niri`, `Xfce4`, etc. **UNCHECKED**.
- *Why*: Our restoration script installs Hyprland + UWSM + Caelestia Shell directly. Keeping all desktops unchecked gives you a clean 0-RAM TTY setup.

#### 6. Package & Driver Configuration
- **Bootloader**: Select **`systemd-boot`** *(Fastest boot times for Arch/CachyOS)*.
- **Audio Server**: **`PipeWire`** *(Default modern audio pipeline)*.
- **Network**: **`NetworkManager`**.
- **Graphics Driver**: Choose the driver matching your GPU (`Nvidia-Open` / `Nvidia-Proprietary` / `AMD-Mesa`).
- **Display Manager**: Select **`None`** / **`No Display Manager`** *(We use 0-RAM Getty tty1 autologin)*.

#### 7. User Setup
- **Name**: Your full name.
- **Username**: Enter your desired username (e.g., `bootlegyouki` for laptop, `youki` for desktop).
- **Password**: Set your user password.
- **Administrator Password**: Check `Use the same password for administrator account`.
- ⚠️ **Do NOT check** "Log in automatically without asking for password" in Calamares *(The restoration script configures Getty tty1 autologin safely)*.

#### 8. Summary & Installation
- Review the configuration details.
- Click **Install** -> Click **Install Now**.
- Wait for installation to complete (~3-5 minutes).
- Once finished, uncheck "Restart now", click **Done**, shut down, and remove your USB drive.

---

# 💻 Part 2: Pre-Handoff Terminal Setup (First Boot into TTY1)

Upon powering on your freshly installed system:

1. System will boot directly into the `tty1` console login prompt.
2. Type your **Username** and **Password** to log in.
3. Install `git`, `github-cli`, and `agy` (Antigravity CLI):
   ```bash
   sudo pacman -S --needed git github-cli
   curl -fsSL https://antigravity.google/install.sh | bash
   ```

---

# ⚡ Part 3: Running the Restoration (Ultra-Simple Command)

To restore your system, just run **this 1 simple line** in TTY1:

```bash
agy "clone https://github.com/BootlegYouki/dotfiles.git and follow the restoration guide in ArchBrain/00-Meta/CachyOS-Restoration-Guide.md"
```

The agent will automatically clone your dotfiles, open this guide, run `restore_setup.sh`, install Flatpaks, and set up your system!

---

# 🤖 Part 4: Master Prompt FOR THE AI AGENT (Internal Instructions)

```text
You are Antigravity. You are tasked with performing a complete, automated system restoration of my CachyOS Hyprland + Caelestia environment from my remote dotfiles and ArchBrain memory bank.

Follow this execution workflow step-by-step:

### Phase 1: Authentication & Repository Setup
1. Verify `git` and `github-cli` (`gh`) are installed.
2. Authenticate with GitHub using `gh auth login` (prompt me if interactive input is required).
3. Clone my dotfiles repository to `~/dotfiles`:
   git clone https://github.com/BootlegYouki/dotfiles.git ~/dotfiles
4. Ensure `~/ArchBrain` is linked:
   ln -sfn ~/dotfiles/ArchBrain ~/ArchBrain

### Phase 2: Execute Master Restoration Script
5. Run the master restoration script which handles dependencies (Pacman & AUR via yay), config deployment, Genshin F-macro systemd service, and Getty tty1 autologin setup:
   chmod +x ~/dotfiles/ArchBrain/02-Dotfiles-Configs/restore_setup.sh
   bash ~/dotfiles/ArchBrain/02-Dotfiles-Configs/restore_setup.sh

### Phase 3: Flatpaks & Additional Apps
6. Configure Flatpak remote and install user Flatpaks if needed:
   flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
   flatpak install --user -y app.twintaillauncher.ttl com.stremio.Stremio md.obsidian.Obsidian com.discordapp.Discord

### Phase 4: Verification & Completion
7. Verify systemd user services are enabled (`caelestia-romaji.service`).
8. Verify systemd system services are enabled (`genshin-f-macro.service`, `getty@tty1.service`).
9. Report "Done" and instruct me to run `sudo reboot`. Upon reboot, getty tty1 will auto-login and start Hyprland via UWSM locked behind Caelestia lockscreen.
```
