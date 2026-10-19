import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Io

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: root

        required property var modelData
        screen: modelData

        // ==========================================
        // UNSC // REACH TACTICAL INTERFACE
        // ==========================================

        readonly property color background: "#101610"
        readonly property color foreground: "#D5DEC8"
        readonly property color highlight: "#35442F"
        readonly property color urgent: "#E9AD4C"

        readonly property color unscGreen: "#9BAF75"
        readonly property color mutedGreen: "#657751"
        readonly property color panelBackground: "#1A221B"
        readonly property color inactive: "#515D4D"

        readonly property color armor: "#252E26"
        readonly property color armorLight: "#303B30"
        readonly property color borderColor: "#46563C"
        readonly property color tacticalAmber: "#E9AD4C"
        readonly property color hudWhite: "#E1E8D7"
        readonly property color dangerRed: "#D66D5B"
        readonly property color dimText: "#7F8C70"

        readonly property string hudFont: "monospace"

        // ==========================================
        // COMPOSITOR DETECTION
        // ==========================================

        property string compositor: ""

        function activateCompositor(name) {
            root.compositor = name

            console.log(
                "UNSC HUD:",
                root.screen.name,
                "compositor =",
                name
            )

            if (name === "hyprland") {
                mangoWatcher.running = false
            } else {
                seedMangoPlaceholders()
                mangoInit.running = true
                mangoWatcher.running = true
            }
        }

        Process {
            id: hyprlandDetect
            command: [
                "sh", "-c",
                "printf '%s' \"$HYPRLAND_INSTANCE_SIGNATURE\""
            ]
            running: true

            stdout: StdioCollector {
                onStreamFinished: {
                    root.activateCompositor(
                        this.text.trim().length > 0
                            ? "hyprland"
                            : "mango"
                    )
                }
            }
        }

        // ==========================================
        // WORKSPACE DATA
        // ==========================================

        ListModel {
            id: workspaceModel
        }

        function switchWorkspace(id) {
            if (root.compositor === "hyprland") {
                Hyprland.dispatch("workspace " + id)
            } else if (root.compositor === "mango") {
                Quickshell.execDetached([
                    "mmsg", "dispatch", "view," + id
                ])
            }
        }

        // ==========================================
        // HYPRLAND WORKSPACES
        // ==========================================

        Repeater {
            model: ScriptModel {
                values: root.compositor === "hyprland"
                    ? Hyprland.workspaces.values.filter(
                        ws => !ws.name.startsWith("special:")
                    )
                    : []
            }

            delegate: Rectangle {
                required property var modelData

                width: 32
                height: 28
                radius: 2

                property bool hovered: false

                color: modelData.focused
                    ? root.highlight
                    : hovered
                        ? root.armor
                        : root.background

                border.width: modelData.focused || hovered ? 1 : 0
                border.color: root.unscGreen

                Text {
                    anchors.centerIn: parent
                    text: modelData.name
                    color: modelData.focused
                        ? root.hudWhite
                        : root.foreground
                    font.family: root.hudFont
                    font.pixelSize: 12
                    font.bold: modelData.focused || parent.hovered
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: parent.hovered = true
                    onExited: parent.hovered = false
                    onClicked: modelData.activate()
                }
            }
        }

        Connections {
            target: Hyprland.workspaces
            enabled: root.compositor === "hyprland"

            function onValuesChanged() {
                // Workspace objects update through ScriptModel.
            }
        }

        // ==========================================
        // MANGOWC WORKSPACES
        // ==========================================

        function seedMangoPlaceholders() {
            workspaceModel.clear()

            for (var i = 1; i <= 9; ++i) {
                workspaceModel.append({
                    workspaceId: i,
                    focused: false,
                    occupied: false,
                    urgent: false
                })
            }
        }

        function handleMangoUpdate(text) {
            var parsed

            try {
                parsed = JSON.parse(text)
            } catch (e) {
                console.log("Mango workspace parse failed:", e)
                return
            }

            var monitors = parsed.all_tags
            if (!Array.isArray(monitors))
                return

            var mine = null

            for (var i = 0; i < monitors.length; ++i) {
                if (monitors[i].monitor === root.screen.name) {
                    mine = monitors[i]
                    break
                }
            }

            if (!mine || !Array.isArray(mine.tags))
                return

            workspaceModel.clear()

            for (var j = 0; j < mine.tags.length; ++j) {
                var tag = mine.tags[j]

                workspaceModel.append({
                    workspaceId: tag.index,
                    focused: !!tag.is_active,
                    occupied: tag.client_count > 0,
                    urgent: !!tag.is_urgent
                })
            }
        }

        Process {
            id: mangoInit
            command: ["mmsg", "get", "all-tags"]
            running: false

            stdout: StdioCollector {
                onStreamFinished: {
                    root.handleMangoUpdate(this.text)
                    if (root.compositor === "mango")
                        mangoWatcher.running = true
                }
            }
        }

        Process {
            id: mangoWatcher
            command: ["mmsg", "watch", "all-tags"]
            running: false

            stdout: SplitParser {
                splitMarker: "\n"

                onRead: data => {
                    var line = data.trim()
                    if (line.length > 0)
                        root.handleMangoUpdate(line)
                }
            }

            onExited: (exitCode, exitStatus) => {
                if (root.compositor === "mango")
                    mangoRestartTimer.start()
            }
        }

        Timer {
            id: mangoRestartTimer
            interval: 2000
            repeat: false

            onTriggered: {
                if (root.compositor === "mango"
                        && !mangoWatcher.running) {
                    mangoWatcher.running = true
                }
            }
        }

        // ==========================================
        // MULLVAD SECURE LINK
        // ==========================================

        property bool mullvadConnected: false
        property bool mullvadStatusKnown: false

        Process {
            id: mullvadCheck
            command: ["mullvad", "status"]
            running: true

            stdout: SplitParser {
                splitMarker: "\n"

                onRead: data => {
                    var status = data.trim().toLowerCase()

                    if (status.includes("disconnected")) {
                        root.mullvadConnected = false
                        root.mullvadStatusKnown = true
                    } else if (status.includes("connected")) {
                        root.mullvadConnected = true
                        root.mullvadStatusKnown = true
                    }
                }
            }

            onExited: (exitCode, exitStatus) => {
                if (exitCode !== 0)
                    root.mullvadStatusKnown = false
            }
        }

        Timer {
            interval: 5000
            running: true
            repeat: true

            onTriggered: {
                if (!mullvadCheck.running)
                    mullvadCheck.running = true
            }
        }

        // ==========================================
        // BAR WINDOW
        // ==========================================

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 42
        color: root.background

        // Top armor seam
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: root.borderColor
        }

        // Lower HUD rail
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: root.mutedGreen
        }

        // UNSC identification plate
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 9
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Rectangle {
                width: 3
                height: 25
                color: root.unscGreen
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text {
                    text: "UNSC"
                    color: root.unscGreen
                    font.family: root.hudFont
                    font.pixelSize: 10
                    font.bold: true
                }

                Text {
                    text: "REACH // 2552"
                    color: root.dimText
                    font.family: root.hudFont
                    font.pixelSize: 7
                }
            }
        }

        // ==========================================
        // MANGOWC WORKSPACE TACTICAL TABS
        // ==========================================

        Row {
            id: workspaces

            anchors.left: parent.left
            anchors.leftMargin: 100
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Repeater {
                model: workspaceModel

                delegate: Rectangle {
                    id: workspaceButton

                    required property var workspaceId
                    required property bool focused
                    required property bool occupied
                    required property bool urgent

                    property bool hovered: false

                    width: 30
                    height: 29
                    radius: 2

                    color: focused
                        ? root.highlight
                        : hovered
                            ? root.armor
                            : root.background

                    border.width: focused || hovered ? 1 : 0
                    border.color: focused
                        ? root.unscGreen
                        : root.borderColor

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 1

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: workspaceButton.workspaceId

                            color: workspaceButton.urgent
                                ? root.tacticalAmber
                                : workspaceButton.focused
                                    ? root.hudWhite
                                    : workspaceButton.occupied
                                        ? root.unscGreen
                                        : root.inactive

                            font.family: root.hudFont
                            font.pixelSize: 12
                            font.bold: workspaceButton.focused
                                || workspaceButton.hovered
                        }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 12
                            height: 2
                            color: workspaceButton.urgent
                                ? root.tacticalAmber
                                : root.unscGreen

                            visible: workspaceButton.focused
                                || workspaceButton.urgent
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onEntered: workspaceButton.hovered = true
                        onExited: workspaceButton.hovered = false

                        onClicked: root.switchWorkspace(
                            workspaceButton.workspaceId
                        )
                    }
                }
            }
        }

        // ==========================================
        // AUDIO SIGNAL DISPLAY
        // ==========================================

        Row {
            id: visualizer

            anchors.right: controlButton.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter

            width: 38
            height: 24
            spacing: 2

            property var levels: [0, 0, 0, 0, 0, 0, 0, 0]

            Process {
                id: cava

                command: [
                    "bash", "-c",
                    "printf '%s\\n' " +
                    "'[general]' " +
                    "'framerate = 30' " +
                    "'bars = 8' " +
                    "'autosens = 1' " +
                    "'sensitivity = 100' " +
                    "'[input]' " +
                    "'method = pulse' " +
                    "'source = auto' " +
                    "'[output]' " +
                    "'method = raw' " +
                    "'channels = mono' " +
                    "'data_format = ascii' " +
                    "'ascii_max_range = 100' " +
                    "'bar_delimiter = 59' " +
                    "'frame_delimiter = 10' " +
                    "'[smoothing]' " +
                    "'monstercat = 1' " +
                    "'waves = 0' " +
                    "'gravity = 100' " +
                    "'integral = 70' " +
                    "'ignore = 0' " +
                    "| cava -p /dev/stdin"
                ]

                running: true

                stdout: SplitParser {
                    splitMarker: "\n"

                    onRead: data => {
                        var values = data.trim().split(";")
                        if (values.length < 8)
                            return

                        var newLevels = []

                        for (var i = 0; i < 8; ++i) {
                            var value = parseFloat(values[i])
                            if (isNaN(value))
                                value = 0

                            newLevels.push(
                                Math.max(0, Math.min(1, value / 100))
                            )
                        }

                        visualizer.levels = newLevels
                    }
                }

                stderr: SplitParser {
                    splitMarker: "\n"
                    onRead: data => console.log("CAVA:", data)
                }
            }

            Repeater {
                model: 8

                delegate: Rectangle {
                    required property int index

                    width: 3
                    radius: 0
                    anchors.verticalCenter: parent.verticalCenter

                    property real audioLevel:
                        visualizer.levels[index] ?? 0

                    height: Math.max(2, audioLevel * 20)

                    color: audioLevel > 0.75
                        ? root.tacticalAmber
                        : root.unscGreen

                    opacity: audioLevel > 0.02 ? 1.0 : 0.35

                    Behavior on height {
                        NumberAnimation {
                            duration: 60
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }
        }

        // ==========================================
        // SECURE LINK STATUS
        // ==========================================

        Rectangle {
            id: mullvadIndicator

            anchors.right: clockText.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter

            width: 56
            height: 28
            radius: 2
            color: root.panelBackground

            border.width: 1
            border.color: root.borderColor

            Row {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: "◆"
                    color: !root.mullvadStatusKnown
                        ? root.tacticalAmber
                        : root.mullvadConnected
                            ? root.unscGreen
                            : root.dangerRed

                    font.pixelSize: 9
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: root.mullvadConnected ? "SEC" : "VPN"
                    color: root.foreground
                    font.family: root.hudFont
                    font.pixelSize: 8
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    Quickshell.execDetached(["mullvad", "status"])
                }
            }
        }

        // ==========================================
        // SYSTEM CLOCK
        // ==========================================

        Column {
            id: clockText

            anchors.centerIn: parent
            spacing: 0

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "SYSTEM LOCAL TIME"
                color: root.mutedGreen
                font.family: root.hudFont
                font.pixelSize: 7
                font.letterSpacing: 1
            }

            Text {
                id: clockValue
                anchors.horizontalCenter: parent.horizontalCenter

                color: root.hudWhite
                font.family: root.hudFont
                font.pixelSize: 17
                font.bold: true
                font.letterSpacing: 2

                text: Qt.formatTime(new Date(), "HH:mm")

                Timer {
                    interval: 1000
                    running: true
                    repeat: true

                    onTriggered: {
                        clockValue.text = Qt.formatTime(
                            new Date(), "HH:mm"
                        )
                    }
                }
            }
        }

        // ==========================================
        // TACTICAL MENU CONTROL
        // ==========================================

        Rectangle {
            id: controlButton

            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter

            width: 46
            height: 32
            radius: 2

            property bool panelOpen: false
            property bool hovered: false

            color: panelOpen
                ? root.highlight
                : hovered
                    ? root.armor
                    : root.background

            border.width: panelOpen || hovered ? 1 : 0
            border.color: root.unscGreen

            Behavior on color {
                ColorAnimation { duration: 100 }
            }

            Row {
                anchors.centerIn: parent
                spacing: 5

                Text {
                    text: "▤"
                    color: controlButton.panelOpen
                        ? root.tacticalAmber
                        : root.unscGreen
                    font.pixelSize: 19
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "SYS"
                    color: root.foreground
                    font.family: root.hudFont
                    font.pixelSize: 9
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onEntered: controlButton.hovered = true
                onExited: controlButton.hovered = false

                onClicked: {
                    controlButton.panelOpen =
                        !controlButton.panelOpen
                }
            }
        }

        // ==========================================
        // CONTROL PANEL
        // ==========================================

        ControlPanel {
            id: controlPanel

            anchorItem: controlButton
            visible: controlButton.panelOpen

            onVisibleChanged: {
                if (!visible)
                    controlButton.panelOpen = false
            }
        }
    }
}
