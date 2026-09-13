# Windows 10 LTSC Developer Testing VM with Quickemu (KVM)

## Overview
Lightweight, hardware-accelerated Windows 10 Enterprise LTSC KVM virtual machine configured via **Quickemu** on CachyOS. Tailored specifically for compiling, running, and testing Windows `.exe` binaries with minimal host overhead and isolated snapshot capabilities.

> [!NOTE]
> Powered by AMD-V KVM acceleration with paravirtualized VirtIO drivers and SPICE integration. Idle RAM consumption is ~1.2 GB, with 0% background telemetry or bloat.

---

## VM Configuration
* **Config File**: `~/windows-10.conf`
* **Data Directory**: `~/windows-10/`
* **OS Edition**: Windows 10 Enterprise LTSC (Build 19044, x64)
* **vCPUs**: 4 cores
* **RAM**: 4096 MB (Dynamic ballooning)
* **Disk**: 64 GB QCOW2 (sparse, expands only as needed)
* **Display**: Native SDL (`display="sdl"`, direct Wayland OpenGL acceleration)
* **Shared Folder**: `~/Public` (automatically mounted in guest via SPICE WebDAV)

---

## Commands & Workflows

### 1. Launching the VM
```bash
# Launch normal session (changes persist to disk)
quickemu --vm ~/windows-10.conf
```

### 2. Sandbox / Disposable Testing Mode (`--status-quo`)
Ideal for running untrusted test builds, installer experiments, or debug sessions without polluting the disk:
```bash
# Any changes made during the session are completely discarded on exit
quickemu --vm ~/windows-10.conf --status-quo
```

### 3. Snapshot Management
```bash
# Create baseline snapshot (e.g., after installing runtimes)
quickemu --vm ~/windows-10.conf --snapshot create clean-state

# Revert back to snapshot after testing
quickemu --vm ~/windows-10.conf --snapshot apply clean-state

# View snapshot info
quickemu --vm ~/windows-10.conf --snapshot info
```

### 4. File Sharing Between Host and Guest
* Put any test `.exe` builds into `~/Public` on the host.
* Access them inside the VM under the network folder or map it as a drive.

---

## Related Notes
- [[macos-quickemu-expo-ipa-build]]
- [[core-packages]]
- [[launching-apps]]
