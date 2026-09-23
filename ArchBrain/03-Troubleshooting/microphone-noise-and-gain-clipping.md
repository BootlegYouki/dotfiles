# Microphone Quality & Analog Gain Fix

Documentation of the microphone audio fix for Realtek ALC1220 / Ryzen HD Audio Controller on Arch Linux / PipeWire.

---

## Symptoms & Root Cause

### 1. Extreme White Noise, Electrical Hiss & Clipping Distortion
- **Symptom:** Microphone input sounds distorted, crackly, robotic, or overwhelmed by loud static hiss.
- **Root Cause:**
  1. Realtek ALC1220 analog 3.5mm inputs had ALSA hardware boost maxed out (`Rear Mic Boost = 3 (+30.00dB)`).
  2. ALSA ADC capture gain was also at 100% (`Capture = 63 (+30.00dB)`).
  3. Total gain stacking was **+60dB**, amplifying tiny motherboard circuit electrical noise and immediately clipping voice input.
  4. On system reboot, `alsa-restore.service` or shutdown state saving can restore the maxed-out defaults if not explicitly enforced.
- **Fix:**
  - Lower `Rear Mic Boost` to `1` (+10dB).
  - Set ALSA `Capture` to ~70% (`45` / +16.50dB).
  - Stored mixer settings via `sudo alsactl store`.
  - Added persistent startup enforcement to `~/.config/hypr/hyprland/execs.lua` (`amixer -c Generic_1 sset ...`).

```bash
amixer -c Generic_1 sset 'Rear Mic Boost' 1
amixer -c Generic_1 sset 'Capture' 45
sudo alsactl store
```

### 2. USB Webcam Overriding Default Microphone (Wrong Input Active)
- **Symptom:** Mic not picking up voice, Discord/apps routing to low-quality webcam mic instead of headset/analog mic.
- **Root Cause:**
  - WirePlumber prioritizes USB audio devices (e.g. `PK-635G / REDRAGON Live Camera` priority `2109`) over onboard PCI analog inputs (`Ryzen HD Audio` priority `2009`).
  - WirePlumber dynamically switches the default capture source to the webcam.
- **Fix:**
  - Explicitly set default audio source to the analog capture node:
    `pactl set-default-source alsa_input.pci-0000_04_00.6.analog-stereo`
  - Persisted in `~/.config/hypr/hyprland/execs.lua` and `~/.local/bin/restart-audio`.

---

## Discord Refresh Note
If PipeWire is restarted while Discord is open, Discord's audio engine will lose its socket and show an empty device dropdown (`System Default:`).
- **Fix:** Press `Ctrl + R` inside Discord (or restart Discord) to reload the device list.

---

## Related Notes
- [[caelestia-hyprland]]
- [[system-services]]
