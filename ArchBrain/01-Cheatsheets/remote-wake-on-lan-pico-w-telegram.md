# Remote Wake-on-LAN Guide: Raspberry Pi Pico W & Telegram Bot

Complete configuration guide for waking your Linux desktop (`youki`) remotely from anywhere in the world using a Raspberry Pi Pico W plugged directly into your PC's standby USB power, triggered securely via a private Telegram bot.

---

## Architecture Overview

```
[Phone / Laptop anywhere in the world (4G/5G/Remote Wi-Fi)]
                     │
                     ▼ (HTTPS via Telegram Cloud)
            [Telegram Cloud API]
                     │
                     ▼ (Long-polling over Home 2.4GHz Wi-Fi)
       [Raspberry Pi Pico W] (Powered via PC rear USB +5VSB)
                     │
                     ▼ (UDP Broadcast 255.255.255.255:9)
         [Home Router / Local LAN]
                     │
                     ▼ (Ethernet Cable - Magic Packet)
  [Realtek RTL8168 NIC on Motherboard (MAC: 30:56:0f:04:0f:3c)]
                     │
                     ▼ (PME Wake Trigger)
          [PC Powers On & Boots into CachyOS]
                     │
                     ▼ (Auto-starts Tailscale & Sunshine)
[Moonlight Remote Streaming Ready in ~15 Seconds]
```

---

## 1. Workstation Specifications & Prerequisites

- **Target PC**: CachyOS Linux (AMD Ryzen 5 5600G)
- **Ethernet Controller**: Realtek RTL8168/8111/8411 Gigabit Ethernet (`enp3s0`)
- **Target MAC Address**: `30:56:0f:04:0f:3c`
- **Network Connection**: `Wired connection 1`
- **Wake Device**: Raspberry Pi Pico W (RP2040 + CYW43439 2.4GHz Wi-Fi)
- **Power Source**: PC Motherboard Rear USB Port (+5VSB standby rail)

---

## 2. PC & Motherboard Preparation

### Step 2.1: Enable Wake-on-LAN in Linux (NetworkManager)
Run this command once in your terminal:
```bash
sudo nmcli connection modify "Wired connection 1" 802-3-ethernet.wake-on-lan magic
```
Verify the setting:
```bash
nmcli connection show "Wired connection 1" | grep -i 802-3-ethernet.wake-on-lan
# Output should show: 802-3-ethernet.wake-on-lan: magic
```

### Step 2.2: Configure Motherboard BIOS (UEFI) Settings
Restart your PC, press `Del` or `F2` to enter BIOS, and ensure the following power management settings:

1. **Power On By PCI-E / PME / Wake on LAN**: Set to **`Enabled`**.
   *(Allows the onboard Realtek NIC to trigger power-on when it detects a magic packet).*
2. **ErP Ready / Deep Sleep**: Set to **`Disabled`**.
   *(CRITICAL: When ErP is Enabled, the motherboard shuts off all +5VSB standby power to the Ethernet chip and USB ports, preventing WoL and killing power to your Pico W).*
3. **USB Power in Soft Off State (S5)** / **USB Standby Power**: Set to **`Enabled`**.
   *(Ensures the rear USB ports deliver 5V power even when the PC is powered off).*

---

## 3. Create your Private Telegram Bot

1. Open Telegram on your phone or PC and search for **`@BotFather`**.
2. Send the command:
   ```text
   /newbot
   ```
3. Follow the prompts:
   - **Bot name**: e.g., `My Desktop Waker`
   - **Bot username**: e.g., `youki_desktop_wake_bot` (must end with `bot`)
4. BotFather will output an **HTTP API Token**:
   ```text
   Use this token to access the HTTP API:
   7123456789:ABCdefGHIjklMNOpqrsTUVwxyz...
   ```
   *Save this token.*

5. Find your personal Telegram **User ID** so unauthorized users cannot wake your machine:
   - Open Telegram and search for **`@userinfobot`**.
   - Send it any message (or `/start`).
   - It will reply with your profile details including `Id: 123456789`.
   - *Save this numerical ID.*

---

## 4. Raspberry Pi Pico W Setup

### Step 4.1: Install MicroPython on the Pico W
1. Download the official Pico W MicroPython firmware (`.uf2`) from:
   [https://micropython.org/download/RPI_PICO_W/](https://micropython.org/download/RPI_PICO_W/)
2. Hold down the white **BOOTSEL** button on the Pico W while plugging it into your PC with a micro-USB cable.
3. A mass storage drive named `RPI-RP2` will appear in your file manager.
4. Drag and drop the downloaded `.uf2` file onto the `RPI-RP2` drive.
5. The Pico W will reboot automatically and is now running MicroPython.

### Step 4.2: Upload `main.py`
Open **Thonny IDE** (available on Linux: `sudo pacman -S thonny`), select the interpreter **MicroPython (Raspberry Pi Pico)** in the bottom-right corner, and save the following script as **`main.py`** directly onto the Pico W storage:

```python
import network
import socket
import time
import urequests
import ujson
from machine import Pin

# ==================== CONFIGURATION ====================
WIFI_SSID = "YOUR_HOME_WIFI_NAME"
WIFI_PASSWORD = "YOUR_WIFI_PASSWORD"

BOT_TOKEN = "8903322642:AAEMQSdT9JkZv8HpxLau8EOkEIeRwDr2Vqg" # Your BotFather Token
ALLOWED_USER_ID = 6885339389                         # Your User ID (@yohkii)

# Linux Desktop Realtek Ethernet MAC Address
PC_MAC = "30:56:0f:04:0f:3c"
# =======================================================

led = Pin("LED", Pin.OUT)

def connect_wifi():
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    wlan.connect(WIFI_SSID, WIFI_PASSWORD)
    
    print("Connecting to Wi-Fi...")
    attempts = 0
    while not wlan.isconnected() and attempts < 40:
        led.toggle()
        time.sleep(0.3)
        attempts += 1
        
    if wlan.isconnected():
        led.on()
        print("Connected to Wi-Fi! IP Address:", wlan.ifconfig()[0])
        return True
    else:
        led.off()
        print("Failed to connect to Wi-Fi.")
        return False

def send_wake_on_lan(mac_str):
    clean_mac = mac_str.replace(":", "").replace("-", "")
    mac_bytes = bytes([int(clean_mac[i:i+2], 16) for i in range(0, 12, 2)])
    
    # Magic Packet payload: 6x 0xFF followed by 16x MAC address repetitions
    magic_packet = b'\xff' * 6 + mac_bytes * 16
    
    # Broadcast across local network
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    sock.sendto(magic_packet, ("255.255.255.255", 9))
    sock.close()
    print("Wake-on-LAN magic packet broadcasted for:", mac_str)

def send_telegram(chat_id, text):
    url = f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"
    headers = {"Content-Type": "application/json"}
    payload = {"chat_id": chat_id, "text": text}
    try:
        r = urequests.post(url, headers=headers, data=ujson.dumps(payload))
        r.close()
    except Exception as e:
        print("Failed to send Telegram reply:", e)

# Initial Wi-Fi connection
connect_wifi()

last_update_id = 0
base_url = f"https://api.telegram.org/bot{BOT_TOKEN}/getUpdates"

print("Pico W WoL Bot is running and polling Telegram...")

while True:
    try:
        # Long polling Telegram API
        url = f"{base_url}?offset={last_update_id + 1}&timeout=20"
        res = urequests.get(url)
        data = res.json()
        res.close()
        
        if "result" in data:
            for update in data["result"]:
                last_update_id = update["update_id"]
                
                if "message" in update and "text" in update["message"]:
                    msg = update["message"]
                    sender_id = msg.get("from", {}).get("id")
                    chat_id = msg["chat"]["id"]
                    text = msg["text"].strip().lower()
                    
                    # Security filter: ignore any unauthorized sender
                    if sender_id != ALLOWED_USER_ID:
                        print(f"Ignored unauthorized message from ID: {sender_id}")
                        continue
                        
                    if text in ["/wake", "/start", "wake"]:
                        send_wake_on_lan(PC_MAC)
                        send_telegram(chat_id, "⚡ Wake-on-LAN packet sent to your desktop (30:56:0f:04:0f:3c)!")
                    elif text in ["/ping", "ping"]:
                        send_telegram(chat_id, "🟢 Pico W is online and connected to Wi-Fi.")
                    else:
                        send_telegram(chat_id, "Available commands:\n• /wake — Power on PC\n• /ping — Check Pico W status")
                        
    except Exception as e:
        print("Polling exception, retrying in 3s:", e)
        time.sleep(3)
        # Reconnect Wi-Fi if connection dropped
        wlan = network.WLAN(network.STA_IF)
        if not wlan.isconnected():
            connect_wifi()
```

---

## 5. Physical Installation & Standby Power Check

1. Plug the Pico W into a **rear motherboard USB port** using a short micro-USB cable.
2. Shut down your PC:
   ```bash
   systemctl poweroff
   ```
3. Inspect the Pico W's onboard green LED:
   - If the green LED stays lit, the port is successfully supplying **+5VSB standby power**.
   - If the LED turns off when the PC shuts down, move it to another rear USB port (or review BIOS ErP / USB S5 settings in Step 2.2).
4. Tuck the Pico W neatly behind the PC case. It will run 24/7 consuming ~0.15W of power.

---

## 6. How to Test (Simulating Full Remote Access)

To prove this works from outside your home without false triggers from local LAN:

1. **Disconnect Phone from Wi-Fi**:
   - Turn **Wi-Fi OFF** on your phone.
   - Turn **Mobile Data (4G/5G)** ON.
   *(Your phone is now on the public internet, completely isolated from your home network).*
2. **Shut Down the PC**:
   ```bash
   systemctl poweroff
   ```
   Wait for fans to stop. Check that the Ethernet port's standby LED is active.
3. **Send Wake Command**:
   - Open Telegram on your phone (on cellular data).
   - Send `/wake` to your bot.
   - The bot will reply: `⚡ Wake-on-LAN packet sent to your desktop!`
4. **Observe PC**:
   - The PC fans spin up and the machine boots into CachyOS automatically.
5. **Connect via Moonlight**:
   - On your phone, turn on the **Tailscale** VPN.
   - Wait ~15 seconds for your desktop to report online in Tailscale.
   - Open **Moonlight** and stream your desktop remotely!

---

## 7. Troubleshooting & Gotchas

| Symptom | Cause | Solution |
|---|---|---|
| Pico W LED turns off when PC shuts down | Motherboard cut standby power | Disable **ErP Ready** in BIOS; Enable **USB Power in Soft Off (S5)**. |
| Ethernet port LED turns off when PC shuts down | Realtek NIC entered deep sleep | Run `sudo nmcli connection modify "Wired connection 1" 802-3-ethernet.wake-on-lan magic`; enable **Power On By PCI-E** in BIOS. |
| Bot replies to `/wake` but PC does not turn on | Magic packet dropped or power state issue | Ensure PC was shut down cleanly (`systemctl poweroff`). Ensure PC is connected via Ethernet cable (Wi-Fi WoL is unreliable on desktops). |
| Pico W loses Wi-Fi connection over time | Router 2.4GHz sleep / lease expiry | The script includes auto-reconnect handling; assign a static DHCP reservation for the Pico W in your router settings. |

---

## Related Notes
- [[streaming-tailscale-sunshine-moonlight]]
- [[system-services]]
- [[custom-scripts]]
