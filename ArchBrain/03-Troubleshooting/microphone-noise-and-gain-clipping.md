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
- **Fix:**
  - Lower `Rear Mic Boost` to `1` (+10dB).
  - Set ALSA `Capture` to ~70% (`45` / +16.50dB).
  - Stored mixer settings via `alsactl store`.

```bash
amixer -c 1 sset 'Rear Mic Boost' 1
amixer -c 1 sset 'Capture' 45
sudo alsactl store
```

---

## Discord Refresh Note
If PipeWire is restarted while Discord is open, Discord's audio engine will lose its socket and show an empty device dropdown (`System Default:`).
- **Fix:** Press `Ctrl + R` inside Discord (or restart Discord) to reload the device list.

---

## Related Notes
- [[caelestia-hyprland]]
- [[system-services]]
