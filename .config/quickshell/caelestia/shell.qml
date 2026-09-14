import "modules"
import "modules/drawers"
import "modules/background"
import "modules/areapicker"
import "modules/lock"
import "modules/dashboard/media"
import QtQuick
import Quickshell
import qs.services

ShellRoot {
    id: root

    settings.watchFiles: false

    Binding {
        target: ShellState
        property: "shellRoot"
        value: root
    }

    GSFLoader {}
    ServiceLoader {}

    Background {}
    Drawers {}
    AreaPicker {}
    Lock {
        id: lock
    }

    ConfigToasts {}
    Shortcuts {}
    BatteryMonitor {}
    IdleMonitors {
        lock: lock
    }

    FloatingLyricsWindow {}
}
