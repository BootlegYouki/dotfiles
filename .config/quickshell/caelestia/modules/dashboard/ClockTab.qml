import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Hyprland
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.utils

Item {
    id: root

    property bool isCompact: false

    implicitWidth: {
        if (!isCompact) return 840;
        if ((Timers.timerRunning || Timers.isOverdue) && Timers.stopwatchRunning) {
            return Timers.isOverdue ? 580 : 540;
        }
        return Timers.isOverdue ? 300 : 260;
    }
    implicitHeight: isCompact ? 76 : mainLayout.implicitHeight

    // Local Current Time (without milliseconds)
    property var currentTime: new Date()

    // Focused App Process Uptime Tracking
    property string activeAppAddress: ""
    property string activeAppClass: ""
    property string activeAppTitle: ""
    property int activeAppPid: 0
    property double activeAppStartTime: 0
    property int activeAppElapsedSec: 0

    readonly property HyprlandToplevel focusedToplevel: Hypr.activeToplevel

    Process {
        id: uptimeProc
        command: ["ps", "-p", root.activeAppPid > 0 ? root.activeAppPid.toString() : "1", "-o", "etimes="]
        stdout: StdioCollector {
            onStreamFinished: {
                const elapsed = parseInt(text.trim()) || 0;
                root.activeAppStartTime = Date.now() - (elapsed * 1000);
                root.activeAppElapsedSec = elapsed;
            }
        }
    }

    function refreshAppUptime() {
        const toplevel = root.focusedToplevel;
        const addr = toplevel?.address ?? "desktop";
        const cls = toplevel?.lastIpcObject?.class ?? "";
        const title = toplevel?.title ?? (cls ? cls : qsTr("Desktop"));
        const pid = toplevel?.lastIpcObject?.pid ?? 0;

        if (addr !== root.activeAppAddress || pid !== root.activeAppPid || root.activeAppStartTime === 0) {
            root.activeAppAddress = addr;
            root.activeAppClass = cls;
            root.activeAppTitle = title;
            root.activeAppPid = pid;

            if (uptimeProc.running) {
                uptimeProc.running = false;
            }
            uptimeProc.command = ["ps", "-p", pid > 0 ? pid.toString() : "1", "-o", "etimes="];
            uptimeProc.running = true;
        }
    }

    onFocusedToplevelChanged: refreshAppUptime()

    Component.onCompleted: {
        refreshAppUptime();
    }

    function getFormattedAppTime(totalSeconds) {
        const isHours = totalSeconds >= 3600;
        const h = Math.floor(totalSeconds / 3600);
        const m = Math.floor((totalSeconds % 3600) / 60);
        const s = totalSeconds % 60;
        return {
            isHours: isHours,
            first: isHours ? (h < 10 ? "0" + h : h.toString()) : (m < 10 ? "0" + m : m.toString()),
            second: isHours ? (m < 10 ? "0" + m : m.toString()) : (s < 10 ? "0" + s : s.toString())
        };
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.currentTime = new Date();
            if (root.activeAppStartTime > 0) {
                root.activeAppElapsedSec = Math.max(0, Math.floor((Date.now() - root.activeAppStartTime) / 1000));
            }
        }
    }

    ColumnLayout {
        id: mainLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Tokens.spacing.medium

        // --- Top Row: Hero Clock Card + Upcoming Events & Agenda Card ---
        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.medium
            visible: !root.isCompact

            // 1. Local Time Hero Card
            StyledRect {
                implicitWidth: 310
                Layout.preferredWidth: 310
                Layout.fillWidth: false
                Layout.fillHeight: true
                color: Colours.tPalette.m3surfaceContainer
                radius: Tokens.rounding.large

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Tokens.spacing.extraSmall

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatTime(root.currentTime, "hh:mm:ss")
                        font: Tokens.font.clock.size(44).weight(Font.Medium).build()
                        color: Colours.palette.m3onSurface
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatDate(root.currentTime, "dddd, MMMM d")
                        font: Tokens.font.title.medium
                        color: Colours.palette.m3onSurfaceVariant
                    }
                }
            }

            // 2. Upcoming Events & Agenda Card (Fixed 150px Height, 3-Step Sliding Wizard)
            StyledRect {
                id: agendaCard
                Layout.fillWidth: true
                implicitHeight: 150
                color: Colours.tPalette.m3surfaceContainer
                radius: Tokens.rounding.large

                property bool isAdding: false
                property int step: 0 // 0: Name, 1: Date, 2: Time
                property int currentEventIndex: 0
                property string eventTitleInput: ""
                property date weekStartDate: getStartOfWeek(new Date())
                property date selectedDate: new Date()
                property int selectedHour: (new Date().getHours() + 1) % 24
                property int selectedMinute: 0

                Connections {
                    target: Events
                    function onUpcomingEventsChanged() {
                        if (agendaCard.currentEventIndex >= Events.upcomingEvents.length) {
                            agendaCard.currentEventIndex = Math.max(0, Events.upcomingEvents.length - 1);
                        }
                    }
                }

                function getStartOfWeek(d) {
                    const res = new Date(d);
                    res.setHours(0, 0, 0, 0);
                    const day = res.getDay(); // 0 is Sunday
                    res.setDate(res.getDate() - day);
                    return res;
                }

                function getDayInWeek(index) {
                    const d = new Date(agendaCard.weekStartDate);
                    d.setDate(d.getDate() + index);
                    return d;
                }

                function getWeekRangeLabel() {
                    const start = agendaCard.weekStartDate;
                    const end = new Date(start);
                    end.setDate(end.getDate() + 6);
                    if (start.getMonth() === end.getMonth()) {
                        return Qt.formatDate(start, "MMMM yyyy");
                    } else if (start.getFullYear() === end.getFullYear()) {
                        return Qt.formatDate(start, "MMM") + " – " + Qt.formatDate(end, "MMM yyyy");
                    } else {
                        return Qt.formatDate(start, "MMM yyyy") + " – " + Qt.formatDate(end, "MMM yyyy");
                    }
                }

                function getFinalTimestamp() {
                    const d = new Date(selectedDate);
                    d.setHours(selectedHour, selectedMinute, 0, 0);
                    return d.getTime();
                }

                function saveEvent() {
                    const title = eventTitleInput.trim() || "Reminder";
                    Events.addEvent(title, getFinalTimestamp());
                    eventTitleInput = "";
                    isAdding = false;
                    step = 0;
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Tokens.padding.large
                    spacing: Tokens.spacing.small

                    // Card Header (Only visible when not adding, freeing full height for the creation steps)
                    RowLayout {
                        Layout.fillWidth: true
                        visible: !agendaCard.isAdding

                        RowLayout {
                            spacing: Tokens.spacing.extraSmall
                            Layout.alignment: Qt.AlignVCenter

                            MaterialIcon {
                                text: "event"
                                fontStyle: Tokens.font.icon.small
                                color: Colours.palette.m3primary
                            }

                            StyledText {
                                text: qsTr("Upcoming Agenda")
                                font: Tokens.font.title.small
                                color: Colours.palette.m3onSurface
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        IconButton {
                            icon: "add"
                            type: IconButton.Tonal
                            isRound: true
                            padding: Tokens.padding.extraSmall / 2
                            font: Tokens.font.icon.small
                            onClicked: {
                                agendaCard.isAdding = true;
                                agendaCard.step = 0;
                                agendaCard.selectedDate = new Date();
                                agendaCard.weekStartDate = agendaCard.getStartOfWeek(new Date());
                                titleInput.forceActiveFocus();
                            }
                        }
                    }

                    // --- VIEW MODE (when !isAdding) ---
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: !agendaCard.isAdding
                        spacing: Tokens.spacing.extraSmall

                        // Has Events: Vertical Sliding Carousel with Mouse Wheel Support
                        Item {
                            id: eventsSlideContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            visible: Events.upcomingEvents.length > 0
                            clip: true

                            // MouseArea for scrolling through multiple events
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onWheel: wheel => {
                                    if (Events.upcomingEvents.length <= 1) return;
                                    if (wheel.angleDelta.y < 0) {
                                        // Scroll down: Next event
                                        agendaCard.currentEventIndex = Math.min(Events.upcomingEvents.length - 1, agendaCard.currentEventIndex + 1);
                                    } else if (wheel.angleDelta.y > 0) {
                                        // Scroll up: Previous event
                                        agendaCard.currentEventIndex = Math.max(0, agendaCard.currentEventIndex - 1);
                                    }
                                }
                            }

                            Column {
                                id: eventsWrapper
                                width: eventsSlideContainer.width
                                y: -agendaCard.currentEventIndex * eventsSlideContainer.height

                                Behavior on y {
                                    Anim {}
                                }

                                Repeater {
                                    model: Events.upcomingEvents

                                    delegate: Item {
                                        id: eventItemDelegate
                                        required property var modelData
                                        required property int index

                                        width: eventsSlideContainer.width
                                        height: eventsSlideContainer.height

                                        RowLayout {
                                            anchors.fill: parent
                                            spacing: Tokens.spacing.medium

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                Layout.alignment: Qt.AlignVCenter
                                                spacing: 4

                                                // Row 1: Event Name (Continuous Loop Marquee if overflowing)
                                                Item {
                                                    id: titleMarquee
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: title1.implicitHeight
                                                    implicitHeight: title1.implicitHeight
                                                    clip: true

                                                    readonly property real textWidth: title1.implicitWidth
                                                    readonly property real gap: 36
                                                    readonly property bool needsLoop: textWidth > width

                                                    property real offset: 0

                                                    NumberAnimation on offset {
                                                        from: 0
                                                        to: titleMarquee.textWidth + titleMarquee.gap
                                                        duration: Math.max(2500, (titleMarquee.textWidth + titleMarquee.gap) * 25)
                                                        loops: Animation.Infinite
                                                        running: titleMarquee.needsLoop && agendaCard.currentEventIndex === eventItemDelegate.index
                                                    }

                                                    StyledText {
                                                        id: title1
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        x: titleMarquee.needsLoop ? -titleMarquee.offset : 0
                                                        text: eventItemDelegate.modelData ? eventItemDelegate.modelData.title : ""
                                                        font: Tokens.font.title.builders.large.weight(Font.DemiBold).build()
                                                        color: Colours.palette.m3onSurface
                                                    }

                                                    StyledText {
                                                        id: title2
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        visible: titleMarquee.needsLoop
                                                        x: title1.x + titleMarquee.textWidth + titleMarquee.gap
                                                        text: title1.text
                                                        font: title1.font
                                                        color: title1.color
                                                    }
                                                }

                                                // Row 2: Date & Time + Countdown + Multi-event Index
                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    spacing: Tokens.spacing.extraSmall

                                                    StyledText {
                                                        text: {
                                                            if (!eventItemDelegate.modelData) return "";
                                                            const d = new Date(eventItemDelegate.modelData.timestamp);
                                                            const timeStr = Qt.formatTime(d, "hh:mm");
                                                            const rel = Events.getRelativeTime(eventItemDelegate.modelData.timestamp);
                                                            const dateStr = Qt.formatDate(d, "MMM d, ") + timeStr;
                                                            return `${dateStr} (${rel})`;
                                                        }
                                                        font: Tokens.font.title.small
                                                        color: Colours.palette.m3primary
                                                        elide: Text.ElideRight
                                                    }

                                                    StyledText {
                                                        visible: Events.upcomingEvents.length > 1
                                                        text: qsTr("• %1 of %2").arg(eventItemDelegate.index + 1).arg(Events.upcomingEvents.length)
                                                        font: Tokens.font.label.small
                                                        color: Colours.palette.m3onSurfaceVariant
                                                    }
                                                }
                                            }

                                            // Quick Complete / Check-off Button for This Event
                                            IconButton {
                                                icon: "check"
                                                type: IconButton.Tonal
                                                isRound: true
                                                font: Tokens.font.icon.small
                                                onClicked: {
                                                    if (eventItemDelegate.modelData) {
                                                        Events.toggleEvent(eventItemDelegate.modelData.id);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // No Events: Empty State
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            visible: Events.upcomingEvents.length === 0
                            spacing: Tokens.spacing.small

                            MaterialIcon {
                                text: "event_available"
                                fontStyle: Tokens.font.icon.medium
                                color: Colours.palette.m3secondary
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                StyledText {
                                    text: qsTr("No upcoming events")
                                    font: Tokens.font.title.small
                                    color: Colours.palette.m3onSurface
                                }

                                StyledText {
                                    text: qsTr("Click + above to schedule a reminder or event.")
                                    font: Tokens.font.body.small
                                    color: Colours.palette.m3onSurfaceVariant
                                }
                            }
                        }
                    }

                    // --- SLIDING 3-STEP CREATOR (Maximized Vertical Space) ---
                    Item {
                        id: slideContainer
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: agendaCard.isAdding
                        clip: true

                        Row {
                            id: pagesWrapper
                            width: slideContainer.width * 3
                            height: slideContainer.height
                            x: -agendaCard.step * slideContainer.width

                            Behavior on x {
                                Anim {}
                            }

                            // === STEP 0: EVENT NAME ===
                            Item {
                                id: page0
                                width: slideContainer.width
                                height: slideContainer.height

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: Tokens.spacing.extraSmall

                                    // Header with Cancel Button
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: Tokens.spacing.extraSmall

                                        MaterialIcon {
                                            text: "edit"
                                            fontStyle: Tokens.font.icon.small
                                            color: Colours.palette.m3primary
                                        }

                                        StyledText {
                                            text: qsTr("Event Name")
                                            font: Tokens.font.title.small
                                            color: Colours.palette.m3onSurface
                                        }

                                        Item {
                                            Layout.fillWidth: true
                                        }

                                        IconButton {
                                            icon: "close"
                                            type: IconButton.Tonal
                                            isRound: true
                                            padding: Tokens.padding.extraSmall / 2
                                            font: Tokens.font.icon.small
                                            onClicked: {
                                                agendaCard.isAdding = false;
                                                agendaCard.step = 0;
                                            }
                                        }
                                    }

                                    // Full-Width Input Card
                                    StyledRect {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        radius: Tokens.rounding.large
                                        color: Colours.layer(Colours.palette.m3surfaceContainerHighest, 1)

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: Tokens.padding.large
                                            anchors.rightMargin: Tokens.padding.small
                                            spacing: Tokens.spacing.small

                                            TextInput {
                                                id: titleInput
                                                Layout.fillWidth: true
                                                text: agendaCard.eventTitleInput
                                                font: Tokens.font.title.medium
                                                color: Colours.palette.m3onSurface
                                                selectionColor: Qt.alpha(Colours.palette.m3primary, 0.4)
                                                selectedTextColor: color
                                                selectByMouse: true
                                                clip: true
                                                onTextChanged: agendaCard.eventTitleInput = text
                                                onAccepted: {
                                                    agendaCard.step = 1;
                                                }

                                                StyledText {
                                                    anchors.fill: parent
                                                    text: qsTr("Enter event name (e.g. Standup, Gym)...")
                                                    font: titleInput.font
                                                    color: Colours.palette.m3outline
                                                    visible: titleInput.text.length === 0 && !titleInput.activeFocus
                                                }
                                            }

                                            IconButton {
                                                icon: "arrow_forward"
                                                type: IconButton.Filled
                                                isRound: true
                                                font: Tokens.font.icon.small
                                                onClicked: {
                                                    agendaCard.step = 1;
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // === STEP 1: SELECT DATE ===
                            Item {
                                id: page1
                                width: slideContainer.width
                                height: slideContainer.height

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: Tokens.spacing.extraSmall

                                    // Header: Back to Name, Month & Year, and Cancel
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: Tokens.spacing.extraSmall

                                        IconButton {
                                            icon: "arrow_back"
                                            type: IconButton.Tonal
                                            isRound: true
                                            padding: Tokens.padding.extraSmall / 2
                                            font: Tokens.font.icon.small
                                            onClicked: {
                                                agendaCard.step = 0;
                                                titleInput.forceActiveFocus();
                                            }
                                        }

                                        IconButton {
                                            icon: "chevron_left"
                                            type: IconButton.Text
                                            isRound: true
                                            padding: Tokens.padding.extraSmall / 2
                                            font: Tokens.font.icon.small
                                            onClicked: {
                                                const d = new Date(agendaCard.weekStartDate);
                                                d.setDate(d.getDate() - 7);
                                                agendaCard.weekStartDate = d;
                                            }
                                        }

                                        StyledText {
                                            Layout.fillWidth: true
                                            horizontalAlignment: Text.AlignHCenter
                                            text: agendaCard.getWeekRangeLabel()
                                            font: Tokens.font.title.small
                                            color: Colours.palette.m3primary
                                        }

                                        IconButton {
                                            icon: "chevron_right"
                                            type: IconButton.Text
                                            isRound: true
                                            padding: Tokens.padding.extraSmall / 2
                                            font: Tokens.font.icon.small
                                            onClicked: {
                                                const d = new Date(agendaCard.weekStartDate);
                                                d.setDate(d.getDate() + 7);
                                                agendaCard.weekStartDate = d;
                                            }
                                        }

                                        IconButton {
                                            icon: "close"
                                            type: IconButton.Tonal
                                            isRound: true
                                            padding: Tokens.padding.extraSmall / 2
                                            font: Tokens.font.icon.small
                                            onClicked: {
                                                agendaCard.isAdding = false;
                                                agendaCard.step = 0;
                                            }
                                        }
                                    }

                                    // 7-Day Horizontal Week Strip (Spacious Full Height)
                                    RowLayout {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        spacing: Tokens.spacing.extraSmall

                                        Repeater {
                                            model: 7

                                            delegate: StyledRect {
                                                id: weekDayCell
                                                required property int index

                                                readonly property date cellDate: agendaCard.getDayInWeek(index)
                                                readonly property bool isToday: {
                                                    const now = new Date();
                                                    return cellDate.getDate() === now.getDate() &&
                                                           cellDate.getMonth() === now.getMonth() &&
                                                           cellDate.getFullYear() === now.getFullYear();
                                                }
                                                readonly property bool isSelected: {
                                                    return agendaCard.selectedDate.getDate() === cellDate.getDate() &&
                                                           agendaCard.selectedDate.getMonth() === cellDate.getMonth() &&
                                                           agendaCard.selectedDate.getFullYear() === cellDate.getFullYear();
                                                }

                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                radius: Tokens.rounding.medium
                                                color: isSelected
                                                    ? Colours.palette.m3primary
                                                    : (dayMouse.containsMouse 
                                                        ? Colours.layer(Colours.palette.m3primary, 0.15) 
                                                        : Colours.layer(Colours.palette.m3surfaceContainerHighest, 1))

                                                Behavior on color {
                                                    ColorAnimation { duration: 120 }
                                                }

                                                ColumnLayout {
                                                    anchors.centerIn: parent
                                                    spacing: 2

                                                    StyledText {
                                                        Layout.alignment: Qt.AlignHCenter
                                                        text: Qt.formatDate(weekDayCell.cellDate, "ddd")
                                                        font: Tokens.font.label.small
                                                        color: weekDayCell.isSelected
                                                            ? Colours.palette.m3onPrimary
                                                            : (weekDayCell.isToday ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant)
                                                    }

                                                    StyledText {
                                                        Layout.alignment: Qt.AlignHCenter
                                                        text: weekDayCell.cellDate.getDate().toString()
                                                        font: weekDayCell.isSelected
                                                            ? Tokens.font.title.builders.small.weight(Font.Bold).build()
                                                            : Tokens.font.title.small
                                                        color: weekDayCell.isSelected
                                                            ? Colours.palette.m3onPrimary
                                                            : (weekDayCell.isToday ? Colours.palette.m3primary : Colours.palette.m3onSurface)
                                                    }
                                                }

                                                MouseArea {
                                                    id: dayMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        agendaCard.selectedDate = weekDayCell.cellDate;
                                                        agendaCard.step = 2; // Smoothly slide to Step 2: Time!
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // === STEP 2: SET TIME ===
                            Item {
                                id: page2
                                width: slideContainer.width
                                height: slideContainer.height

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: Tokens.spacing.extraSmall

                                    // Header with Back Arrow, Selected Date, Save & Close
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: Tokens.spacing.extraSmall

                                        IconButton {
                                            icon: "arrow_back"
                                            type: IconButton.Tonal
                                            isRound: true
                                            padding: Tokens.padding.extraSmall / 2
                                            font: Tokens.font.icon.small
                                            onClicked: {
                                                agendaCard.step = 1; // Slide back to Date!
                                            }
                                        }

                                        StyledText {
                                            text: Qt.formatDate(agendaCard.selectedDate, "MMM d, yyyy")
                                            font: Tokens.font.title.small
                                            color: Colours.palette.m3primary
                                        }

                                        Item {
                                            Layout.fillWidth: true
                                        }

                                        IconButton {
                                            icon: "check"
                                            type: IconButton.Filled
                                            isRound: true
                                            padding: Tokens.padding.extraSmall / 2
                                            font: Tokens.font.icon.small
                                            onClicked: agendaCard.saveEvent()
                                        }

                                        IconButton {
                                            icon: "close"
                                            type: IconButton.Tonal
                                            isRound: true
                                            padding: Tokens.padding.extraSmall / 2
                                            font: Tokens.font.icon.small
                                            onClicked: {
                                                agendaCard.isAdding = false;
                                                agendaCard.step = 0;
                                            }
                                        }
                                    }

                                    // Clean 24-Hour Digits Display (Spacious Full Height)
                                    StyledRect {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        radius: Tokens.rounding.large
                                        color: Colours.layer(Colours.palette.m3surfaceContainerHighest, 1)

                                        RowLayout {
                                            anchors.centerIn: parent
                                            spacing: Tokens.spacing.small

                                            // 24H Hours Block
                                            StyledRect {
                                                implicitWidth: 80
                                                implicitHeight: 52
                                                radius: Tokens.rounding.medium
                                                color: hourMouse.containsMouse 
                                                    ? Colours.layer(Colours.palette.m3primary, 0.15) 
                                                    : "transparent"

                                                Behavior on color {
                                                    ColorAnimation { duration: 120 }
                                                }

                                                StyledText {
                                                    anchors.centerIn: parent
                                                    text: agendaCard.selectedHour < 10 ? "0" + agendaCard.selectedHour : agendaCard.selectedHour.toString()
                                                    font: Tokens.font.clock.size(44).weight(Font.Medium).build()
                                                    color: Colours.palette.m3onSurface
                                                }

                                                MouseArea {
                                                    id: hourMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    onWheel: wheel => {
                                                        if (wheel.angleDelta.y > 0) {
                                                            agendaCard.selectedHour = (agendaCard.selectedHour + 1) % 24;
                                                        } else if (wheel.angleDelta.y < 0) {
                                                            agendaCard.selectedHour = (agendaCard.selectedHour + 23) % 24;
                                                        }
                                                    }
                                                }
                                            }

                                            // Colon Separator
                                            StyledText {
                                                text: ":"
                                                font: Tokens.font.clock.size(38).weight(Font.Medium).build()
                                                color: Colours.palette.m3primary
                                            }

                                            // 24H Minutes Block
                                            StyledRect {
                                                implicitWidth: 80
                                                implicitHeight: 52
                                                radius: Tokens.rounding.medium
                                                color: minMouse.containsMouse 
                                                    ? Colours.layer(Colours.palette.m3primary, 0.15) 
                                                    : "transparent"

                                                Behavior on color {
                                                    ColorAnimation { duration: 120 }
                                                }

                                                StyledText {
                                                    anchors.centerIn: parent
                                                    text: agendaCard.selectedMinute < 10 ? "0" + agendaCard.selectedMinute : agendaCard.selectedMinute.toString()
                                                    font: Tokens.font.clock.size(44).weight(Font.Medium).build()
                                                    color: Colours.palette.m3secondary
                                                }

                                                MouseArea {
                                                    id: minMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    onWheel: wheel => {
                                                        if (wheel.angleDelta.y > 0) {
                                                            agendaCard.selectedMinute = (agendaCard.selectedMinute + 5) % 60;
                                                        } else if (wheel.angleDelta.y < 0) {
                                                            agendaCard.selectedMinute = (agendaCard.selectedMinute + 55) % 60;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // --- Bottom Row: Focused App Uptime, Countdown Timer & Stopwatch Cards ---
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: Tokens.spacing.medium

            // === 1. Focused App Uptime Card ===
            StyledRect {
                id: appUptimeCard
                implicitWidth: root.isCompact ? 260 : 200
                Layout.preferredWidth: 200
                Layout.fillWidth: false
                implicitHeight: root.isCompact ? 76 : 180
                color: Colours.tPalette.m3surfaceContainer
                radius: Tokens.rounding.large
                visible: !root.isCompact

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Tokens.spacing.small

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("App Uptime")
                        font: Tokens.font.label.large
                        color: Colours.palette.m3onSurfaceVariant
                    }

                    // Time Digits: [ MM : SS ] (< 1h) or [ HH : MM ] (≥ 1h)
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 8

                        StyledText {
                            text: root.getFormattedAppTime(root.activeAppElapsedSec).first
                            font: Tokens.font.clock.size(36).weight(Font.Medium).build()
                            color: Colours.palette.m3onSurface
                        }

                        StyledText {
                            text: ":"
                            font.pixelSize: 34
                            font.weight: Font.Medium
                            color: Colours.palette.m3onSurfaceVariant
                        }

                        StyledText {
                            text: root.getFormattedAppTime(root.activeAppElapsedSec).second
                            font: Tokens.font.clock.size(36).weight(Font.Medium).build()
                            color: Colours.palette.m3secondary
                        }
                    }

                    // App Badge Pill
                    StyledRect {
                        Layout.alignment: Qt.AlignHCenter
                        implicitHeight: 36
                        implicitWidth: Math.min(appInfoRow.implicitWidth + Tokens.padding.large * 2, 175)
                        color: Colours.layer(Colours.palette.m3surfaceContainerHighest, 1)
                        radius: Tokens.rounding.full

                        RowLayout {
                            id: appInfoRow
                            anchors.centerIn: parent
                            spacing: Tokens.spacing.extraSmall

                            IconImage {
                                asynchronous: true
                                implicitSize: 18
                                source: Icons.getAppIcon(root.activeAppClass, "image-missing")
                            }

                            StyledText {
                                text: root.activeAppTitle.length > 0 ? root.activeAppTitle : (root.activeAppClass.length > 0 ? root.activeAppClass : qsTr("Desktop"))
                                font: Tokens.font.label.small
                                color: Colours.palette.m3onSurface
                                elide: Text.ElideRight
                                Layout.maximumWidth: 120
                            }
                        }
                    }
                }
            }

            // === 2. Countdown Timer Card ===
            StyledRect {
                id: timerCard
                implicitWidth: root.isCompact ? (Timers.isOverdue ? 300 : 260) : 0
                Layout.fillWidth: !root.isCompact
                implicitHeight: root.isCompact ? 76 : 180
                color: Colours.tPalette.m3surfaceContainer
                radius: Tokens.rounding.large
                visible: !root.isCompact || Timers.timerRunning || Timers.isOverdue

                Behavior on implicitWidth {
                    Anim {}
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Tokens.spacing.small

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: Timers.isOverdue ? qsTr("Timer Overdue") : qsTr("Timer")
                        font: Tokens.font.label.large
                        color: Timers.isOverdue ? Colours.palette.m3error : Colours.palette.m3onSurfaceVariant
                        visible: !root.isCompact
                    }

                    // Overdue Digits: [ - HH : MM : SS ]
                    RowLayout {
                        visible: Timers.isOverdue
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 8

                        StyledText {
                            text: "-"
                            font: Tokens.font.clock.size(36).weight(Font.Bold).build()
                            color: Colours.palette.m3error
                        }

                        StyledText {
                            text: Timers.getHours(Timers.overdueSeconds)
                            font: Tokens.font.clock.size(36).weight(Font.Medium).build()
                            color: Colours.palette.m3error
                        }

                        StyledText {
                            text: ":"
                            font.pixelSize: 34
                            font.weight: Font.Medium
                            color: Colours.palette.m3error
                        }

                        StyledText {
                            text: Timers.getMinutes(Timers.overdueSeconds)
                            font: Tokens.font.clock.size(36).weight(Font.Medium).build()
                            color: Colours.palette.m3error
                        }

                        StyledText {
                            text: ":"
                            font.pixelSize: 34
                            font.weight: Font.Medium
                            color: Colours.palette.m3error
                        }

                        StyledText {
                            text: Timers.getSeconds(Timers.overdueSeconds)
                            font: Tokens.font.clock.size(36).weight(Font.Medium).build()
                            color: Colours.palette.m3error
                        }
                    }

                    // Time Digits: [ HH : MM : SS ] (Normal mode)
                    RowLayout {
                        visible: !Timers.isOverdue
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Tokens.spacing.extraSmall

                        // Hours Block
                        StyledRect {
                            implicitWidth: 68
                            implicitHeight: 52
                            radius: Tokens.rounding.medium
                            color: (!Timers.timerRunning && timerHourMouse.containsMouse)
                                ? Colours.layer(Colours.palette.m3primary, 0.15)
                                : "transparent"

                            Behavior on color {
                                ColorAnimation { duration: 120 }
                            }

                            StyledText {
                                anchors.centerIn: parent
                                text: Timers.getHours(Timers.timerRemaining)
                                font: Tokens.font.clock.size(36).weight(Font.Medium).build()
                                color: Timers.timerRemaining === 0 ? Colours.palette.m3error : Colours.palette.m3onSurface
                            }

                            MouseArea {
                                id: timerHourMouse
                                anchors.fill: parent
                                hoverEnabled: !Timers.timerRunning
                                onWheel: wheel => {
                                    if (wheel.angleDelta.y > 0) {
                                        Timers.adjustHours(1);
                                    } else if (wheel.angleDelta.y < 0) {
                                        Timers.adjustHours(-1);
                                    }
                                }
                            }
                        }

                        // Colon Separator
                        StyledText {
                            text: ":"
                            font.pixelSize: 34
                            font.weight: Font.Medium
                            color: Colours.palette.m3onSurfaceVariant
                        }

                        // Minutes Block
                        StyledRect {
                            implicitWidth: 68
                            implicitHeight: 52
                            radius: Tokens.rounding.medium
                            color: (!Timers.timerRunning && timerMinMouse.containsMouse)
                                ? Colours.layer(Colours.palette.m3primary, 0.15)
                                : "transparent"

                            Behavior on color {
                                ColorAnimation { duration: 120 }
                            }

                            StyledText {
                                anchors.centerIn: parent
                                text: Timers.getMinutes(Timers.timerRemaining)
                                font: Tokens.font.clock.size(36).weight(Font.Medium).build()
                                color: Timers.timerRemaining === 0 ? Colours.palette.m3error : Colours.palette.m3onSurface
                            }

                            MouseArea {
                                id: timerMinMouse
                                anchors.fill: parent
                                hoverEnabled: !Timers.timerRunning
                                onWheel: wheel => {
                                    if (wheel.angleDelta.y > 0) {
                                        Timers.adjustMinutes(1);
                                    } else if (wheel.angleDelta.y < 0) {
                                        Timers.adjustMinutes(-1);
                                    }
                                }
                            }
                        }

                        // Colon Separator
                        StyledText {
                            text: ":"
                            font.pixelSize: 34
                            font.weight: Font.Medium
                            color: Colours.palette.m3onSurfaceVariant
                        }

                        // Seconds Block
                        StyledRect {
                            implicitWidth: 68
                            implicitHeight: 52
                            radius: Tokens.rounding.medium
                            color: (!Timers.timerRunning && timerSecMouse.containsMouse)
                                ? Colours.layer(Colours.palette.m3primary, 0.15)
                                : "transparent"

                            Behavior on color {
                                ColorAnimation { duration: 120 }
                            }

                            StyledText {
                                anchors.centerIn: parent
                                text: Timers.getSeconds(Timers.timerRemaining)
                                font: Tokens.font.clock.size(36).weight(Font.Medium).build()
                                color: Timers.timerRemaining === 0 ? Colours.palette.m3error : Colours.palette.m3onSurface
                            }

                            MouseArea {
                                id: timerSecMouse
                                anchors.fill: parent
                                hoverEnabled: !Timers.timerRunning
                                onWheel: wheel => {
                                    if (wheel.angleDelta.y > 0) {
                                        Timers.adjustSeconds(1);
                                    } else if (wheel.angleDelta.y < 0) {
                                        Timers.adjustSeconds(-1);
                                    }
                                }
                            }
                        }
                    }

                    // Overdue Action Buttons (Full Dashboard)
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Tokens.spacing.medium
                        visible: !root.isCompact && Timers.isOverdue

                        IconButton {
                            icon: "add"
                            type: IconButton.Tonal
                            isRound: true
                            font: Tokens.font.icon.medium
                            onClicked: Timers.addFiveMinutes()
                        }

                        IconButton {
                            icon: "replay"
                            type: IconButton.Tonal
                            isRound: true
                            font: Tokens.font.icon.medium
                            onClicked: Timers.restartTimer()
                        }

                        IconButton {
                            icon: "close"
                            type: IconButton.Tonal
                            isRound: true
                            font: Tokens.font.icon.medium
                            onClicked: Timers.resetTimer()
                        }
                    }

                    // Action Buttons (Play/Pause & Reset) - Normal Mode in full dashboard
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Tokens.spacing.medium
                        visible: !root.isCompact && !Timers.isOverdue

                        IconButton {
                            icon: Timers.timerRunning ? "pause" : "play_arrow"
                            type: Timers.timerRunning ? IconButton.Filled : IconButton.Tonal
                            isRound: true
                            font: Tokens.font.icon.medium
                            onClicked: Timers.toggleTimer()
                        }

                        IconButton {
                            icon: "replay"
                            type: IconButton.Tonal
                            isRound: true
                            font: Tokens.font.icon.medium
                            onClicked: Timers.resetTimer()
                        }
                    }
                }
            }

            // === 2. Stopwatch Card ===
            StyledRect {
                id: stopwatchCard
                implicitWidth: root.isCompact ? 260 : 0
                Layout.fillWidth: !root.isCompact
                implicitHeight: root.isCompact ? 76 : 180
                color: Colours.tPalette.m3surfaceContainer
                radius: Tokens.rounding.large
                visible: !root.isCompact || Timers.stopwatchRunning

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Tokens.spacing.small

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Stopwatch")
                        font: Tokens.font.label.large
                        color: Colours.palette.m3onSurfaceVariant
                        visible: !root.isCompact
                    }

                    // Time Digits: [ MM : SS . MS ]
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 8

                        StyledText {
                            text: Timers.getStopwatchMinutes(Timers.stopwatchMs)
                            font: Tokens.font.clock.size(36).weight(Font.Medium).build()
                            color: Colours.palette.m3onSurface
                        }

                        StyledText {
                            text: ":"
                            font.pixelSize: 34
                            font.weight: Font.Medium
                            color: Colours.palette.m3onSurfaceVariant
                        }

                        StyledText {
                            text: Timers.getStopwatchSeconds(Timers.stopwatchMs)
                            font: Tokens.font.clock.size(36).weight(Font.Medium).build()
                            color: Colours.palette.m3onSurface
                        }

                        StyledText {
                            text: "."
                            font.pixelSize: 34
                            font.weight: Font.Bold
                            color: Colours.palette.m3primary
                        }

                        StyledText {
                            text: Timers.getStopwatchMs(Timers.stopwatchMs)
                            font: Tokens.font.clock.size(36).weight(Font.Medium).build()
                            color: Timers.stopwatchRunning ? Colours.palette.m3primary : Colours.palette.m3onSurface
                        }
                    }

                    // Action Buttons (Play/Pause & Reset) - ONLY visible in full dashboard
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Tokens.spacing.medium
                        visible: !root.isCompact

                        IconButton {
                            icon: Timers.stopwatchRunning ? "pause" : "play_arrow"
                            type: Timers.stopwatchRunning ? IconButton.Filled : IconButton.Tonal
                            isRound: true
                            font: Tokens.font.icon.medium
                            onClicked: Timers.toggleStopwatch()
                        }

                        IconButton {
                            icon: "replay"
                            type: IconButton.Tonal
                            isRound: true
                            font: Tokens.font.icon.medium
                            onClicked: Timers.resetStopwatch()
                        }
                    }
                }
            }
        }

        // --- 3rd Row: Quick Presets Strip ---
        StyledRect {
            Layout.fillWidth: true
            implicitHeight: 52
            color: Colours.tPalette.m3surfaceContainer
            radius: Tokens.rounding.large
            visible: !root.isCompact

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Tokens.padding.large
                anchors.rightMargin: Tokens.padding.large
                spacing: Tokens.spacing.small

                // Preset Chips (evenly spaced across width)
                Repeater {
                    model: [
                        { name: "1m", sec: 60, icon: "timer" },
                        { name: "3m", sec: 180, icon: "local_cafe" },
                        { name: "5m", sec: 300, icon: "coffee" },
                        { name: "10m", sec: 600, icon: "self_improvement" },
                        { name: "15m", sec: 900, icon: "bedtime" },
                        { name: "25m", sec: 1500, icon: "psychology" },
                        { name: "30m", sec: 1800, icon: "timelapse" },
                        { name: "45m", sec: 2700, icon: "work" },
                        { name: "1h", sec: 3600, icon: "hourglass_bottom" }
                    ]

                    delegate: StyledRect {
                        id: presetChip
                        required property var modelData
                        required property int index

                        Layout.fillWidth: true
                        implicitHeight: 34
                        radius: Tokens.rounding.full
                        color: chipMouseArea.containsMouse
                            ? Colours.layer(Colours.palette.m3primary, 0.18)
                            : Colours.layer(Colours.palette.m3surfaceContainerHighest, 1)

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }

                        RowLayout {
                            id: chipContent
                            anchors.centerIn: parent
                            spacing: Tokens.spacing.extraSmall

                            MaterialIcon {
                                text: presetChip.modelData.icon
                                fontStyle: Tokens.font.icon.small
                                color: chipMouseArea.containsMouse ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                            }

                            StyledText {
                                text: presetChip.modelData.name
                                font: Tokens.font.label.medium
                                color: chipMouseArea.containsMouse ? Colours.palette.m3primary : Colours.palette.m3onSurface
                            }
                        }

                        MouseArea {
                            id: chipMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Timers.setAndStartTimer(presetChip.modelData.sec);
                            }
                        }
                    }
                }
            }
        }
    }
}
