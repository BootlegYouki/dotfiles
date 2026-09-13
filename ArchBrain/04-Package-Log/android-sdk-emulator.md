# Android SDK & Hardware-Accelerated Emulator

Documentation of the Android SDK, OpenJDK 17, and KVM-accelerated Android Emulator installation on CachyOS / Hyprland.

---

## Installed Packages & System Integration
- `jdk17-openjdk`: OpenJDK Java 17 LTS (system default via `archlinux-java`).
- `android-tools`: Pacman package providing system `adb` and `fastboot`.
- `android-udev`: Udev rules for physical Android debugging over USB (user added to `adbusers` & `kvm` groups).
- `Android SDK Tools` (`~/Android/Sdk`):
  - `cmdline-tools/latest` (version 22.0)
  - `platform-tools` (v37.0.1)
  - `emulator` (v37.1.11.0)
  - `platforms;android-34`
  - `build-tools;34.0.0`
  - `system-images;android-34;google_apis;x86_64`

---

## Virtual Device (AVD) Configuration
- **AVD Name**: `Pixel_7_API_34`
- **Location**: `~/.android/avd/Pixel_7_API_34.avd/`
- **GPU Driver**: Host GPU acceleration (`hw.gpu.mode=host`) utilizing AMD Radeon Vulkan (RADV) & Mesa.
- **KVM Acceleration**: Direct AMD-V hardware virtualization via `/dev/kvm`.
- **Keyboard Passthrough**: Host keyboard passthrough enabled (`hw.keyboard=yes`).

---

## Launch Methods
1. **Application Launcher**: Select `Android Emulator (Pixel 7)`.
2. **CLI Runner**: `start-android-emulator` (or `uwsm app -- /home/youki/bin/start-android-emulator`).
3. **Expo / React Native**: Inside project directory, run `npm run android` or `npx expo start` and press `a`.

---

## Related Notes
- [[core-packages]]
- [[launching-apps]]
