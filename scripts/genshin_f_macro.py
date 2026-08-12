import evdev
from evdev import ecodes, InputDevice, UInput
import threading
import time
import sys
import os
import pwd
import signal
import select
import subprocess

def find_keyboards():
    # Only grab devices that have a full set of alpha keys (A-Z).
    # This filters out secondary USB HID interfaces (media keys, macros)
    # that share the same device name but don't carry normal keystrokes.
    ALPHA_KEYS = {
        ecodes.KEY_A, ecodes.KEY_B, ecodes.KEY_C, ecodes.KEY_D,
        ecodes.KEY_E, ecodes.KEY_F, ecodes.KEY_G, ecodes.KEY_H,
        ecodes.KEY_I, ecodes.KEY_J, ecodes.KEY_K, ecodes.KEY_L,
        ecodes.KEY_M, ecodes.KEY_N, ecodes.KEY_O, ecodes.KEY_P,
        ecodes.KEY_Q, ecodes.KEY_R, ecodes.KEY_S, ecodes.KEY_T,
        ecodes.KEY_U, ecodes.KEY_V, ecodes.KEY_W, ecodes.KEY_X,
        ecodes.KEY_Y, ecodes.KEY_Z,
    }
    candidates = []
    for path in evdev.list_devices():
        try:
            dev = InputDevice(path)
            caps = dev.capabilities()
            if ecodes.EV_KEY not in caps:
                continue
            keys = set(caps[ecodes.EV_KEY])
            if not ALPHA_KEYS.issubset(keys):
                continue
            name_lower = dev.name.lower()
            if any(x in name_lower for x in ("mouse", "pointer", "ydotool", "genshin", "touchpad")):
                continue
            candidates.append((dev, keys))
        except Exception:
            continue

    # If we have multiple candidates, only keep the one(s) with the
    # highest key count. The "full" HID interface always has more keys
    # than secondary USB sub-interfaces from the same keyboard.
    if not candidates:
        return []
    max_keys = max(len(k) for _, k in candidates)
    return [dev for dev, keys in candidates if len(keys) == max_keys]

keyboards = find_keyboards()
if not keyboards:
    print("Error: Could not find any keyboard devices.")
    sys.exit(1)

print("Found keyboard devices:")
for kb in keyboards:
    print(f" - {kb.name} ({kb.path})")

# Merge capabilities of all physical keyboards
merged_caps = {}
for kb in keyboards:
    try:
        caps = kb.capabilities()
        for ev_type, ev_codes in caps.items():
            if ev_type not in merged_caps:
                merged_caps[ev_type] = set()
            if isinstance(ev_codes, list):
                merged_caps[ev_type].update(ev_codes)
    except Exception as e:
        print(f"Warning: Could not read capabilities for {kb.name}: {e}")

# Construct the capability dictionary for the virtual keyboard
uinput_caps = {}
for ev_type, ev_codes in merged_caps.items():
    if ev_type != ecodes.EV_SYN:
        uinput_caps[ev_type] = list(ev_codes)

# Create a virtual keyboard with the combined capabilities of all devices
ui = UInput(uinput_caps, name="Genshin Turbo Keyboard")
print("Virtual keyboard created with merged capabilities.")

macro_enabled = False
spam_thread = None
f_intercepted = False

# Read actual physical state of Ctrl keys at startup so we don't
# inherit a stuck-pressed state if the service restarted while Ctrl was held
ctrl_pressed = any(
    kb.active_keys() and any(k in kb.active_keys() for k in (ecodes.KEY_LEFTCTRL, ecodes.KEY_RIGHTCTRL))
    for kb in keyboards
)

# Automatically detect target user and UID based on file ownership
# Defaults to "youki" (UID 1000) if any lookup fails
try:
    file_owner_uid = os.stat(os.path.abspath(__file__)).st_uid
    target_user = pwd.getpwuid(file_owner_uid).pw_name
    target_uid = file_owner_uid
except Exception:
    target_user = "youki"
    target_uid = 1000

def send_notification(enabled):
    state = "Enabled" if enabled else "Disabled"
    icon_path = os.path.expanduser(f"~{target_user}/.local/share/icons/loot_macro_keyboard.svg")
    if not os.path.exists(icon_path):
        icon_path = "/usr/share/icons/Papirus/22x22/devices/input-keyboard.svg"
    cmd = [
        "sudo", "-u", target_user,
        f"DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/{target_uid}/bus",
        "notify-send",
        "-a", "Loot Macro",
        "-i", icon_path,
        "Loot Macro",
        state,
        "-h", "string:x-canonical-private-synchronous:loot-macro"
    ]
    try:
        subprocess.Popen(cmd)
    except Exception as e:
        print(f"Failed to send notification: {e}")

# Rapid F press loop (longer delays to ensure Proton/Wine registers input)
def f_spam_loop():
    global macro_enabled
    while macro_enabled:
        ui.write(ecodes.EV_KEY, ecodes.KEY_F, 1) # Press down
        ui.syn()
        time.sleep(0.05) # Hold for 50ms
        ui.write(ecodes.EV_KEY, ecodes.KEY_F, 0) # Release
        ui.syn()
        time.sleep(0.05) # Wait for 50ms before repeating (10 clicks/sec)
    # Final safety release
    ui.write(ecodes.EV_KEY, ecodes.KEY_F, 0)
    ui.syn()

def cleanup(signum=None, frame=None):
    global macro_enabled
    macro_enabled = False
    print("\nStopping macro and restoring keyboards...")
    for kb in keyboards:
        try:
            kb.ungrab()
        except Exception:
            pass
    try:
        ui.close()
    except Exception:
        pass
    sys.exit(0)

# Register signals for clean exit
signal.signal(signal.SIGINT, cleanup)
signal.signal(signal.SIGTERM, cleanup)

try:
    # Grab all physical keyboards so events go only to this script
    for kb in keyboards:
        kb.grab()
    print("Keyboards grabbed. Press Ctrl+F to toggle rapid F-spam. Press Ctrl+C to stop.")

    # Mapping of file descriptors to keyboard objects
    devices_dict = {kb.fd: kb for kb in keyboards}

    while True:
        # Monitor all keyboard file descriptors for events
        r, w, x = select.select(devices_dict, [], [])
        for fd in r:
            dev = devices_dict[fd]
            for event in dev.read():
                if event.type == ecodes.EV_KEY:
                    # Track control keys
                    if event.code in (ecodes.KEY_LEFTCTRL, ecodes.KEY_RIGHTCTRL):
                        if event.value in (1, 2):  # Down or repeat
                            ctrl_pressed = True
                        elif event.value == 0:     # Up
                            ctrl_pressed = False
                        ui.write(event.type, event.code, event.value)
                        ui.syn()

                    # Track F key
                    elif event.code == ecodes.KEY_F:
                        if event.value == 1:  # Down
                            if ctrl_pressed:
                                macro_enabled = not macro_enabled
                                send_notification(macro_enabled)
                                if macro_enabled:
                                    spam_thread = threading.Thread(target=f_spam_loop)
                                    spam_thread.daemon = True
                                    spam_thread.start()
                                f_intercepted = True
                            else:
                                f_intercepted = False
                                ui.write(event.type, event.code, event.value)
                                ui.syn()
                        elif event.value == 0:  # Up
                            if f_intercepted:
                                f_intercepted = False
                            else:
                                ui.write(event.type, event.code, event.value)
                                ui.syn()
                        else:  # Repeat
                            if not f_intercepted:
                                ui.write(event.type, event.code, event.value)
                                ui.syn()

                    # Forward all other keys
                    else:
                        ui.write(event.type, event.code, event.value)
                        ui.syn()
                else:
                    # Forward non-key events (sync, LEDs, etc.)
                    ui.write(event.type, event.code, event.value)
                    ui.syn()

except Exception as e:
    print(f"Error in macro execution: {e}")
finally:
    cleanup()
