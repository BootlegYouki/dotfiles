# Genshin Impact on CachyOS (Linux Setup Guide)

## Overview & Anti-Cheat Status
- **Compatibility**: Genshin Impact runs smoothly on Linux via Proton/Wine.
- **Anti-Cheat**: HoYoverse's anti-cheat automatically activates a user-mode fallback under Proton/Wine.
- **Account Safety**: Safe when using official stock launchers/game files. Avoid third-party DLL mods, FPS unlockers, or memory injectors.

---

## Storage Status (Fresh Install Ready)
- **Drive Free Space**: **365 GB available**.
- **Clean State**: Previous partial download files, manifests, and prefixes have been completely wiped.

---

## Recommended Launchers

### Option 1: Twintail Launcher (Best & Easiest)
A modern, open-source Linux launcher for HoYoverse games (Genshin Impact, Honkai: Star Rail, Zenless Zone Zero). Handles prefixes, proton versions, downloading, and updates seamlessly.

```bash
# Launch Twintail Launcher
uwsm app -- flatpak run app.twintaillauncher.ttl
```

### Option 2: Steam (Non-Steam Game Setup)
1. Download official `HoYoPlay` installer (`.exe`) from the official Genshin website.
2. In Steam: **Games** -> **Add a Non-Steam Game...** -> Select installer.
3. Properties -> **Compatibility** -> Select **Proton Experimental** or **Proton-GE**.
4. Run installer, download Genshin Impact, and update the Steam target path to `HYP.exe` / `GenshinImpact.exe`.

---

## Optimization for AMD Ryzen 5 5500U (Radeon iGPU)

- **Proton Version**: Proton-GE or Proton-CachyOS.
- **In-Game Settings**:
  - **Resolution**: 1920x1080 (or 1600x900 for max FPS stability).
  - **Frame Rate**: 60 FPS.
  - **Shadows & Volumetric Fog**: Low / Medium.
  - **Anti-Aliasing**: SMAA or FSR 2.

---

## Related Notes
- [[btrfs-live-partition-expansion]]
- [[genshin-download-disk-full]]
- [[gaming-steam-overwatch2]]
- [[cachyos-features-and-tools]]
- [[gaming-genshin-turbo-f-macro]]
