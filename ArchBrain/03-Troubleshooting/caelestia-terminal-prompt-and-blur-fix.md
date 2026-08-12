# 🐛 Caelestia Terminal, Starship Prompt, & Opacity Fix

## Problem Description
The terminal window in Hyprland failed to display the Caelestia aesthetic:
1. **Missing Prompt**: Standard `~ ❯` default Fish prompt rendered instead of the Starship prompt.
2. **Missing Logo & Specs**: Standard CachyOS ASCII art logo displayed instead of the custom logo on fastfetch greeting.
3. **No Blur / Opacity**: Terminal window remained 100% solid without Hyprland background blur or window opacity.

---

## Root Causes
1. **Starship Package Missing**: `starship` CLI binary was not installed on the system, causing `command -v starship` in `~/.config/fish/config.fish` to fail.
2. **Fastfetch Config Missing / Incomplete**: `~/.config/fastfetch/config.jsonc` was missing or lacked module definitions.
3. **Hyprland Opaque Rule Overrides**: `ghostty` was included in the `opaque_tag` list within `~/.config/hypr/hyprland/rules.lua`, forcing 100% opacity regardless of Ghostty configuration.

---

## Solutions & Fixes Applied

### 1. Install Starship
```bash
sudo pacman -S --noconfirm starship
```

### 2. Configure Fastfetch (`~/.config/fastfetch/config.jsonc`)
Created `~/.config/fastfetch/config.jsonc` with essential system specs and monochrome `YOUKI` ASCII logo.

### 3. Blank Terminal Startup (`~/.config/fish/functions/fish_greeting.fish`)
Disabled automatic `fastfetch` execution on interactive terminal launch by clearing `fish_greeting`:
```fish
function fish_greeting
end
```
*(You can still manually run `fastfetch` anytime by typing `fastfetch` in the terminal).*

### 4. Switch Caelestia Scheme to Monochrome
Set Caelestia scheme variant to `monochrome` via CLI:
```bash
caelestia scheme set -v monochrome
```

### 5. Remove Ghostty from Hyprland Opaque Rules
Updated [`~/.config/hypr/hyprland/rules.lua`](file:///home/youki/.config/hypr/hyprland/rules.lua) to remove `"com.mitchellh.ghostty|ghostty"` from `opaque_tag`, then ran `hyprctl reload`.

---

## Related Notes
- [[fish-and-starship]]
- [[ghostty-and-terminals]]
- [[fastfetch]]
- [[desktop-caelestia-hyprland]]
