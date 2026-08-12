pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import Quickshell.Io
import Caelestia
import Caelestia.Components
import Caelestia.Config
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

    readonly property string toggleScript: Paths.toLocalFile(Qt.resolvedUrl("../../../../utils/scripts/toggle_monitor.py"))
    property bool secondMonitorOn: true

    Process {
        id: dpmsCheckProc
        command: [toggleScript, "status"]
        running: true
        onExited: (code) => {
            root.secondMonitorOn = (code === 0);
        }
    }

    Connections {
        target: Hypr
        function onMonitorsChanged() {
            dpmsCheckProc.running = true;
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
                        icon: Nmcli.activeEthernet !== null ? "lan" : "settings_ethernet"
                        checked: Nmcli.activeEthernet !== null
                        onClicked: {
                            if (Nmcli.activeEthernet) {
                                Nmcli.disconnectEthernet(Nmcli.activeEthernet.connection, () => {});
                            } else {
                                const eth = Nmcli.ethernetDevices.find(d => d.connection);
                                if (eth) {
                                    Nmcli.connectEthernet(eth.connection, eth.iface, () => {});
                                } else {
                                    Nmcli.getEthernetInterfaces(() => {});
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
                            procCmd.run([toggleScript, nextState ? "on" : "off"]);
                            root.secondMonitorOn = nextState;
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
                            procCmd.run([toggleScript, nextState ? "on" : "off"]);
                            root.secondMonitorOn = nextState;
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
