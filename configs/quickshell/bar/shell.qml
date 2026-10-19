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

        // =========================
        // THEME
        // =========================

        readonly property color background: "#1f1f1f"
        readonly property color foreground: "#d4d4d4"
        readonly property color highlight: "#3a3a3a"
        readonly property color urgent: "#f38ba8"

        // =========================
        // COMPOSITOR DETECTION
        // =========================

        property string compositor: ""

        function activateCompositor(name) {
            root.compositor = name

            console.log(
                "WORKSPACES:",
                root.screen.name,
                "using compositor =",
                name
            )

            if (name === "hyprland") {
                mangoWatcher.running = false
                refreshHyprlandWorkspaces()
            } else {
                seedMangoPlaceholders()
                mangoInit.running = true
                mangoWatcher.running = true
            }
        }

        Process {
            id: hyprlandDetect

            command: [
                "sh",
                "-c",
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

       
        // =========================
        // WORKSPACES
        // =========================

        ListModel {
            id: workspaceModel
        }

        function switchWorkspace(id) {
            if (root.compositor === "hyprland") {
                Hyprland.dispatch("workspace " + id)
            } else if (root.compositor === "mango") {
                Quickshell.execDetached([
                    "mmsg",
                    "dispatch",
                    "view," + id
                ])
            }
        }

    // ---- Hyprland ----

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
            radius: 4

            property bool hovered: false

            color: modelData.focused || hovered
                ? root.highlight
                : root.background

            Text {
                anchors.centerIn: parent

                text: modelData.name
                color: root.foreground

                font.pixelSize: 14
                font.bold: modelData.focused || parent.parent.hovered
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
                root.refreshHyprlandWorkspaces()
            }
        }

        // ---- MangoWC ----

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
                console.log("MangoWC workspace parse failed:", e)
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

        // =========================
        // MULLVAD VPN
        // =========================

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

        // =========================
        // BAR WINDOW
        // =========================

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 40
        color: root.background

        // =========================
        // WORKSPACE BUTTONS
        // =========================

        Row {
            id: workspaces

            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter

            spacing: 6

            Repeater {
                model: workspaceModel

                Rectangle {
                    id: workspaceButton

                    required property var workspaceId
                    required property bool focused
                    required property bool occupied
                    required property bool urgent

                    property bool hovered: false

                    width: 32
                    height: 28
                    radius: 4

                    color: focused || hovered
                        ? root.highlight
                        : root.background

                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }

                    Text {
                        anchors.centerIn: parent

                        text: workspaceButton.workspaceId

                        color: workspaceButton.urgent
                            ? root.urgent
                            : workspaceButton.occupied
                                ? root.foreground
                                : Qt.darker(root.foreground, 1.6)

                        font.pixelSize: 14
                        font.bold: workspaceButton.focused
                            || workspaceButton.hovered
                    }

                    // Active workspace indicator

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 3

                        width: 12
                        height: 2
                        radius: 1

                        color: root.foreground
                        visible: workspaceButton.focused
                    }

                    MouseArea {
                        anchors.fill: parent

                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onEntered: {
                            workspaceButton.hovered = true
                        }

                        onExited: {
                            workspaceButton.hovered = false
                        }

                        onClicked: {
                            root.switchWorkspace(
                                workspaceButton.workspaceId
                            )
                        }
                    }
                }
            }
        }

        // =========================
        // AUDIO VISUALIZER
        // =========================

        Row {
            id: visualizer

            anchors.right: controlButton.left
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter

            width: 38
            height: 24
            spacing: 2

            property var levels: [
                0, 0, 0, 0,
                0, 0, 0, 0
            ]

            Process {
                id: cava

                command: [
                    "bash",
                    "-c",
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
                                Math.max(
                                    0,
                                    Math.min(1, value / 100)
                                )
                            )
                        }

                        visualizer.levels = newLevels
                    }
                }

                stderr: SplitParser {
                    splitMarker: "\n"

                    onRead: data => {
                        console.log("CAVA:", data)
                    }
                }
            }

            Repeater {
                model: 8

                Rectangle {
                    required property int index

                    width: 3
                    radius: 2

                    anchors.verticalCenter: parent.verticalCenter

                    property real audioLevel:
                        visualizer.levels[index] ?? 0

                    property real targetHeight:
                        audioLevel > 0.01
                            ? 3 + audioLevel * 19
                            : 2

                    height: targetHeight
                    color: root.foreground

                    Behavior on height {
                        NumberAnimation {
                            duration: 45
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }
        }

        // =========================
        // MULLVAD INDICATOR
        // =========================

        Rectangle {
            id: mullvadIndicator

            anchors.right: clockText.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter

            width: 24
            height: 28
            radius: 4

            color: root.background

            Text {
                anchors.centerIn: parent

                text: "󰦝"
                font.pixelSize: 19

                color: !root.mullvadStatusKnown
                    ? "#f9e2af"
                    : root.mullvadConnected
                        ? "#a6e3a1"
                        : "#f38ba8"
            }

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    Quickshell.execDetached([
                        "mullvad",
                        "status"
                    ])
                }
            }
        }

        // =========================
        // CLOCK
        // =========================

        Text {
            id: clockText

            anchors.centerIn: parent

            color: root.foreground
            font.pixelSize: 16
            font.bold: true

            text: Qt.formatTime(new Date(), "HH:mm")

            Timer {
                interval: 1000
                running: true
                repeat: true

                onTriggered: {
                    clockText.text = Qt.formatTime(
                        new Date(),
                        "HH:mm"
                    )
                }
            }
        }

        // =========================
        // CONTROL BUTTON
        // =========================

        Rectangle {
            id: controlButton

            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter

            width: 36
            height: 32
            radius: 6

            property bool panelOpen: false
            property bool hovered: false

            color: panelOpen || hovered
                ? root.highlight
                : root.background

            Behavior on color {
                ColorAnimation {
                    duration: 100
                }
            }

            Text {
                anchors.centerIn: parent

                text: "󰍜"
                color: root.foreground
                font.pixelSize: 20
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

                    console.log(
                        "CONTROL PANEL:",
                        controlButton.panelOpen
                    )
                }
            }
        }

        // =========================
        // CONTROL PANEL
        // =========================

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
