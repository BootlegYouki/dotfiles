pragma Singleton

import QtQml
import QtQuick
import Quickshell
import Quickshell.Io
import qs.components.misc

Singleton {
    id: root

    property bool enabled: props.enabled
    property string mode: props.mode || "romaji"

    function toggle(): void {
        props.enabled = !props.enabled;
    }

    function cycleMode(): void {
        if (props.mode === "romaji") {
            props.mode = "english";
        } else if (props.mode === "english") {
            props.mode = "original";
        } else {
            props.mode = "romaji";
        }
    }

    PersistentProperties {
        id: props

        property bool enabled: true
        property string mode: "romaji"

        reloadableId: "romaji"
    }

    property var cache: ({})
    readonly property string sockPath: `/run/user/${Quickshell.env("UID") || "1000"}/caelestia-romaji.sock`

    function convert(input: var, callback: var, forceMode: var): void {
        const currentMode = forceMode || props.mode || "romaji";
        if (!enabled || !input || currentMode === "original") {
            callback(input);
            return;
        }

        let payload = input;
        if (typeof input === "object" && !Array.isArray(input) && input.length !== undefined) {
            try {
                payload = Array.from(input);
            } catch (e) {
                payload = input;
            }
        }

        const jsonStr = typeof payload === "string" ? payload : JSON.stringify(payload);
        if (currentMode === "romaji") {
            const needsConversion = /[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff\uAC00-\uD7A3]/.test(jsonStr);
            if (!needsConversion) {
                callback(input);
                return;
            }
        }

        const cacheKey = currentMode + ":" + jsonStr;
        if (cache[cacheKey] !== undefined) {
            callback(cache[cacheKey]);
            return;
        }

        const reqData = JSON.stringify({
            mode: currentMode,
            input: payload
        });

        romajiSocketComponent.createObject(root, {
            inputData: reqData,
            cacheKey: cacheKey,
            rawInput: input,
            callback: callback
        });
    }

    Component {
        id: romajiSocketComponent

        QtObject {
            id: req

            property string inputData: ""
            property string cacheKey: ""
            property var rawInput
            property var callback
            property int retryCount: 0

            property Socket sock: Socket {
                id: sock
                path: root.sockPath
                connected: false

                parser: SplitParser {
                    splitMarker: "\n"
                    onRead: data => {
                        const trimmed = data.trim();
                        if (trimmed.length === 0) return;
                        try {
                            const res = JSON.parse(trimmed);
                            if (req.cacheKey) root.cache[req.cacheKey] = res;
                            if (req.callback) req.callback(res);
                        } catch (e) {
                            if (req.callback) req.callback(req.rawInput);
                        }
                        Qt.callLater(() => req.destroy());
                    }
                }

                onConnectionStateChanged: {
                    if (connected) {
                        write(req.inputData + "\n");
                    }
                }

                onError: err => {
                    if (req.retryCount < 2) {
                        req.retryCount++;
                        sock.connected = false;
                        Qt.callLater(() => { sock.connected = true; });
                        return;
                    }
                    if (req.callback) req.callback(req.rawInput);
                    Qt.callLater(() => req.destroy());
                }
            }

            Component.onCompleted: {
                // Connect only after inputData is guaranteed to be set
                sock.connected = true;
            }
        }
    }
}
