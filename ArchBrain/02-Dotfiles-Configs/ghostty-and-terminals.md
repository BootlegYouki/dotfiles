# 💻 Ghostty & Terminal Setup

Documentation and complete source code for terminal emulator configurations on this CachyOS Hyprland desktop.

---

## 👻 Ghostty Full Configuration (`~/.config/ghostty/config`)

```ini
# Ghostty Configuration for Caelestia / Hyprland

font-family = JetBrainsMono Nerd Font
font-size = 12

# Window Padding & Opacity for Hyprland Blur
window-padding-x = 20
window-padding-y = 20
background-opacity = 0.78

# Cursor
cursor-style = bar
cursor-style-blink = false

# Colors matching Caelestia current scheme
background = 0b0f11
foreground = e0e6ee
selection-background = 34566f
selection-foreground = cce6ff

palette = 0=#343434
palette = 1=#8383ff
palette = 2=#44def5
palette = 3=#75fcdd
palette = 4=#81b0cd
palette = 5=#89aaed
palette = 6=#89d3f0
palette = 7=#ccdcd6
palette = 8=#9aa59f
palette = 9=#a29eff
palette = 10=#89ecff
palette = 11=#c9fff3
palette = 12=#a8c5d5
palette = 13=#a7bef8
palette = 14=#a0e5ff
palette = 15=#ffffff
```

---

## 👟 Foot Terminal Setup
Uses `mark_prompt_start` hook in Fish shell (`echo -en "\e]133;A\e\\"`) to enable native scrollback prompt jumping (`Shift + Up` / `Shift + Down`).
