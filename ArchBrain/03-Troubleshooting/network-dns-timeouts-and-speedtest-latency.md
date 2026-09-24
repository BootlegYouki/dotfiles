# Network DNS Timeouts, Browser Hangs & Speedtest Latency Fix

Documentation for resolving intermittent browser page load failures, high-latency Speedtest routing (500ms+), and systemd-resolved/NetworkManager desynchronization on Arch/CachyOS.

---

## Symptoms & Diagnostics

1. **Browser Intermittent Failures**:
   - Websites stalled indefinitely on "Resolving host..." or threw `DNS_PROBE_FINISHED_NO_INTERNET` / `ERR_NAME_NOT_RESOLVED`.
   - Local gateway (`192.168.100.1`) DNS proxy had a 70% query timeout rate (failing domains like `youtube.com`, `facebook.com`, `twitter.com`, `wikipedia.org`, `netflix.com`).
2. **Speedtest Erratic Routing & 500ms Ping**:
   - Legacy Python `speedtest-cli` failed to fetch local coordinates due to deprecated Speedtest.net unauthenticated HTTP endpoints and DNS timeouts, defaulting server selection to **Hong Kong [1118 km away]** with 500.026 ms ping.
3. **IPv6 Precedence Without IPv6 Internet Route**:
   - `tailscale0` assigned a ULA IPv6 address (`fd7a:...`) with `scope global`.
   - Without a default IPv6 internet route, applications attempting dual-stack connections (e.g. `paru`, WebRTC, Chromium Happy Eyeballs) failed with `Network is unreachable (os error 101)`.
4. **Tailscale Health Warning**:
   - Tailscale reported `systemd-resolved and NetworkManager are wired together incorrectly; MagicDNS will probably not work.` because `/etc/resolv.conf` was a foreign static file rather than the `stub-resolv.conf` symlink.

---

## Root Causes

- **ISP Router DNS Proxy (`192.168.100.1`)**: The DHCP-provided gateway DNS server suffered from severe dropped queries and timeouts.
- **RFC 6724 Glibc IPv6 Sorting**: glibc sorted IPv6 before IPv4 due to Tailscale's global-scope ULA address.
- **Unlinked Stub Resolver**: NetworkManager was not configured with `dns=systemd-resolved` and `/etc/resolv.conf` was not pointing to `/run/systemd/resolve/stub-resolv.conf`.

---

## Resolution Steps

### 1. Configure Fast Upstream DNS on Primary Interface
Bypassed the failing ISP router DNS by assigning Cloudflare DNS (`1.1.1.1`, `1.0.0.1`):
```bash
sudo nmcli connection modify "Wired connection 1" ipv4.dns "1.1.1.1 1.0.0.1" ipv4.ignore-auto-dns yes
sudo nmcli connection up "Wired connection 1"
```

### 2. Integrate NetworkManager with systemd-resolved
Created `/etc/NetworkManager/conf.d/dns.conf`:
```ini
[main]
dns=systemd-resolved
```
Symlinked the stub resolver and restarted systemd-resolved:
```bash
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
sudo systemctl restart systemd-resolved
```

### 3. Prioritize IPv4 in `/etc/gai.conf`
Uncommented the IPv4 precedence directive in `/etc/gai.conf`:
```text
precedence ::ffff:0:0/96  100
```
This forces `getaddrinfo(3)` to prefer IPv4 when no native IPv6 default route exists, eliminating `Network is unreachable (os error 101)` connection stalls.

### 4. Restart Tailscale Daemon
Refreshed Tailscale's network monitor and resolved the health check warning:
```bash
sudo systemctl restart tailscaled
```

### 5. Bypass ISP Transpacific Detour via Cloudflare WARP
When ISP (Converge ICT) BGP peering routes Asia game servers (e.g. Genshin Tokyo Alibaba Cloud `47.74.39.4`) across the Pacific to the US and back (causing 340ms+ latency), Cloudflare WARP routes client traffic directly via Cloudflare's private backbone:
```bash
sudo pacman -S cloudflare-warp-bin
sudo systemctl enable --now warp-svc
warp-cli --accept-tos registration new
warp-cli --accept-tos connect
# Exclude Discord from WARP tunnel to prevent RTC/voice/websocket issues:
for domain in discord.com discord.gg discordapp.com discordapp.net discord.media discordcdn.com gateway.discord.gg; do
  warp-cli --accept-tos tunnel host add "$domain"
done
# Disable IPv6 on CloudflareWARP interface to prevent Discord WebRTC RTC stalls:
# /etc/udev/rules.d/99-cloudflare-warp.rules
ACTION=="add", SUBSYSTEM=="net", KERNEL=="CloudflareWARP", RUN+="/usr/bin/sysctl -w net.ipv6.conf.CloudflareWARP.disable_ipv6=1"
```
Tailscale CGNAT (`100.64.0.0/10`) and local LAN (`192.168.0.0/16`) are excluded by default in WARP settings, ensuring zero disruption to local streaming or mesh connectivity.

Automated via `genshin-warp-auto.service` (`~/.local/bin/genshin-warp-auto`): WARP automatically connects when `GenshinImpact.exe` is detected and disconnects upon game exit, keeping normal web browsing and Discord 100% on native fiber.

---

## Verification Results

| Metric | Before Fix | After Fix |
| :--- | :--- | :--- |
| **DNS Query Success Rate** | 30% (7/10 timed out on `192.168.100.1`) | **100% (0 timeouts, 3-50ms latency)** |
| **Speedtest Ping** | 500.026 ms (routed to HK) | **6.809 ms (routed to Metro Manila)** |
| **Speedtest Throughput** | Erratic / choked | **423.43 Mbps Down / 496.85 Mbps Up** |
| **Tailscale Health** | Warning: resolved-nm misconfigured | **Clean (Healthy)** |
| **AUR / Dual-stack Tools** | `os error 101` unreachable | **Instant resolution** |
| **Genshin Tokyo Asia Server** | 342.0 ms (Converge US detour) | **69.3 ms (Cloudflare WARP route)** |

---

## Related Notes
- [[streaming-tailscale-sunshine-moonlight]]
- [[shell-terminal-config]]
- [[core-packages]]
