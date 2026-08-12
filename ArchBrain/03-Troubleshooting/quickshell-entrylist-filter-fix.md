---
title: Quickshell Caelestia EntryList Filter TypeError & Restoration Fix
description: Diagnostic and resolution steps for Quickshell UI silent crashes caused by EntryList .filter calls, restoring Romaji, English Translation, and Night Light features.
date: 2026-08-12
---

# Quickshell Caelestia EntryList Filter TypeError & Restoration Fix

## Problem Description
After setup migration or updates, the Caelestia Shell UI (Quickshell) failed to load custom widgets (Night Light, Romaji/Translation, Status Icons, Sidebar Quick Toggles) or crashed silently.

The `quickshell` log (`/run/user/1000/quickshell/by-id/*/log.qslog`) contained:
```
TypeError: Property 'filter' of object caelestia::config::EntryList(...) is not a function
```

## Root Causes Identified
1. **Quickshell C++ `EntryList` Type Incompatibility**:
   In Caelestia Shell, C++ `EntryList` configuration objects do not expose a JavaScript `.filter()` array method directly. Attempting to execute `Config.bar.entries.filter(...)` or `Config.utilities.quickToggles.filter(...)` throws a fatal QML `TypeError`, preventing the Bar and Sidebar widgets from rendering.

2. **`caelestia-romaji` CLI Shell Escaping Syntax Bug**:
   Line 10 of `~/.local/bin/caelestia-romaji` contained a nested double-quote bash string interpolation bug, causing a `SyntaxError: unterminated string literal` when invoking the CLI directly.

## Solutions Applied

### 1. QML `EntryList` Array Safe Casting (`Bar.qml`, `Toggles.qml`, `Actions.qml`)
Updated QML bindings to access `.values` or cast via `Array.from(...)`:

- **`Bar.qml`**:
  ```qml
  values: (root.Config.bar.entries.values ?? Array.from(root.Config.bar.entries ?? [])).filter(e => e.enabled ?? true)
  ```
- **`Toggles.qml`**:
  ```qml
  const rawToggles = Config.utilities.quickToggles.values ?? Array.from(Config.utilities.quickToggles ?? []);
  return rawToggles.filter(item => { ... });
  ```
- **`Actions.qml`**:
  ```qml
  model: (GlobalConfig.launcher.actions.values ?? Array.from(GlobalConfig.launcher.actions ?? [])).filter(a => (a.enabled ?? true) && ...)
  ```

### 2. Optional Chaining on `StatusIcons.qml`
Added optional chaining to prevent undefined property crashes when accessing status indicators:
- **`StatusIcons.qml`**: `Config.bar?.status?.showAudio ?? true`

### 3. Rewrote `caelestia-romaji` CLI Tool as Pure Python Script
Replaced bash string wrapping with clean, standalone Python IPC socket messaging in `~/.local/bin/caelestia-romaji`. Tested CLI with `caelestia-romaji "こんにちは世界"`, which instantly returns `konnichiha sekai`.

### 4. Restarted Shell & Services
- **Caelestia Romaji Socket Daemon**: Active under systemd (`caelestia-romaji.service`).
- **Night Light Daemon**: `hyprsunset` running at 4000K, controllable via Super+Shift+N and the Caelestia sidebar widget.
- **Caelestia Shell**: Cleanly reloaded without QML type errors.

## Verification
- Verified IPC Romaji socket (`/run/user/1000/caelestia-romaji.sock`) returns both Romaji and English translations on demand.
- Verified Night Light toggle script (`nightlight`) and widget dynamically control `hyprsunset` temperature without screen flashing.
- Dotfiles repo updated and committed (`fix(quickshell): resolve EntryList type errors and update romaji CLI client`).

## Related Notes
- [[romaji-lyrics-daemon]]
- [[caelestia-nightlight-widget]]
- [[00-AGENT-SYSTEM-RESTORE-GUIDE]]
- [[desktop-caelestia-hyprland]]
