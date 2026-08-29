# Canva Desktop App Setup & Pinta Removal

Documentation for replacing Pinta with Canva as the primary design and graphics tool on CachyOS/Hyprland.

---

## Overview

- **Removed Package**: `pinta` (and orphaned `dotnet-runtime-10.0`, `dotnet-host`)
- **Installed Solution**: Standalone Canva Desktop Web Application (`brave-origin --app=https://www.canva.com/`)
- **Desktop Entry**: `~/.local/share/applications/canva.desktop`
- **Icon Assets**: `~/.local/share/icons/hicolor/{scalable,16x16,24x24,32x32,48x48,64x64,128x128,256x256,512x512}/apps/canva.{svg,png}`
- **WM Class**: `www.canva.com`

---

## Configuration & Integration Details

### 1. Desktop Entry (`~/.local/share/applications/canva.desktop`)
```ini
[Desktop Entry]
Version=1.0
Name=Canva
Comment=Free design tool: presentations, video, social media
GenericName=Graphic Design
Exec=brave-origin --app=https://www.canva.com/ %U
Icon=canva
Terminal=false
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;VectorGraphics;Publishing;
StartupNotify=true
StartupWMClass=www.canva.com
Keywords=canva;design;graphics;drawing;editor;presentation;poster;photo;pinta;paint;
```

### 2. High-Resolution Icon Assets
High-fidelity SVG vector and rasterized PNG icons generated across standard sizes in `~/.local/share/icons/hicolor/` with cache rebuilt via `gtk-update-icon-cache`.

---

## Related Notes
- [[brave-origin-browser]]
- [[core-packages]]
- [[desktop-caelestia-hyprland]]
