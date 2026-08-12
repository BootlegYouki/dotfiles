# Steam & Overwatch 2 Gaming Setup Guide

## System Environment & Specs
- **OS**: CachyOS (Arch Linux based) with Kernel 7.1+
- **Desktop Environment**: Hyprland on Wayland (with UWSM session management)
- **CPU / GPU**: AMD Ryzen 5 5500U with integrated Radeon Graphics (RADV Vulkan driver)
- **RAM**: 16 GB RAM with 15 GB zRAM swap

---

## 1. Prerequisites & Dependencies

### Core Packages
- `steam`: Official Valve digital software delivery client (from `multilib` repository).
- `steam-devices`: System rules for controllers and VR equipment.
- `lib32-vulkan-radeon` & `vulkan-radeon`: 32-bit & 64-bit AMD RADV Vulkan drivers (already installed).
- `gamemode` & `lib32-gamemode`: Optimizes CPU governor, process priorities, and GPU performance during gaming sessions.

### Optional Performance & Compatibility Extras
- `proton-cachyos-slr` / `proton-cachyos-native` or `protonup-qt`: Optimized custom Proton builds for CachyOS / GE-Proton.
- `gamescope`: Micro-compositor for resolution scaling, mouse lock, or custom window management under Wayland.
- `mangohud` & `lib32-mangohud`: On-screen HUD for FPS, temperatures, CPU/GPU load monitoring.

---

## 2. Installation Commands

Run the following command to install Steam and recommended gaming packages:

```bash
sudo pacman -S steam gamemode lib32-gamemode proton-cachyos-slr gamescope
```

---

## 3. Launching Steam on Hyprland

Because the system uses **UWSM** (Universal Wayland Session Manager) under Hyprland:
- Launch via terminal: `uwsm app -- steam`
- Launch via application menu / Caelestia drawer: Click the Steam icon (automatically formatted via desktop entry under UWSM).

---

## 4. Installing & Configuring Overwatch 2

1. Open **Steam** and search for **Overwatch 2** in the Store (it is Free to Play).
2. Click **Install**.
3. Right-click **Overwatch 2** in your Steam Library -> **Properties...** -> **Compatibility**.
   - Check **"Force the use of a specific Steam Play compatibility tool"**.
   - Select **Proton Experimental**, **Proton-CachyOS**, or **GE-Proton**.
4. In **Properties...** -> **General** -> **Launch Options**, set one of the following configurations:

   **Option A: Force Native Wayland (Recommended for zero overhead)**
   ```bash
   PROTON_ENABLE_WAYLAND=1 gamemoderun %command%
   ```
   *Bypasses XWayland entirely, fixing mouse capture, click registration, and scaling issues natively under Hyprland.*

   **Option B: Use Gamescope (Isolated Micro-Compositor)**
   ```bash
   gamescope -W 1920 -H 1080 -r 75 -f -- gamemoderun %command%
   ```
   *Forces gamescope to manage windowing, matching your HDMI-A-1 monitor's 1920x1080@75Hz spec and ensuring mouse containment.*

5. Click **Play**.
   - On the first launch, a browser tab will open to link your **Battle.net** account to your Steam account.

---

## 5. Optimization & Performance Tips for Ryzen 5 5500U (Radeon Graphics)

- **In-Game Video Settings**:
  - **Resolution**: 1920x1080 (or 1600x900 / 1280x720 for higher framerates).
  - **Graphics Quality**: Low Preset.
  - **AMD FSR 1.0 / 2.2**: Enable in-game upscaling if higher FPS is desired (e.g. set Render Scale to Dynamic or 75-85% with FSR Sharpening).
  - **Reduce Buffering**: Set to **ON**.
  - **Frame Rate Cap**: Set custom cap (e.g. 60 FPS, 120 FPS, or Display Based).

- **Shader Compilation (Initial Stuttering)**:
  - When playing for the first time, Mesa RADV compiles shaders on-the-fly. Initial stutters in the first 2-3 matches are normal and disappear as shader caches build.

- **Hyprland Screen Tearing / Unlocked FPS (Optional)**:
  Add the following rule to your Hyprland configuration (`hyprland.conf`) if tearing/low-latency mode is preferred:
  ```ini
  windowrulev2 = immediate, class:^(steam_app_2357570)$
  ```

---

## Related Notes
- [[cachyos-features-and-tools]]
- [[desktop-caelestia-hyprland]]
