# GUI Software Managers

Graphical package managers and app stores installed on CachyOS.

## Installed Software Centers

### 1. Pamac ("Add/Remove Software")
- **Package**: `pamac-aur` (11.7.5), `libpamac-aur` (11.7.4), `archlinux-appstream-data`
- **Application Name**: `Add/Remove Software`
- **Launch Command**:
  ```bash
  uwsm app -- pamac-manager
  ```
- **Features**:
  - Full Microsoft Store / App Store style interface with rich AppStream metadata (screenshots, categories, descriptions, ratings).
  - Multi-source support: Arch Official Repos, CachyOS Optimized Repos, Arch User Repository (AUR), and Flatpak.
  - Built-in update manager with system tray indicators.

> [!TIP]
> To enable AUR and Flatpak in Pamac: Open Pamac -> Click the Three Dots Menu (`⋮`) -> **Preferences** -> **Third Party** -> Toggle on **Enable AUR support** and **Flatpak**.

---

### 2. CachyOS Package Installer
- **Package**: `cachyos-packageinstaller`
- **Application Name**: `CachyOS Package Installer`
- **Launch Command**:
  ```bash
  uwsm app -- cachyos-packageinstaller
  ```
- **Features**:
  - Curated, optimized software suite specifically tested for CachyOS.
  - One-click setup for gaming environments, web browsers, development runtimes, and optimized kernels.

---

## Related Notes
- [[core-packages]]
- [[system-services]]
