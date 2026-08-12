# 🎵 Audio & Streaming: PipeWire & Sunshine

Configuration details for audio routing and remote game streaming on this machine.

---

## 🔊 Audio System Architecture
- **Audio Server**: PipeWire 1.6.8
- **Session Manager**: WirePlumber 1.6.8
- **Primary Hardware Output**: Ryzen HD Audio Controller (Speaker)
- **Primary Hardware Input**: Ryzen HD Audio Controller (Stereo Microphone)

---

## ☀️ Sunshine Integration
This system uses **Sunshine** for low-latency GameStream hosting.

### Virtual Audio Sinks
- `sink-sunshine-stereo`: Stereo virtual audio sink for game/media streaming.
- `sink-sunshine-surround71`: 7.1 Surround virtual audio sink.
- `sink-sunshine-surround51`: 5.1 Surround virtual audio sink.

---

## 🛠️ Audio Troubleshooting & Commands

### Check PipeWire Status & Active Clients
```bash
wpctl status
```

### Inspect WirePlumber Logs
```bash
journalctl --user -u wireplumber -b
```

### Reset PipeWire Audio Daemons
```bash
systemctl --user restart pipewire pipewire-pulse wireplumber
```
