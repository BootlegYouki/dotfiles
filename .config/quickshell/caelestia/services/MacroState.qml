pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.components.misc

Singleton {
    id: root

    property bool active: false

    function enable(): void {
        active = true;
    }

    function disable(): void {
        active = false;
    }

    function toggle(): void {
        active = !active;
    }

    function set(val: bool): void {
        active = val;
    }

    FileView {
        id: stateFile

        printErrors: false
        path: `/run/user/${Quickshell.env("UID") || "1000"}/genshin_macro.state`

        onLoaded: {
            const val = text().trim();
            root.active = (val === "1" || val === "true" || val === "enabled");
        }

        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound) {
                root.active = false;
            }
        }
    }

    IpcHandler {
        function isEnabled(): bool {
            return root.active;
        }

        function toggle(): void {
            root.active = !root.active;
        }

        function enable(): void {
            root.active = true;
        }

        function disable(): void {
            root.active = false;
        }

        function set(val: bool): void {
            root.active = val;
        }

        target: "macro"
    }
}
