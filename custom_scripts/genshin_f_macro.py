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
import glob
import socket
import json

ALPHA_KEYS = {
    ecodes.KEY_A, ecodes.KEY_B, ecodes.KEY_C, ecodes.KEY_D,
    ecodes.KEY_E, ecodes.KEY_F, ecodes.KEY_G, ecodes.KEY_H,
    ecodes.KEY_I, ecodes.KEY_J, ecodes.KEY_K, ecodes.KEY_L,
    ecodes.KEY_M, ecodes.KEY_N, ecodes.KEY_O, ecodes.KEY_P,
    ecodes.KEY_Q, ecodes.KEY_R, ecodes.KEY_S, ecodes.KEY_T,
    ecodes.KEY_U, ecodes.KEY_V, ecodes.KEY_W, ecodes.KEY_X,
    ecodes.KEY_Y, ecodes.KEY_Z,
}

def is_valid_keyboard(path):
    try:
        dev = InputDevice(path)
        caps = dev.capabilities()
        if ecodes.EV_KEY not in caps:
            return None
        keys = set(caps[ecodes.EV_KEY])
        if not ALPHA_KEYS.issubset(keys):
            return None
        if ecodes.KEY_F not in keys:
            return None
        if ecodes.KEY_LEFTCTRL not in keys and ecodes.KEY_RIGHTCTRL not in keys:
            return None
        name_lower = dev.name.lower()
        if any(x in name_lower for x in ("mouse", "pointer", "ydotool", "genshin", "touchpad", "emitter")):
            return None
        return dev
    except Exception:
        return None

# Virtual emitter ONLY for F keypresses - does not hijack physical keyboards
ui = UInput({ecodes.EV_KEY: [ecodes.KEY_F]}, name="Genshin Macro Emitter")
print("Macro emitter created.")

macro_enabled = False
is_genshin_focused = False
spam_thread = None

# Automatically detect target user and UID
try:
    file_owner_uid = os.stat(os.path.abspath(__file__)).st_uid
    target_user = pwd.getpwuid(file_owner_uid).pw_name
    target_uid = file_owner_uid
except Exception:
    target_user = "youki"
    target_uid = 1000

def get_hypr_socket(name=".socket2.sock"):
    candidates = glob.glob(f"/run/user/*/hypr/*/{name}") + glob.glob(f"/run/user/*/hypr/{name}")
    return candidates[0] if candidates else None

def query_active_window():
    sock_path = get_hypr_socket(".socket.sock")
    if not sock_path:
        return "", ""
    try:
        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        s.settimeout(0.5)
        s.connect(sock_path)
        s.sendall(b"j/activewindow")
        data = b""
        while True:
            chunk = s.recv(4096)
            if not chunk:
                break
            data += chunk
        s.close()
        parsed = json.loads(data.decode("utf-8"))
        return parsed.get("class", ""), parsed.get("title", "")
    except Exception:
        return "", ""

def is_genshin_window(win_class, win_title):
    c = (win_class or "").lower()
    t = (win_title or "").lower()
    if "genshin" in t or "原神" in t:
        return True
    if any(x in c for x in ("genshinimpact", "yuanshen")):
        return True
    if c in ("steam_proton", "gamescope", "twintaillauncher") and ("genshin" in t or "原神" in t):
        return True
    return False

def set_macro_indicator(enabled):
    # 1. Update persistent state files in /run/user/<uid>/ and /tmp/
    for state_path in (f"/run/user/{target_uid}/genshin_macro.state", "/tmp/genshin_macro.state"):
        try:
            with open(state_path, "w") as f:
                f.write("1" if enabled else "0")
            os.chmod(state_path, 0o666)
        except Exception:
            pass

    # 2. Instantaneous direct IPC call to Quickshell Caelestia running as target user
    cmd = [
        "sudo", "-u", target_user,
        f"XDG_RUNTIME_DIR=/run/user/{target_uid}",
        f"DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/{target_uid}/bus",
        "/usr/bin/qs", "ipc",
        "-c", "caelestia",
        "--any-display",
        "call", "macro", "set", "true" if enabled else "false"
    ]
    try:
        subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        pass

def hypr_focus_monitor():
    global is_genshin_focused, macro_enabled
    init_class, init_title = query_active_window()
    is_genshin_focused = is_genshin_window(init_class, init_title)
    print(f"Initial focus check: Genshin={is_genshin_focused} (class='{init_class}', title='{init_title}')")

    while True:
        try:
            sock_path = get_hypr_socket(".socket2.sock")
            if not sock_path:
                time.sleep(1.0)
                continue

            s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            s.connect(sock_path)
            c, t = query_active_window()
            new_focused = is_genshin_window(c, t)
            if new_focused != is_genshin_focused:
                is_genshin_focused = new_focused
                set_macro_indicator(macro_enabled and is_genshin_focused)

            buffer = ""
            while True:
                data = s.recv(4096)
                if not data:
                    break
                buffer += data.decode("utf-8", errors="replace")
                while "\n" in buffer:
                    line, buffer = buffer.split("\n", 1)
                    line = line.strip()
                    if line.startswith("activewindow>>"):
                        content = line[len("activewindow>>"):]
                        parts = content.split(",", 1)
                        win_class = parts[0] if len(parts) > 0 else ""
                        win_title = parts[1] if len(parts) > 1 else ""
                        new_focused = is_genshin_window(win_class, win_title)
                        if new_focused != is_genshin_focused:
                            is_genshin_focused = new_focused
                            print(f"[Focus Changed] Genshin focused: {is_genshin_focused} (class='{win_class}', title='{win_title}')")
                            set_macro_indicator(macro_enabled and is_genshin_focused)
            s.close()
        except Exception:
            time.sleep(1.0)

# Rapid F press loop (50ms down, 50ms up -> 10 clicks/sec) - ONLY when Genshin is active window!
def f_spam_loop():
    global macro_enabled, is_genshin_focused
    while macro_enabled:
        if is_genshin_focused:
            ui.write(ecodes.EV_KEY, ecodes.KEY_F, 1)  # Press down
            ui.syn()
            time.sleep(0.05)
            ui.write(ecodes.EV_KEY, ecodes.KEY_F, 0)  # Release
            ui.syn()
            time.sleep(0.05)
        else:
            time.sleep(0.1)  # Idle pause while Genshin is unfocused
    # Final safety release
    ui.write(ecodes.EV_KEY, ecodes.KEY_F, 0)
    ui.syn()

def cleanup(signum=None, frame=None, exit_code=0):
    global macro_enabled
    macro_enabled = False
    set_macro_indicator(False)
    print("\nStopping macro...")
    try:
        ui.close()
    except Exception:
        pass
    sys.exit(exit_code)

# Register signals for clean exit
signal.signal(signal.SIGINT, lambda s, f: cleanup(s, f, exit_code=0))
signal.signal(signal.SIGTERM, lambda s, f: cleanup(s, f, exit_code=0))

try:
    set_macro_indicator(False)

    # Start real-time Hyprland window focus monitor in background
    focus_thread = threading.Thread(target=hypr_focus_monitor, daemon=True)
    focus_thread.start()

    print("Monitoring keyboards (dynamic hotplug enabled). Press Ctrl+F in Genshin Impact to toggle rapid F-spam.")

    devices_dict = {}  # fd -> InputDevice
    dev_paths = {}     # path -> fd
    held_ctrl_keys = set()  # set of (fd, code)
    last_toggle_time = 0
    last_scan_time = 0

    def scan_keyboards():
        global devices_dict, dev_paths
        current_paths = set(evdev.list_devices())
        for p in current_paths:
            if p not in dev_paths:
                dev = is_valid_keyboard(p)
                if dev:
                    devices_dict[dev.fd] = dev
                    dev_paths[p] = dev.fd
                    print(f"[Device Added] {dev.name} ({dev.path})")

    # Initial keyboard scan
    scan_keyboards()

    while True:
        now = time.time()
        # Periodic rescan every 2 seconds for hotplugged devices (Sunshine, USB, Bluetooth)
        if now - last_scan_time >= 2.0:
            last_scan_time = now
            scan_keyboards()

        if not devices_dict:
            time.sleep(1.0)
            continue

        try:
            r, _, _ = select.select(list(devices_dict.keys()), [], [], 2.0)
        except (ValueError, OSError):
            # One of the file descriptors became invalid, clean up dead devices
            dead_paths = []
            for path, fd in list(dev_paths.items()):
                dev = devices_dict.get(fd)
                if not dev:
                    continue
                try:
                    dev.active_keys()
                except Exception:
                    dead_paths.append((path, fd))
            for path, fd in dead_paths:
                dev = devices_dict.pop(fd, None)
                dev_paths.pop(path, None)
                held_ctrl_keys = {item for item in held_ctrl_keys if item[0] != fd}
                if dev:
                    try:
                        dev.close()
                    except Exception:
                        pass
                    print(f"[Device Removed (Invalid FD)] {dev.name} ({path})")
            continue

        for fd in r:
            dev = devices_dict.get(fd)
            if not dev:
                continue

            try:
                events = list(dev.read())
            except (OSError, IOError) as e:
                # Device was unplugged / destroyed (e.g. [Errno 19] No such device)
                dev_name = dev.name
                dev_path = dev.path
                devices_dict.pop(fd, None)
                dev_paths.pop(dev_path, None)
                held_ctrl_keys = {item for item in held_ctrl_keys if item[0] != fd}
                try:
                    dev.close()
                except Exception:
                    pass
                print(f"[Device Disconnected] {dev_name} ({dev_path}): {e}")
                continue

            for event in events:
                if event.type == ecodes.EV_KEY:
                    if event.code in (ecodes.KEY_LEFTCTRL, ecodes.KEY_RIGHTCTRL):
                        if event.value in (1, 2):
                            held_ctrl_keys.add((fd, event.code))
                        elif event.value == 0:
                            held_ctrl_keys.discard((fd, event.code))
                    elif event.code == ecodes.KEY_F and event.value == 1:
                        is_ctrl_held = len(held_ctrl_keys) > 0
                        if not is_ctrl_held:
                            try:
                                active = dev.active_keys()
                                if ecodes.KEY_LEFTCTRL in active or ecodes.KEY_RIGHTCTRL in active:
                                    is_ctrl_held = True
                            except Exception:
                                pass

                        t_now = time.time()
                        if is_ctrl_held and (t_now - last_toggle_time > 0.25):
                            last_toggle_time = t_now

                            # Only toggle when Genshin Impact is in focus (or if turning OFF an already running macro)
                            if not is_genshin_focused and not macro_enabled:
                                continue

                            macro_enabled = not macro_enabled
                            print(f"[Macro Toggled] Enabled: {macro_enabled} (Genshin focused: {is_genshin_focused})")
                            set_macro_indicator(macro_enabled and is_genshin_focused)
                            if macro_enabled:
                                spam_thread = threading.Thread(target=f_spam_loop, daemon=True)
                                spam_thread.start()

except Exception as e:
    print(f"Error in macro execution: {e}")
    cleanup(exit_code=1)
finally:
    cleanup(exit_code=0)
