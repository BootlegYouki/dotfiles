#!/usr/bin/env python3
import subprocess
import json
import sys

def get_monitors():
    try:
        out = subprocess.check_output(["hyprctl", "monitors", "all", "-j"])
        return json.loads(out)
    except Exception as e:
        print(f"Error querying monitors: {e}", file=sys.stderr)
        return []

def get_secondary_monitor(monitors):
    for m in monitors:
        if m.get("name") != "HDMI-A-1":
            return m
    return None

def eval_lua(cmd):
    try:
        subprocess.check_call(["hyprctl", "eval", cmd])
    except Exception as e:
        print(f"Error executing lua command: {e}", file=sys.stderr)

def main():
    if len(sys.argv) < 2:
        print("Usage: toggle_monitor.py [on|off|status|detect]", file=sys.stderr)
        sys.exit(1)
        
    action = sys.argv[1]
    monitors = get_monitors()
    
    if action == "detect":
        sys.exit(0 if len(monitors) > 1 else 1)
        
    sec = get_secondary_monitor(monitors)
    if not sec:
        print("No secondary monitor found.", file=sys.stderr)
        sys.exit(1)
        
    name = sec.get("name", "DP-1")
    
    if action == "status":
        # Exit 0 if enabled (not disabled), 1 if disabled
        sys.exit(1 if sec.get("disabled", False) else 0)
        
    elif action == "off":
        cmd = f"hl.monitor({{ output = '{name}', disabled = true }})"
        eval_lua(cmd)
        
    elif action == "on":
        # Use user's configured defaults if disabled properties are reset to 0
        transform = sec.get("transform", 3)
        if transform == 0 and name == "DP-1":
            transform = 3
            
        y = sec.get("y", -420)
        if y == 0 and name == "DP-1":
            y = -420
            
        x = sec.get("x", 1920) or 1920
        scale = sec.get("scale", 1) or 1
        
        cmd = f"hl.monitor({{ output = '{name}', disabled = false, mode = '1920x1080@60', position = '{x}x{y}', scale = {scale}, transform = {transform} }})"
        eval_lua(cmd)
        
    else:
        print(f"Unknown action: {action}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
