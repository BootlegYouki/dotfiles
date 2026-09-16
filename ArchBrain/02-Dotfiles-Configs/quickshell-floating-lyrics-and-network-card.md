# Caelestia Quickshell Floating Lyrics & Network Card Sparkline

Documents the floating lyrics widget overlay and the NetworkCard sparkline rendering fix in Caelestia Quickshell.

---

## 1. Floating Lyrics Widget

### Overview
A draggable, compact desktop overlay (`FloatingWindow`) for synchronized lyrics playback with centered typography, smooth slide-up line transitions, and hover-activated frosted glass backdrop.

### Architecture & Components
- **Service (`~/.config/quickshell/caelestia/services/FloatingLyrics.qml`)**:
  - Global singleton tracking `open` visibility state (`toggle()`, `show()`, `hide()`).
- **UI Window (`~/.config/quickshell/caelestia/modules/dashboard/media/FloatingLyricsWindow.qml`)**:
  - `Quickshell.FloatingWindow` with a transparent client area and borderless styling.
  - Dimensions: base `440x155` (minimum `260x80`), comfortably accommodating title, active lyrics (up to 2 lines), and next lyric (up to 2 lines).
  - Only visible when an active player exists and explicitly opened via dashboard (`visible: FloatingLyrics.open && !!Players.active`). Default is closed (`open: false`).
  - No hover backdrop or internal mouse drag areas. Moving and resizing are handled seamlessly via standard Hyprland window bindings (`SUPER + Left Click` to drag, `SUPER + Right Click` to resize).
  - **Track Title**: Subdued header at the top displaying `${artist} - ${title}` with `Tokens.font.label.builders.medium` (`opacity: 0.70`, centered).
  - **Active Lyric**: Prominently rendered in `Colours.palette.m3primary` using `Tokens.font.title.builders.medium` (scaled, `Font.Medium`/`Font.DemiBold`), wrapped up to 2 lines with proportional line height (`lineHeight: 1.15`, centered) and black font outline (`style: Text.Outline`, `styleColor: Qt.rgba(0, 0, 0, 0.85)`) for sharp contrast and readability against bright backgrounds.
  - **Next Lyric**: Placed directly below the active lyric in `Colours.palette.m3onSurfaceVariant` (`opacity: 0.65`, `Font.Normal`), wrapped up to 2 lines, centered (without outline for clean visual hierarchy).
  - **Slide-Up Transition Animation**:
    - Both active (`line1`) and upcoming (`line2`) lyrics incorporate a `Translate` transform paired with a `ParallelAnimation`.
    - When lines update, text smoothly glides upward (`y` translates from +14px / +10px to 0 with `Easing.OutCubic`) while fading in, creating a fluid upward flow into position.
    - Honors `GameMode.enabled` to zero out animations during gaming.
  - **Hover Backdrop & Blur**:
    - Embedded `Rectangle` with dynamic corner radius (`radius: GameMode.enabled ? 0 : Tokens.rounding.large`), smoothly animated via `Anim.DefaultEffects`.
    - Automatically flattens to 0 rounding when Game Mode is active to match Hyprland's zero-rounding rule, and restores `Tokens.rounding.large` when Game Mode is disabled.
    - `Colours.palette.m3surfaceContainer` (`alpha: 0.65`), and `Colours.palette.m3outline` (`alpha: 0.25`) 1px border.
    - Fades in smoothly via `Anim.DefaultEffects` when `hoverArea` or `resizeArea` is hovered (`containsMouse`).
  - **Close Button**: Top-right corner `IconButton` (`type: IconButton.Text`, `icon: "close"`) that fades in smoothly upon hover and calls `FloatingLyrics.hide()` when clicked.
  - **Hyprland Compositor Blur**: Configured `no_blur = false` in `hyprland/rules.lua` and removed `noblur` from `userprefs.conf`, enabling native GPU frosted glass blur when the hover backdrop is active.
  - **Dynamic Scaling**: Gentle curve (`Math.pow(win.width / 440, 0.45)`, clamped between 0.90x and 1.20x) with step quantization to avoid subpixel layout jitter during resize.
  - **Corner Resize Grip**: Dedicated bottom-right resize handle (`win.startSystemResize(Qt.RightEdge | Qt.BottomEdge)`).
  - **Synchronization**:
    - Reactive binding dependency tracker forcing re-evaluation when `currentIndex` or `lyricList` updates.
    - Active polling via `Timer` (`positionChanged()` + `updateIndex()`) plus `Connections` to `Players.active` for seamless lyric progression.
- **Toggle Button (`~/.config/quickshell/caelestia/modules/dashboard/media/LyricsAndSelector.qml`)**:
  - `picture_in_picture_alt` icon button next to the translation mode button in the Lyrics card header.
  - Clicking it toggles `FloatingLyrics.open` and automatically closes the dashboard drawer (`ShellState.forActive()?.dashboard = false`).
- **Hyprland Rules (`~/.config/hypr/hyprland/rules.lua` & `userprefs.conf`)**:
  - Title match `Floating Lyrics`: pinned across all workspaces (`pin = true`), floating (`float = true`), borderless (`border_size = 0`), undecorated (`decorate = false`), no shadow (`no_shadow = true`), no blur (`no_blur = false`), and transparent (`opaque = false`).

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
