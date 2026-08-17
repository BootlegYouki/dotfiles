# Building iOS IPAs Locally with Quickemu (KVM) and Expo

## Overview
This cheat sheet provides the complete setup for running macOS Sonoma inside a hardware-accelerated KVM virtual machine using **Quickemu** on Arch Linux / CachyOS, allowing you to compile, sign, and export native iOS `.ipa` binaries directly from **Expo / React Native** projects.

> [!NOTE]
> Hardware virtualization (AMD-V / VT-x) is leveraged through `/dev/kvm`. Because of near-native CPU throughput, local `eas build --local --platform ios` runs at speeds comparable to physical Intel/AMD macOS machines.

---

## 1. Prerequisites & Host Installation (Arch Linux)

Install Quickemu, QEMU desktop, SPICE client, and OVMF firmware:

```bash
# Install Quickemu and dependencies via pacman / AUR
yay -S quickemu spice-gtk edk2-ovmf qemu-desktop samba
```

Verify KVM kernel modules are active:
```bash
lsmod | grep kvm
# Should return kvm and kvm_amd (or kvm_intel)
```

Ensure your user is in the `kvm` and `libvirt` groups:
```bash
sudo usermod -aG kvm $USER
```

---

## 2. Setting Up the macOS Sonoma VM

### A. Download the macOS Sonoma Base Image
Create a dedicated folder for your virtual machines:
```bash
mkdir -p ~/vms/macos-sonoma
cd ~/vms/macos-sonoma

# Download macOS Sonoma configuration and recovery image
quickget macos sonoma
```

### B. Customizing VM Resources
Edit `~/vms/macos-sonoma/macos-sonoma.conf` to allocate CPU, RAM, and enable folder sharing and SSH port forwarding:

```ini
guest_os="macos"
disk_img="macos-sonoma/disk.qcow2"
iso="macos-sonoma/BaseSystem.dmg"

# Resource allocation (Tuned for Ryzen 5600G + 16GB Host RAM)
cpu_cores="4"
ram="8G"
disk_size="80G"

# Port Forwarding: Forward host port 2222 to guest SSH port 22
port_forwards=("2222:22")

# Shared public directory (Exposes ~/vms/macos-sonoma/shared to guest)
public_dir="/home/youki"
```

### C. Launching and Installing macOS
Start the VM with SPICE GUI:
```bash
quickemu --vm macos-sonoma.conf
```

1. In the **macOS Recovery Menu**, select **Disk Utility**.
2. Select the top unformatted QEMU HARDDISK (~80GB), click **Erase**, format as **APFS** with Scheme **GUID Partition Map**, name it `Macintosh HD`.
3. Close Disk Utility, select **Reinstall macOS Sonoma**, and proceed with the installation.
4. Once completed, create your local user account (e.g. `youki`).

---

## 3. Configuring the macOS Guest Environment

Open Terminal inside the macOS guest (or connect via SSH):

### A. Enable Remote Login (SSH)
In macOS **System Settings** -> **General** -> **Sharing**:
- Turn on **Remote Login** (Allow access for your user).

Now from your Arch Linux host, you can access the VM anytime:
```bash
ssh -p 2222 youki@localhost
```

### B. Install Developer Toolchain
Run the following inside macOS Terminal:
```bash
# 1. Install Xcode Command Line Tools
xcode-select --install

# 2. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# 3. Install Node.js LTS, CocoaPods & xcodes
brew install node cocoapods xcodesorg/made/xcodes

# 4. Install Full Xcode (Required for iOS SDK & xcodebuild)
xcodes install --latest --experimental-unxip
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

# 5. Install Expo CLI & EAS CLI
npm install -g eas-cli expo-cli
```

---

## 4. Expo Project Configuration (`eas.json`)

In your Expo project on Linux (e.g., `~/my-expo-app/eas.json`):

```json
{
  "cli": {
    "version": ">= 12.0.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal",
      "ios": {
        "simulator": false
      }
    },
    "production": {
      "ios": {
        "simulator": false
      }
    }
  }
}
```

---

## 5. Building the IPA Locally

### Option 1: Direct Build via SSH
From your Linux terminal, sync your project or mount via Samba/SSHFS and run:

```bash
# SSH into guest and run local EAS build
ssh -p 2222 youki@localhost "cd /Volumes/Shared/my-expo-app && eas build --platform ios --local --output ./dist/app.ipa"
```

### Option 2: Automated Linux Host Script (`build-ios-vm.sh`)

Save this script in your project root or `~/.local/bin/build-ios-vm.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

VM_CONF="$HOME/vms/macos-sonoma/macos-sonoma.conf"
SSH_PORT="2222"
VM_USER="youki"
PROJECT_DIR="$(pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"
VM_DEST="~/workspace/$PROJECT_NAME"

# 1. Check if VM is running; if not, start headless
if ! nc -z localhost "$SSH_PORT" 2>/dev/null; then
    echo "==> Starting macOS Quickemu VM in background..."
    quickemu --vm "$VM_CONF" --display none &
    echo "==> Waiting for macOS SSH to become ready..."
    while ! nc -z localhost "$SSH_PORT"; do
        sleep 2
    done
    echo "==> macOS VM is ready!"
fi

# 2. Sync project files to macOS VM (excluding node_modules / .git)
echo "==> Syncing project files to macOS guest..."
rsync -avz -e "ssh -p $SSH_PORT" \
    --exclude 'node_modules' \
    --exclude '.expo' \
    --exclude '.git' \
    --exclude 'dist' \
    ./ "$VM_USER@localhost:$VM_DEST"

# 3. Execute EAS Local Build inside macOS
echo "==> Running EAS local build inside macOS..."
ssh -p "$SSH_PORT" "$VM_USER@localhost" "
    export PATH=\"/opt/homebrew/bin:\$PATH\"
    cd $VM_DEST
    npm install
    npx eas-cli build --platform ios --local --output ./dist/app.ipa --non-interactive
"

# 4. Fetch the compiled .ipa back to Linux
mkdir -p ./dist
echo "==> Fetching compiled IPA back to host..."
scp -P "$SSH_PORT" "$VM_USER@localhost:$VM_DEST/dist/app.ipa" ./dist/app.ipa

echo "SUCCESS: IPA built successfully at ./dist/app.ipa"
```

---

## 6. Troubleshooting & Optimization

> [!TIP]
> **Performance Tip**: Add `--display none` to run Quickemu completely headless once the initial macOS installation and Xcode setup are finished. This saves GPU/RAM on Arch Linux.

> [!WARNING]
> **Disk Space**: macOS + Xcode requires ~45GB of disk space inside the VM. Always ensure the QCOW2 sparse disk is allocated at 80GB+.

---

## Related Notes
- [[desktop-caelestia-hyprland]]
- [[arch-brain]]
