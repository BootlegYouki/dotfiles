# Moonlight Starting RTSP Handshake Failed (Error 110)

## Problem Description
When initiating a stream session in **Moonlight Game Streaming**, the client displays an error dialog:
```
Starting RTSP handshake failed: Error 110
Check your firewall and port forwarding rules for port(s): TCP 48010, UDP 48000, UDP 48010
```

## Root Cause Analysis
- **Error 110 (`ETIMEDOUT` / Connection Timed Out / Refused)** occurs when Moonlight cannot establish an initial RTSP session with the Sunshine host.
- In Tailscale setups:
  - Tailscale network connectivity might be active (`tailscale ping` succeeds with low latency), but the Sunshine streaming daemon on the host (`100.121.200.114`) is either:
    1. **Not running** (Sunshine process/service is stopped or crashed).
    2. **Blocked by Firewall** on the host machine (ports `TCP 48010`, `TCP 47984`, `TCP 47989`, `UDP 47998-48010` dropped/rejected).
    3. Not bound to `0.0.0.0` or the Tailscale interface (`tailscale0`).

---

## Resolution Steps

### 1. Verify and Start Sunshine on the Host
On the host machine (`Rious-Lenovo-Ideapad-Gaming-3-15IAH7`):
- **Linux (systemd user service)**:
  ```bash
  systemctl --user status sunshine
  systemctl --user restart sunshine
  ```
- **Linux (manual run / debug)**:
  ```bash
  sunshine
  ```
- **Windows**:
  - Start Sunshine from the Start Menu or Services (`SunshineService`).

### 2. Configure Host Firewall Rules
Ensure the host machine allows incoming Sunshine and Tailscale connections:

#### Linux (UFW):
```bash
# Allow Tailscale interface completely:
sudo ufw allow in on tailscale0

# Or explicitly allow Sunshine ports:
sudo ufw allow 47984,47989,47990,48010/tcp
sudo ufw allow 47998,47999,48000,48002,48010/udp
sudo ufw reload
```

#### Linux (firewalld):
```bash
sudo firewall-cmd --zone=trusted --add-interface=tailscale0 --permanent
sudo firewall-cmd --reload
```

#### Windows Defender Firewall:
- Add an inbound rule allowing `sunshine.exe` or open TCP ports `47984, 47989, 47990, 48010` and UDP ports `47998, 47999, 48000, 48002, 48010`.

---

## Verification
From the client machine (`youki`):
```bash
# Test TCP ports to host over Tailscale
nc -zv -w 3 100.121.200.114 47989
nc -zv -w 3 100.121.200.114 48010
```
When ports return `open` / `succeeded`, launch Moonlight and start streaming.

## Related Notes
- [[01-Cheatsheets/system-services]]
