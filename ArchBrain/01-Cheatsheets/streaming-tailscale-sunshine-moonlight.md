# Remote Gaming & Streaming Guide: Tailscale, Sunshine, and Moonlight

Complete configuration and command reference for remote desktop and game streaming on CachyOS / Arch Linux under Hyprland (Wayland) with AMD GPU hardware acceleration.

---

## Overview of Components

- **Tailscale**: Encrypted peer-to-peer mesh VPN allowing secure connections between your PC and client devices from anywhere without port forwarding.
- **Sunshine**: High-performance, self-hosted GameStream host supporting Wayland/PipeWire capture, hardware VA-API video encoding (H.264/HEVC), and low-latency input emulation.
- **Moonlight**: Open-source client app for streaming games and desktop sessions at high framerates and low latency.

---

## 1. Tailscale Setup & Usage

### Start and Connect Tailscale
```bash
# Authenticate and connect to your Tailscale mesh network
sudo tailscale up

# Check status and assigned Tailscale IP (100.x.y.z)
tailscale status
tailscale ip -4
```

### Manage Tailscale Daemon
```bash
# Daemon runs as a systemd service
sudo systemctl status tailscaled
sudo systemctl restart tailscaled
```

> [!NOTE]
> Running `sudo tailscale up` will print an authentication URL. Open that URL in your browser to log into your Tailscale account and pair this machine.

---

## 2. Sunshine (Host) Setup & Usage

### Running Sunshine
```bash
# Start Sunshine as a user service in background
systemctl --user start sunshine

# Enable autostart on user login
systemctl --user enable sunshine

# Or launch manually / via UWSM under Hyprland
uwsm app -- sunshine
```

### Accessing the Web Configuration Interface
1. Open your browser and navigate to:
   ```
   https://localhost:47990
   ```
   *(Accept the self-signed SSL security certificate warning).*
2. On initial launch, set up an **admin username** and **password**.
3. Sunshine configuration is stored at `~/.config/sunshine/sunshine.conf`.

### Pairing with Moonlight
1. Open **Moonlight** on your client device (phone, tablet, laptop, or handheld).
2. Moonlight will discover your PC automatically if on the same network / Tailscale mesh, or you can add your PC by entering its **Tailscale IP** (e.g. `100.x.y.z`).
3. Moonlight will display a 4-digit PIN.
4. Go to Sunshine Web UI (`https://localhost:47990`) -> **PIN** tab -> enter the 4-digit PIN and click **Send**.
5. Your client is now paired and ready to stream.

---

## 3. Moonlight (Client) Usage

### Launching Moonlight
```bash
# Launch Moonlight client via UWSM
uwsm app -- moonlight

# Or launch directly
moonlight
```

---

## 4. Hardware & Permissions Reference

### AMD GPU Hardware Encoding (VA-API)
Hardware video encoding for H.264 and HEVC (H.265 8-bit / 10-bit HDR) is enabled using `mesa` and `libva-mesa-driver`.
Verify VA-API status anytime with:
```bash
vainfo
```

### Input Device Permissions (`/dev/uinput`)
Sunshine requires access to `/dev/uinput` for gamepad/mouse/keyboard emulation. The user must belong to the `input` group:
```bash
sudo usermod -aG input $USER
sudo udevadm control --reload-rules && sudo udevadm trigger
```

### Firewall Rules (UFW)
The following ports and interfaces are configured in UFW:
- **TCP**: `47984, 47989, 47990, 48010`
- **UDP**: `47998, 47999, 48000, 48002, 48010`
- **Tailscale Interface**: `tailscale0` (all traffic allowed across mesh)

---

## Related Notes
- [[desktop-caelestia-hyprland]]
- [[gaming-genshin-impact-cachyos]]
