# 🌐 Fix: YouTube Infinite Buffering / Loading Loop

**Symptom**: YouTube videos intermittently get stuck in an infinite loading/buffering loop (loading spinner spins forever), requiring a website refresh or page restart to temporarily resume playback.

**Root Cause**: The HTML5 video player synchronizes the media stream with the system audio clock. WirePlumber (v0.5+) by default has an aggressive power-saving feature that suspends audio nodes (`session.suspend-timeout-seconds`) after 5 seconds of inactivity. When resuming, seeking, or opening a video, the latency/timing mismatch during audio device wakeup causes chromium/firefox to lose synchronization, resulting in a playback hang/buffering loop.

> [!NOTE]
> This is a common Linux-specific browser behavior where HTML5 players halt playback entirely if the audio sink takes too long to respond or enters a suspended state.

---

## Fix: Disable WirePlumber Suspend-on-Idle

Create a user-level configuration override to set the suspend timeout to `0` (disabled) for all ALSA audio input and output devices.

### 1. Create Configuration Override File
Write the override rules to [`~/.config/wireplumber/wireplumber.conf.d/50-disable-suspend.conf`](file:///home/youki/.config/wireplumber/wireplumber.conf.d/50-disable-suspend.conf):

```json
monitor.alsa.rules = [
  {
    matches = [
      {
        node.name = "~alsa_output.*"
      },
      {
        node.name = "~alsa_input.*"
      }
    ]
    actions = {
      update-props = {
        session.suspend-timeout-seconds = 0
      }
    }
  }
]
```

### 2. Restart WirePlumber Service
Apply the configuration changes by restarting the user-level WirePlumber systemd service:

```bash
systemctl --user restart wireplumber
```

### 3. Verify Status
Ensure WirePlumber is active and running cleanly:

```bash
systemctl --user status wireplumber
```

---

## Related Notes
- [[audio-pipewire-sunshine]]
- [[system-profile]]
- [[installed-applications]]
