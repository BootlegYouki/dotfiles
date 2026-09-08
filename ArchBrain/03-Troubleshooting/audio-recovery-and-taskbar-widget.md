# Audio Recovery & Caelestia Taskbar Audio Widget

Documentation of the desktop audio recovery mechanism and the customization of the Caelestia Shell taskbar to replace the laptop battery indicator with an interactive audio & mic panel with restart capabilities.

---

## 1. Problem & Symptoms
- **Audio Outage:** Default audio sink (`Ryzen HD Audio Controller Analog Stereo`) and ALSA master levels muted or dropping to `0.00` (-inf dB), cutting all desktop game and media output.
- **Unused Battery Icon:** On desktop systems without a battery, the taskbar defaulted to displaying a power-profile balance icon (`balance`) opening an empty "No battery detected" popout.
- **Widget Sizing & Sliders:** Default audio popout was oversized due to full device radio lists and used plain line sliders instead of the modern Material 3 filled capsule sliders (`FilledSlider`).

---

## 2. Solutions Implemented

### A. Dedicated Audio Recovery Script (`~/.local/bin/restart-audio`)
A recovery command that:
1. Restarts PipeWire user services: `systemctl --user restart wireplumber pipewire-pulse pipewire`.
2. Unmutes and sets the default sink volume to 50%.
3. Restores ALSA Master (70%), PCM (100%), and Front (100%) channels on `Generic_1`.
4. Re-enforces the Realtek ALC1220 hardware mic boost and capture gain fix (`Rear Mic Boost: 1`, `Capture: 45`) from [[microphone-noise-and-gain-clipping]].
5. Sends a desktop notification upon restoration.

### B. Caelestia Shell Customization
1. **Config (`~/.config/caelestia/shell.json`)**:
   - Enabled `"showAudio": true` and `"showBattery": false` under `bar.status`.
2. **Status Icons (`~/.config/quickshell/caelestia/modules/bar/components/StatusIcons.qml`)**:
   - Positioned Audio icon at the bottom of the pill (below Night Light, replacing the old Battery/Scale slot) so the bar order matches: Network -> Camera -> Night Light -> Audio.
   - Scaled with `Tokens.font.icon.medium` so it matches the optical size of surrounding icons.
   - Battery icon conditionally suppressed on desktop systems without a physical laptop battery (`UPower.displayDevice.isLaptopBattery`).
3. **Compact Audio Popout (`~/.config/quickshell/caelestia/modules/bar/popouts/Audio.qml`)**:
   - Redesigned into a sleek, compact panel (`width: 260`, ~170px height) matching the Night Light widget aesthetic.
   - Uses horizontal capsule sliders with integrated handle icons (`FilledSlider`) for both Output Volume and Microphone Volume.
   - Clickable percentage text to easily toggle mute on/off.
   - Full-width **"Restart audio"** button and quick Settings button.

---

## Related Notes
- [[microphone-noise-and-gain-clipping]]
- [[caelestia-hyprland]]
