pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import Quickshell.Io
import Caelestia.Components
import Caelestia.Config
import qs.utils
import qs.components
import qs.components.controls
import qs.services
import qs.modules.nexus
import qs.modules.bar.popouts as BarPopouts

StyledRect {
    id: root

    required property ScreenState screenState
    required property BarPopouts.Wrapper popouts
    property bool hasBluetoothHardware: false

    Process {
        id: procCmd
        function run(args) {
            command = args;
            running = true;
        }
    }

    Process {
        id: btCheckProc
        command: ["sh", "-c", "rfkill list bluetooth 2>/dev/null | grep -qi bluetooth"]
        running: true
        onExited: (code) => {
            root.hasBluetoothHardware = (code === 0);
        }
    }

    readonly property bool secondMonitorOn: Hypr.secondMonitorOn
    readonly property bool hasMultipleMonitors: Hypr.hasMultipleMonitors

    property bool autoLoginEnabled: true

    Process {
        id: autoLoginCheckProc
        command: ["sh", "-c", "if [ -x /home/youki/custom_scripts/toggle-autologin ]; then /home/youki/custom_scripts/toggle-autologin status; elif [ -x /home/youki/.local/bin/toggle-autologin ]; then /home/youki/.local/bin/toggle-autologin status; else toggle-autologin status; fi"]
        running: true
        onExited: (code) => {
            root.autoLoginEnabled = (code === 0);
        }
    }

    Connections {
        target: root.screenState
        function onUtilitiesChanged() {
            if (root.screenState.utilities) {
                Hypr.refreshMonitorState();
                autoLoginCheckProc.running = true;
            }
        }
    }

    readonly property var quickToggles: {
        const seenIds = new Set();
        const rawToggles = Config.utilities.quickToggles.values ?? Array.from(Config.utilities.quickToggles ?? []);

        return rawToggles.filter(item => {
            if (!(item.enabled ?? true))
                return false;

            if (seenIds.has(item.id)) {
                return false;
            }

            if (item.id === "vpn") {
                return GlobalConfig.utilities.vpn.provider.some(p => typeof p === "object" ? (p.enabled === true) : false);
            }

            if (item.id === "bluetooth") {
                return root.hasBluetoothHardware;
            }

            if (item.id === "display" || item.id === "monitor") {
                return root.hasMultipleMonitors;
            }

            if (item.id === "ethernet") {
                return Nmcli.ethernetDevices.length > 0;
            }

            if (item.id === "wifi") {
                return Nmcli.wirelessInterfaces.length > 0;
            }

            seenIds.add(item.id);
            return true;
        });
    }
    readonly property int splitIndex: Math.ceil(quickToggles.length / 2)
    readonly property bool needExtraRow: quickToggles.length > 6

    Layout.fillWidth: true
    implicitHeight: layout.implicitHeight + Tokens.padding.extraLargeIncreased

    radius: Tokens.rounding.large
    color: Colours.tPalette.m3surfaceContainer

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: Tokens.padding.large
        spacing: Tokens.spacing.medium

        StyledText {
            text: qsTr("Quick Toggles")
            font: Tokens.font.body.medium
        }

        QuickToggleRow {
            model: root.needExtraRow ? root.quickToggles.slice(0, root.splitIndex) : root.quickToggles
        }

        QuickToggleRow {
            visible: root.needExtraRow
            model: root.needExtraRow ? root.quickToggles.slice(root.splitIndex) : []
        }
    }

    component QuickToggleRow: ButtonRow {
        property alias model: repeater.model

        Layout.fillWidth: true
        spacing: Tokens.spacing.small

        Repeater {
            id: repeater

            delegate: DelegateChooser {
                role: "id"

                DelegateChoice {
                    roleValue: "wifi"
                    delegate: Toggle {
                        icon: Nmcli.active !== null ? Icons.getNetworkIcon(Nmcli.active.strength ?? 0) : (Nmcli.wifiEnabled ? "wifi" : "wifi_off")
                        checked: Nmcli.wifiEnabled
                        onClicked: {
                            Nmcli.enableWifi(!Nmcli.wifiEnabled);
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "network"
                    delegate: Toggle {
                        icon: Nmcli.activeEthernet !== null ? "lan" : (Nmcli.active !== null ? Icons.getNetworkIcon(Nmcli.active.strength ?? 0) : (Nmcli.wifiEnabled ? "wifi" : "wifi_off"))
                        checked: Nmcli.activeEthernet !== null || Nmcli.wifiEnabled
                        onClicked: {
                            if (Nmcli.activeEthernet !== null) {
                                Nmcli.disconnectEthernet(Nmcli.activeEthernet.connection, () => {});
                            } else {
                                Nmcli.enableWifi(!Nmcli.wifiEnabled);
                            }
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "ethernet"
                    delegate: Toggle {
                        icon: "lan"
                        checked: Nmcli.activeEthernet !== null
                        onClicked: {
                            if (Nmcli.activeEthernet !== null) {
                                Nmcli.disconnectEthernet(Nmcli.activeEthernet.connection, () => {});
                            } else {
                                const eth = Nmcli.ethernetDevices[0];
                                if (eth) {
                                    Nmcli.connectEthernet(eth.connection ?? "", eth.iface, () => {});
                                }
                            }
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "bluetooth"
                    delegate: Toggle {
                        icon: !Bluetooth.defaultAdapter?.enabled ? "bluetooth_disabled" : (Bluetooth.devices.values.some(d => d.connected) ? "bluetooth_connected" : "bluetooth")
                        checked: Bluetooth.defaultAdapter?.enabled ?? false
                        onClicked: {
                            if (Bluetooth.defaultAdapter)
                                Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "display"
                    delegate: Toggle {
                        icon: "desktop_windows"
                        checked: root.secondMonitorOn
                        onClicked: {
                            const nextState = !root.secondMonitorOn;
                            const action = nextState ? "on" : "off";
                            procCmd.run(["sh", "-c", `if [ -x /home/youki/custom_scripts/toggle_monitor.py ]; then /home/youki/custom_scripts/toggle_monitor.py ${action}; elif [ -x /etc/xdg/quickshell/caelestia/utils/scripts/toggle_monitor.py ]; then /etc/xdg/quickshell/caelestia/utils/scripts/toggle_monitor.py ${action}; else toggle_monitor.py ${action}; fi`]);
                            Hypr.secondMonitorOn = nextState;
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "monitor"
                    delegate: Toggle {
                        icon: "desktop_windows"
                        checked: root.secondMonitorOn
                        onClicked: {
                            const nextState = !root.secondMonitorOn;
                            const action = nextState ? "on" : "off";
                            procCmd.run(["sh", "-c", `if [ -x /home/youki/custom_scripts/toggle_monitor.py ]; then /home/youki/custom_scripts/toggle_monitor.py ${action}; elif [ -x /etc/xdg/quickshell/caelestia/utils/scripts/toggle_monitor.py ]; then /etc/xdg/quickshell/caelestia/utils/scripts/toggle_monitor.py ${action}; else toggle_monitor.py ${action}; fi`]);
                            Hypr.secondMonitorOn = nextState;
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "autologin"
                    delegate: Toggle {
                        icon: root.autoLoginEnabled ? "lock_open" : "lock"
                        checked: root.autoLoginEnabled
                        onClicked: {
                            const nextState = !root.autoLoginEnabled;
                            const action = nextState ? "on" : "off";
                            procCmd.run(["sh", "-c", `if [ -x /home/youki/custom_scripts/toggle-autologin ]; then /home/youki/custom_scripts/toggle-autologin ${action}; elif [ -x /home/youki/.local/bin/toggle-autologin ]; then /home/youki/.local/bin/toggle-autologin ${action}; else toggle-autologin ${action}; fi`]);
                            root.autoLoginEnabled = nextState;
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "autoLogin"
                    delegate: Toggle {
                        icon: root.autoLoginEnabled ? "lock_open" : "lock"
                        checked: root.autoLoginEnabled
                        onClicked: {
                            const nextState = !root.autoLoginEnabled;
                            const action = nextState ? "on" : "off";
                            procCmd.run(["sh", "-c", `if [ -x /home/youki/custom_scripts/toggle-autologin ]; then /home/youki/custom_scripts/toggle-autologin ${action}; elif [ -x /home/youki/.local/bin/toggle-autologin ]; then /home/youki/.local/bin/toggle-autologin ${action}; else toggle-autologin ${action}; fi`]);
                            root.autoLoginEnabled = nextState;
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "nightlight"
                    delegate: Toggle {
                        icon: NightLight.enabled ? "bedtime" : "bedtime_off"
                        checked: NightLight.enabled
                        onClicked: NightLight.toggle()
                    }
                }
                DelegateChoice {
                    roleValue: "nightLight"
                    delegate: Toggle {
                        icon: NightLight.enabled ? "bedtime" : "bedtime_off"
                        checked: NightLight.enabled
                        onClicked: NightLight.toggle()
                    }
                }
                DelegateChoice {
                    roleValue: "mic"
                    delegate: Toggle {
                        icon: "mic"
                        checked: !Audio.sourceMuted
                        onClicked: {
                            const audio = Audio.source?.audio;
                            if (audio)
                                audio.muted = !audio.muted;
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "settings"
                    delegate: Toggle {
                        icon: "settings"
                        inactiveOnColour: Colours.palette.m3onSurfaceVariant
                        isToggle: false
                        onClicked: {
                            root.screenState.utilities = false;
                            WindowFactory.create();
                        }
                    }
                }
                DelegateChoice {
                    roleValue: "gameMode"
                    delegate: Toggle {
                        icon: "gamepad"
                        checked: GameMode.enabled
                        onClicked: GameMode.enabled = !GameMode.enabled
                    }
                }
                DelegateChoice {
                    roleValue: "dnd"
                    delegate: Toggle {
                        icon: "notifications_off"
                        checked: Notifs.dnd
                        onClicked: Notifs.dnd = !Notifs.dnd
                    }
                }
                DelegateChoice {
                    roleValue: "vpn"
                    delegate: Toggle {
                        icon: "vpn_key"
                        checked: VPN.connected && VPN.status.state !== "needs-auth" && VPN.status.state !== "error"
                        enabled: !VPN.connecting
                        isToggle: VPN.status.state !== "needs-auth" && VPN.status.state !== "error"
                        inactiveOnColour: Colours.palette.m3onSurfaceVariant
                        onClicked: VPN.toggle()
                    }
                }
            }
        }
    }

    component Toggle: IconButton {
        inactiveColour: Colours.layer(Colours.palette.m3surfaceContainerHighest, 2)
        fillWidth: true
        isToggle: true
        isRound: true
        shapeMorph: true
    }
}
