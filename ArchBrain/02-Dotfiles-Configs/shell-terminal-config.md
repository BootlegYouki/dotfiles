# Shell and Terminal Configurations

Actual configurations driving the terminal, shell environment, and desktop shell.

## 1. Ghostty Terminal (`~/.config/ghostty/config`)
- **Theme:** Monochrome Caelestia scheme (Background `131313`, Foreground `e2e2e2`)
- **Font:** JetBrainsMono Nerd Font (Size 12)
- **UI:** Window padding X/Y set to 20, Background opacity `0.78` for Hyprland blur integration.
- **Cursor:** Bar style, non-blinking.
- **Default Shell:** `/bin/fish`

## 2. Fish Shell (`~/.config/fish/config.fish`)
- **Hyprland Auto-start:** Uses `uwsm start hyprland-uwsm.desktop` automatically on `tty1` login.
- **Prompt:** Managed by `starship`.
- **Integrations:** `direnv` and `zoxide` (aliased to `cd`).
- **ls Replacement:** Uses `eza` (`alias ls='eza --icons --group-directories-first -1'`).
- **Git Abbreviations:** Comprehensive list (`lg` for lazygit, `gd`, `ga`, `gc`, `gsh`, etc.)
- **Caelestia Integration:** Loads custom color sequences from `~/.local/state/caelestia/sequences.txt` and user configs from `~/.config/caelestia/user-config.fish`.
- **Foot Terminal Jump:** Custom event function `mark_prompt_start` for jumping between prompts in foot terminal.

## 3. Desktop Shell: Quickshell
- **Config location:** `~/.config/quickshell/shell.qml`
- **Crash reporting:** Configured for `caelestia-dots/shell` issues.
- **Optimizations:** `QS_DROP_EXPENSIVE_FONTS=1`, threaded render loop (`QSG_RENDER_LOOP=threaded`).
