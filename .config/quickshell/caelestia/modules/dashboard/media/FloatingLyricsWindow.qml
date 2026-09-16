import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Caelestia.Config
import Caelestia.Services
import qs.components
import qs.components.controls
import qs.services

FloatingWindow {
    id: win

    title: "Floating Lyrics"
    color: "transparent"
    surfaceFormat.opaque: false
    visible: FloatingLyrics.open && !!Players.active

    implicitWidth: 440
    implicitHeight: 155
    minimumSize.width: 260
    minimumSize.height: 80

    readonly property real _rawScale: Math.max(0.90, Math.min(1.20, Math.pow(win.width / 440, 0.45)))
    readonly property real effectiveScale: Math.round(_rawScale * 20) / 20

    readonly property int lyricWeight: effectiveScale >= 1.25 ? Font.DemiBold : Font.Medium
    readonly property int nextLyricWeight: Font.Normal

    screen: Screens.activeScreen
    contentItem.Tokens.screen: screen?.name ?? ""

    onClosed: {
        FloatingLyrics.open = false;
    }

    onVisibleChanged: {
        if (!visible && FloatingLyrics.open)
            FloatingLyrics.open = false;
    }

    property string _lastTrackKey: ""

    function syncTrack(): void {
        const p = Players.active;
        const key = `${p?.trackArtist}\0${p?.trackTitle}\0${p?.trackAlbum}\0${p?.length}`;
        if (key === win._lastTrackKey)
            return;
        win._lastTrackKey = key;
        if (p && p.trackTitle)
            Lyrics.setTrack(p.trackArtist, p.trackTitle, p.trackAlbum, p.length);
        else
            Lyrics.clearTrack();
    }

    property var lyricList: []
    property string currentTrack: ""
    property bool converting: false
    property int lyricReqId: 0

    function updateLyrics(trackChanged: bool): void {
        const reqId = ++lyricReqId;
        const raw = Lyrics.lyrics;
        if (!raw || raw.length === 0) {
            lyricList = [];
            converting = false;
            return;
        }
        if (trackChanged)
            lyricList = [];

        converting = true;
        Romaji.convert(raw, res => {
            if (reqId === win.lyricReqId) {
                lyricList = res;
                converting = false;
            }
        });
    }

    Connections {
        target: Lyrics
        function onLyricsChanged() {
            const track = Players.active?.trackTitle ?? "";
            const trackChanged = track !== win.currentTrack;
            win.currentTrack = track;
            win.updateLyrics(trackChanged);
            win.updateIndex();
        }

        function onHasLyricsChanged() {
            const track = Players.active?.trackTitle ?? "";
            const trackChanged = track !== win.currentTrack;
            win.currentTrack = track;
            win.updateLyrics(trackChanged);
            win.updateIndex();
        }
    }

    Connections {
        target: Romaji
        function onModeChanged() {
            win.updateLyrics(false);
        }
    }

    Connections {
        target: Players
        function onActiveChanged() {
            win.syncTrack();
            const track = Players.active?.trackTitle ?? "";
            const trackChanged = track !== win.currentTrack;
            win.currentTrack = track;
            win.updateLyrics(trackChanged);
        }
    }

    Connections {
        target: Players.active
        function onTrackTitleChanged() {
            win.syncTrack();
        }
    }

    property int currentIndex: -1

    function updateIndex(): void {
        const p = Players.active;
        if (!p) {
            win.currentIndex = -1;
            return;
        }
        const idx = Lyrics.indexForTime(p.position);
        if (idx !== win.currentIndex)
            win.currentIndex = idx;
    }

    Component.onCompleted: {
        syncTrack();
        updateLyrics(true);
        updateIndex();
    }

    function cleanLyric(line) {
        if (line === undefined || line === null)
            return "";
        if (typeof line === "string")
            return line;
        if (line.text !== undefined)
            return String(line.text);
        if (line.lyric !== undefined)
            return String(line.lyric);
        if (line.words !== undefined)
            return String(line.words);
        return String(line);
    }

    function isValidLine(line) {
        const text = cleanLyric(line).trim();
        return text !== "" && text !== ". . ." && text !== "...";
    }

    readonly property string currentLineText: {
        win.currentIndex;
        win.lyricList;
        if (!Players.active)
            return qsTr("No active player");
        if (converting || Lyrics.loading)
            return Romaji.mode === "english" ? qsTr("Translating lyrics...") : qsTr("Loading lyrics...");
        if (!Lyrics.hasLyrics || !lyricList || lyricList.length === 0)
            return Romaji.mode === "english" && Lyrics.hasLyrics ? qsTr("No translation found") : qsTr("No lyrics found");
        if (currentIndex < 0)
            return ". . .";
        if (currentIndex < lyricList.length)
            return cleanLyric(lyricList[currentIndex]) || ". . .";
        return cleanLyric(lyricList[lyricList.length - 1]) || ". . .";
    }

    readonly property string nextLineText: {
        win.currentIndex;
        win.lyricList;
        if (!Lyrics.hasLyrics || !lyricList || lyricList.length === 0 || converting || Lyrics.loading)
            return "";
        const startIdx = currentIndex < 0 ? 0 : currentIndex + 1;
        for (let i = startIdx; i < lyricList.length; i++) {
            if (isValidLine(lyricList[i]))
                return cleanLyric(lyricList[i]);
        }
        return "";
    }

    IpcHandler {
        target: "floatingLyrics"
        function getInfo(): string {
            return JSON.stringify({
                currentIndex: win.currentIndex,
                currentLineText: win.currentLineText,
                nextLineText: win.nextLineText,
                hasLyrics: Lyrics.hasLyrics
            });
        }
    }

    Timer {
        running: win.visible && (Players.active?.isPlaying ?? false)
        interval: GlobalConfig.dashboard.mediaUpdateInterval
        triggeredOnStart: true
        repeat: true
        onTriggered: {
            Players.active?.positionChanged();
            win.updateIndex();
        }
    }

    Item {
        id: container

        anchors.fill: parent

        Item {
            id: contentArea

            anchors.fill: parent
            anchors.leftMargin: Tokens.padding.medium
            anchors.rightMargin: Tokens.padding.medium
            anchors.topMargin: Tokens.padding.small
            anchors.bottomMargin: Tokens.padding.small

            ColumnLayout {
                id: mainLayout

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Math.round(4 * win.effectiveScale)

                StyledText {
                    id: titleText

                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: {
                        const p = Players.active;
                        if (!p)
                            return qsTr("Floating Lyrics");
                        const title = p.trackTitle;
                        const artist = p.trackArtist;
                        if (title && artist)
                            return `${artist} - ${title}`;
                        return title || artist || qsTr("Floating Lyrics");
                    }
                    font: Tokens.font.label.builders.medium.scale(win.effectiveScale * 0.95).weight(Font.Medium).build()
                    color: Colours.palette.m3onSurfaceVariant
                    opacity: 0.70
                    elide: Text.ElideRight
                }

                StyledText {
                    id: line1

                    Layout.fillWidth: true
                    text: win.currentLineText
                    font: Tokens.font.title.builders.medium.scale(win.effectiveScale * 1.15).weight(win.lyricWeight).build()
                    lineHeightMode: Text.ProportionalHeight
                    lineHeight: 1.15
                    color: Colours.palette.m3primary
                    style: Text.Outline
                    styleColor: Qt.rgba(0, 0, 0, 0.85)
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter

                    transform: Translate {
                        id: line1Trans
                        y: 0
                    }

                    onTextChanged: {
                        if (win.visible && line1.text !== "" && line1.text !== ". . .")
                            slideAnim1.restart();
                    }

                    ParallelAnimation {
                        id: slideAnim1

                        NumberAnimation {
                            target: line1Trans
                            property: "y"
                            from: Math.round(14 * win.effectiveScale)
                            to: 0
                            duration: GameMode.enabled ? 0 : Tokens.anim.durations.normal
                            easing.type: Easing.OutCubic
                        }

                        NumberAnimation {
                            target: line1
                            property: "opacity"
                            from: 0.2
                            to: 1.0
                            duration: GameMode.enabled ? 0 : Tokens.anim.durations.normal
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                StyledText {
                    id: line2

                    Layout.fillWidth: true
                    visible: !!win.nextLineText
                    text: win.nextLineText
                    opacity: 0.65
                    font: Tokens.font.title.builders.medium.scale(win.effectiveScale * 1.05).weight(win.nextLyricWeight).build()
                    lineHeightMode: Text.ProportionalHeight
                    lineHeight: 1.15
                    color: Colours.palette.m3onSurfaceVariant
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter

                    transform: Translate {
                        id: line2Trans
                        y: 0
                    }

                    onTextChanged: {
                        if (win.visible && line2.text !== "")
                            slideAnim2.restart();
                    }

                    ParallelAnimation {
                        id: slideAnim2

                        NumberAnimation {
                            target: line2Trans
                            property: "y"
                            from: Math.round(10 * win.effectiveScale)
                            to: 0
                            duration: GameMode.enabled ? 0 : Tokens.anim.durations.normal
                            easing.type: Easing.OutCubic
                        }

                        NumberAnimation {
                            target: line2
                            property: "opacity"
                            from: 0.1
                            to: 0.65
                            duration: GameMode.enabled ? 0 : Tokens.anim.durations.normal
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}
