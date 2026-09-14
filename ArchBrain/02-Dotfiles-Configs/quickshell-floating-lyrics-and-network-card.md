# Caelestia Quickshell Floating Lyrics & Network Card Sparkline

Documents the floating lyrics widget overlay and the NetworkCard sparkline rendering fix in Caelestia Quickshell.

---

## 1. Floating Lyrics Widget

### Overview
A draggable, compact desktop overlay (`FloatingWindow`) for synchronized lyrics playback with media controls and progress scrubbing.

### Architecture & Components
- **Service (`~/.config/quickshell/caelestia/services/FloatingLyrics.qml`)**:
  - Global singleton tracking `open` visibility state (`toggle()`, `show()`, `hide()`).
- **UI Window (`~/.config/quickshell/caelestia/modules/dashboard/media/FloatingLyricsWindow.qml`)**:
  - `Quickshell.FloatingWindow` with a fully transparent client area and borderless styling.
  - Dimensions: base `350x95` (minimum `250x65`), comfortably displaying the active lyric and the dimmed upcoming line.
  - Next Line Display: Rendered by a compact `ListView` using the same lyric model/current-index pattern as the dashboard lyrics list; only the first upcoming line appears below the active line with subdued opacity (`opacity: 0.45`) and black outline.
  - Subdued Scaling: Dynamic scaling uses a gentle curve (`Math.pow(win.width / 350, 0.45)`, clamped between 0.90x and 1.20x max), allowing comfortable resizing without the font exploding in size.
  - Compositor-Native Rounding: Removed client-side `radius` on `container` and removed `decorate = false` from Hyprland rules. Corner rounding is now rendered directly by Hyprland's GPU fragment shader (`vars.windowRounding = 10`), completely eliminating the rubber-banding corner warping, shearing, and visual tearing during window resize.
  - Excluded from `opaque*` tag: Removed `org.quickshell` from `opaque_tag` in `rules.lua` so Hyprland's damage tracker does not force opaque pipeline assumptions onto alpha buffers.
  - Refined Weight Transitions: Restricts lyric weights to `Font.Medium` and `Font.DemiBold`, preventing heavy blocky text when enlarged.
  - Sliding Transition: `Translate` + `NumberAnimation` smoothly glides new lyrics upward into position as lines change.
  - Typography: Dynamic scaling with black `Text.Outline` on lyric lines for wallpaper readability without a widget background.
  - Vertically & Horizontally Centered: Content block (title + active lyric + next lyric) is cleanly centered (`anchors.centerIn: parent`) with generous surrounding margins, completely eliminating top/bottom boundary clipping regardless of manual window resizing.
  - Proportional Line Height: Removed rigid `FixedHeight` line bounds; uses `Text.ProportionalHeight` (`lineHeight: 1.15`), preventing ascender clipping when lines wrap onto two lines.
  - Pure Transparent Backdrop: Removed the translucent dark hover backdrop (`Rectangle`) and hover listener so the widget remains cleanly transparent on hover without dark popup cards obscuring the background.
  - Clean Anti-Aliased Typography: Stripped black outlines from lyrics in favor of clean native font rendering against the frosted hover backdrop.
  - Auto-Reload Daemon: Disabled and stopped `caelestia-auto-reload.service` to prevent compositor/shell crash cycles on file saves.
  - Hyprland Window Rule: Configured `rounding = 0` for `Floating Lyrics` in `userprefs.conf` and `rules.lua`, allowing the QML window to handle corner geometry without compositor clipping cuts or asymmetrical corner artifacts.
  - Corner Grip: Bottom-right resize handle (`win.startSystemResize(Qt.RightEdge | Qt.BottomEdge)`).
  - **Lyrics**: Max 2 lines displayed with centered alignment.
    - Line 1 (Current): Highlighted in `Colours.palette.m3primary` with black outline.
    - Line 2 (Next): Subdued in `Colours.palette.m3outline` with black outline.
    - Active/current lyric is positioned at the top of the compact list; following lyric delegates naturally appear underneath like the dashboard lyric view.
    - Background track updater binding keeps lyrics synchronized even when the dashboard drawer is closed.
  - **Controls**: Inline previous/play-next controls were removed to keep the floating overlay lyrics-focused.
- **Toggle Button (`~/.config/quickshell/caelestia/modules/dashboard/media/LyricsAndSelector.qml`)**:
  - `picture_in_picture_alt` icon button next to the translation mode button in the Lyrics card header.
  - Clicking it toggles `FloatingLyrics.open` and automatically closes the dashboard drawer (`ShellState.forActive()?.dashboard = false`).
- **Hyprland Rules (`~/.config/hypr/hyprland/rules.lua` & `userprefs.conf`)**:
  - Title match `Floating Lyrics`: pinned across all workspaces (`pin = true`), floating (`float = true`), borderless (`border_size = 0`), undecorated (`decorate = false`), no shadow (`no_shadow = true`), no blur (`no_blur = true`), and transparent (`opaque = false`).

---

## 2. NetworkCard Sparkline Glitch Fix

### Root Cause
When opening the dashboard performance tab, the sparkline graph would glitch with vertical jagged lines bleeding out into the header:
1. `sparkline.targetMax` started at a fixed `1024 B/s`, causing speeds > 1 KB/s to yield negative Y coordinates (`y = h - (val / maxValue) * h`), projecting lines above the item.
2. `maxValue: smoothMax` animated slowly with `Anim {}`, lagging behind live data spikes.
3. The sparkline container lacked `clip: true`, allowing paths to render outside the graph area into the header.
4. Uninitialized/cold service delta readings rendered immediately before 2 buffer points were available.

### Fix Implemented (`NetworkCard.qml`)
- Added `clip: true` on the sparkline container `Item`.
- Dynamic `targetMax` initialization: `Math.max(NetworkUsage.downloadBuffer.maximum, NetworkUsage.uploadBuffer.maximum, 1024)`.
- Added `Connections` for `NetworkUsage.uploadBuffer` on `valuesChanged` to immediately adapt to upload bursts.
- Added buffer count-based opacity: `opacity: NetworkUsage.downloadBuffer.count >= 2 ? 1 : 0` with `Anim.DefaultEffects` transition.

---

## Related Notes
- [[caelestia-hyprland]]
- [[quickshell-caelestia-auto-reload]]
