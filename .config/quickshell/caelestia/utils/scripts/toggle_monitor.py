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
        if m["name"] != "HDMI-A-1":
            return m
    return None

def eval_lua(cmd):
    try:
        subprocess.check_call(["hyprctl", "eval", cmd])
    except Exception as e:
        print(f"Error executing lua command: {e}", file=sys.stderr)

def main():
    if len(sys.argv) < 2:
        print("Usage: toggle_monitor.py [on|off|status]", file=sys.stderr)
        sys.exit(1)
        
    action = sys.argv[1]
    monitors = get_monitors()
    sec = get_secondary_monitor(monitors)
    
    if not sec:
        print("No secondary monitor found.", file=sys.stderr)
        sys.exit(1)
        
    name = sec["name"]
    
    if action == "status":
        # Exit with 0 if monitor is enabled (not disabled)
        sys.exit(1 if sec.get("disabled", False) else 0)
        
    elif action == "off":
        cmd = f"hl.monitor({{ output = '{name}', disabled = true }})"
        eval_lua(cmd)
        
    elif action == "on":
        width = sec.get("width", 1920)
        height = sec.get("height", 1080)
        refresh = sec.get("refreshRate", 60.0)
        x = sec.get("x", 1920)
        y = sec.get("y", 0)
        scale = sec.get("scale", 1)
        transform = sec.get("transform", 0)
        
        cmd = f"hl.monitor({{ output = '{name}', disabled = false, mode = '{width}x{height}@{refresh}', position = '{x}x{y}', scale = {scale}, transform = {transform} }})"
        eval_lua(cmd)
        
        # Also ensure DPMS is on
        eval_lua("hl.dispatch(hl.dsp.dpms('on'))")
        
    else:
        print(f"Unknown action: {action}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
