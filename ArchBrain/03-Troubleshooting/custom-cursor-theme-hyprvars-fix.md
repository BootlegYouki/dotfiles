# 🖱️ Cursor Theme Fix: Applying `Bibata-Modern-Ice` via `hypr-vars.lua` & GSettings

## Issue
Setting `cursorTheme` did not immediately reflect or failed when editing `~/.config/caelestia/hypr-vars.lua` directly without syncing GSettings and GTK default fallbacks.

---

## Cause
1. **Hyprland Variables Lua Override**: Caelestia's Hyprland Lua loader (`hyprland.lua`) dynamically merges key-value pairs from `~/.config/caelestia/hypr-vars.lua` into `vars`. To override `cursorTheme`, the file must return a Lua table specifying `cursorTheme`.
2. **GSettings & GTK Fallback**: Hyprland reads environment variables at session launch, but live desktop applications and GTK apps require `gsettings set org.gnome.desktop.interface cursor-theme` and `~/.icons/default/index.theme`.

---

## Resolution
1. **Configured `~/.config/caelestia/hypr-vars.lua`**:
   ```lua
   return {
       cursorTheme = "Bibata-Modern-Ice",
   }
   ```

2. **Created `~/.icons/default/index.theme`**:
   ```ini
   [Icon Theme]
   Name=Default
   Comment=Default Cursor Theme
   Inherits=Bibata-Modern-Ice
   ```

3. **Applied Live Cursor & Session Services**:
   ```bash
   hyprctl setcursor Bibata-Modern-Ice 24
   gsettings set org.gnome.desktop.interface cursor-theme "Bibata-Modern-Ice"
   gsettings set org.gnome.desktop.interface cursor-size 24
   hyprctl reload
   caelestia shell -k && caelestia shell -d
   ```

4. **Symlinked Cursor Theme for XWayland & Legacy Applications**:
   Legacy X11 and XWayland applications look in `~/.icons/` rather than `~/.local/share/icons/` to find cursor themes. To prevent them from falling back to a giant default/fallback cursor, symlink the theme folder:
   ```bash
   ln -sf ~/.local/share/icons/Bibata-Modern-Ice ~/.icons/Bibata-Modern-Ice
   ```

5. **Forced Native Wayland Mode for Spotify**:
   To prevent Spotify from running under XWayland (which can cause scaling and cursor issues), create `~/.config/spotify-flags.conf` with:
   ```text
   --enable-features=UseOzonePlatform
   --ozone-platform=wayland
   ```

6. **Disabled Hardware Cursors for Rotated/Secondary Displays**:
   To prevent the cursor from freezing, rendering incorrectly, or failing to scale when moving between a landscape main monitor and a rotated/vertical secondary monitor, configure software cursor rendering in [`~/hypr/hyprland/input.lua`](file:///home/youki/hypr/hyprland/input.lua):
   ```lua
   cursor = {
       no_hardware_cursors = true,
   }
   ```

7. **Centered Floating Steam & Game Launcher Windows**:
   Under XWayland multi-monitor configurations (especially with vertical coordinate offsets like `1920x-420`), apps trying to center their own loading/login screens (like Steam) calculate coordinates against the entire virtual canvas, causing them to spawn off-center or cut off. We force them to center on the active monitor in [`~/hypr/hyprland/rules.lua`](file:///home/youki/hypr/hyprland/rules.lua):
   ```lua
   hl.window_rule({ match = { class = "steam", float = true }, center = true })
   hl.window_rule({ match = { class = "Twintaillauncher|app.twintaillauncher.ttl|com.github.an-anime-game-launcher", float = true }, center = true })
   ```

---

## Related Notes
- [[desktop-caelestia-hyprland]]
- [[caelestia-ui-fixes]]
