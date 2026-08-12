# Caelestia Sidebar & Special Workspace UI Indicators

## Keybindings & Toggles
- `SUPER + D`: Bound once to `fn.toggle("communication")`. Toggles the Communication special workspace.
- `SUPER + Up` / `SUPER + Down`: Cycles through active special workspaces in visual bar order.

---

## 🔢 Constant Special Workspace Order

Both [`hypr-user.lua`](file:///home/youki/.config/caelestia/hypr-user.lua#L54-L61) and [`SpecialWorkspaces.qml`](file:///home/youki/.config/quickshell/caelestia/modules/bar/components/workspaces/SpecialWorkspaces.qml#L114-L124) define a fixed sort order for special workspaces:

```lua
-- hypr-user.lua
local special_order = {
    ["special:music"]         = 1,
    ["special:dev"]           = 2,
    ["special:communication"] = 3,
    ["special:todo"]          = 4,
    ["special:sysmon"]        = 5,
    ["special:special"]       = 6,
}
```

```js
// SpecialWorkspaces.qml ScriptModel
const order = {
    "special:music": 1,
    "special:dev": 2,
    "special:communication": 3,
    "special:todo": 4,
    "special:sysmon": 5,
    "special:special": 6,
};
```

**Why this matters:** Without a fixed order, Hyprland returns windows in non-deterministic order, meaning the sidebar icons and `Super + Up/Down` cycle order would be unpredictable. With the constant order defined in both places, the sidebar always sorts top-to-bottom by this fixed mapping, and cycling always follows the same visual sequence regardless of which workspaces are currently open.

---

## 🐛 Special Workspace Active Indicator Transition Fix

### Problem
When opening a special workspace fresh (e.g. `Super + D` while no special workspace is active), the white pill-shaped indicator in the Caelestia sidebar would stretch or sit in the middle between icons before snapping to the correct position.

Additionally, when switching between non-adjacent special workspaces (e.g. workspace 1 → workspace 3), the indicator would animate slowly through workspace 2 in the middle.

### Root Cause
`SpecialWorkspaces.qml` used `Anim.Emphasized` (~600ms) for both position (`Behavior on y`) and height (`Behavior on implicitHeight`). On fresh open, `currentIndex` momentarily initializes before Hyprland IPC delivers the correct target workspace, causing a visible slide from item 0.

### ✅ Correct Fix (applied by laptop agent via SSH)

**[`SpecialWorkspaces.qml`](file:///home/youki/.config/quickshell/caelestia/modules/bar/components/workspaces/SpecialWorkspaces.qml)**

Added `prevSpecial` and `animateSlide` properties to root:

```qml
property string prevSpecial: ""
property bool animateSlide: false

onActiveSpecialChanged: {
    if (prevSpecial !== "" && activeSpecial !== "" && prevSpecial !== activeSpecial) {
        animateSlide = true;   // switching between two active specials → animate
    } else {
        animateSlide = false;  // fresh open / close → snap instantly, no animation
    }
    prevSpecial = activeSpecial;
}
```

Indicator behaviors use `enabled: root.animateSlide`:

```qml
Behavior on y {
    enabled: root.animateSlide
    Anim {
        type: Anim.StandardSmall
    }
}

Behavior on implicitHeight {
    enabled: root.animateSlide
    Anim {
        type: Anim.StandardSmall
    }
}
```

**Why this is correct:** Tracks semantic state — animation fires only when switching *between* two already-active special workspaces. Fresh open/close always snaps instantly regardless of opacity timing. My earlier attempt (`enabled: root.opacity === 1`) was a timing-based hack that could still race if opacity transition finished before the IPC update.

### ❌ Failed Approach (do not use)
Using `enabled: root.opacity === 1` — this relies on the opacity transition finishing before IPC delivers the workspace update, which is a race condition.

---

## Related Notes
- [[desktop-caelestia-hyprland]]
- [[cachyos-features-and-tools]]
