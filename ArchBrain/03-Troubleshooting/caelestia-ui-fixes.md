# 🎨 Caelestia UI Fixes: Monochrome Scheme & Border Radius Uniformity

## Overview
Resolution for UI inconsistencies in Caelestia Shell performance dashboard, weather tab, card border radii, and tab hover states.

---

## 1. Preferred Card Border Radius: `Tokens.rounding.large`
The user specified that the DateTime card border radius style (`Tokens.rounding.large`) is their preferred corner rounding format.

Updated all dashboard & weather tab cards to strictly use `Tokens.rounding.large`:
- **`HeroCard.qml`** (CPU & GPU) -> `Tokens.rounding.large`
- **`StorageCard.qml`** -> `Tokens.rounding.large`
- **`NetworkCard.qml`** -> `Tokens.rounding.large`
- **`MemoryCard.qml`** -> `Tokens.rounding.large`
- **`BatteryTank.qml`** -> `Tokens.rounding.large`
- **`WeatherTab.qml`** (Main Weather Info Card & `DetailCard`s) -> `Tokens.rounding.large`
- **`Dash.qml`** (`User`, `SmallWeather`, `DateTime`, `Calendar`, `Resources`, `Media`) -> `Tokens.rounding.large`

---

## 2. Dynamic Monochrome Color Scheme
Applied dynamic monochrome theme palette using the Caelestia CLI:
```bash
caelestia scheme set -n dynamic -v monochrome
```

---

## 3. Dashboard Tab Hover Hitbox & State Layer Fix
In `~/.config/quickshell/caelestia/modules/dashboard/Tabs.qml`:
- Changed `StateLayer` from `anchors.fill: undefined` to `anchors.fill: parent` with small margins so hover bounds are properly calculated when mouse passes over tab titles (`Dashboard`, `Media`, `Performance`, `Weather`).

---

## Related Notes
- [[desktop-caelestia-hyprland]]
- [[caelestia-sidebar-indicators]]
