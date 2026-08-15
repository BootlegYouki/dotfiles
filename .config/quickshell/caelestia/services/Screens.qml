pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Caelestia.Config

Singleton {
    id: root

    readonly property list<ShellScreen> screens: Quickshell.screens.filter(s => GlobalConfig.forScreen(s.name).enabled)
    readonly property ShellScreen activeScreen: screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? screens[0] ?? null

    function isExcluded(screen: ShellScreen): bool {
        return !GlobalConfig.forScreen(screen.name).enabled;
    }
}
