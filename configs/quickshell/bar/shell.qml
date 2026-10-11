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
        // Nvim-style Theme
        // =========================

        readonly property color background: "#1f1f1f"
        readonly property color foreground: "#d4d4d4"
        readonly property color highlight: "#3a3a3a"
        readonly property color urgent: "#f38ba8"

        // =========================
        // Compositor Detection
        // =========================

        property string compositor: ""

        function activateCompositor(name) {
            root.compositor = name
            console.log("WORKSPACES:", root.screen.name, "using compositor =", name)

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

            command: ["sh", "-c", "printf '%s' \"$HYPRLAND_INSTANCE_SIGNATURE\""]
            running: true

            stdout: StdioCollector {
                onStreamFinished: {
                    root.activateCompositor(this.text.trim().length > 0 ? "hyprland" : "mango")
                }
            }
        }

        // =========================
        // Workspaces (unified model)
        // =========================

        // Entries: { workspaceId, focused, occupied, urgent }
        ListModel {
            id: workspaceModel
        }

        function switchWorkspace(id) {
            if (root.compositor === "hyprland") {
                Hyprland.dispatch("workspace " + id)
            } else {
                // Verify this dispatch name/args against `mmsg dispatch` docs.
                Quickshell.execDetached(["mmsg", "dispatch", "view," + id])
            }
        }

        // ---- Hyprland backend ----

        function refreshHyprlandWorkspaces() {
            if (root.compositor !== "hyprland")
                return

            workspaceModel.clear()

            var list = Hyprland.workspaces.values.filter(
                ws => !ws.name.startsWith("special:")
            )

            for (var i = 0; i < list.length; ++i) {
                var ws = list[i]
                workspaceModel.append({
                    workspaceId: ws.name,
                    focused: !!ws.focused,
                    occupied: true,
                    urgent: false
                })
            }
        }

        Connections {
            target: Hyprland.workspaces
            enabled: root.compositor === "hyprland"

            function onValuesChanged() {
                root.refreshHyprlandWorkspaces()
            }
        }

        // ---- MangoWC backend (via mmsg) ----

        // Placeholder tags 1-9 so the strip is visible before the first real update.
        function seedMangoPlaceholders() {
            workspaceModel.clear()
            for (var k = 1; k <= 9; ++k) {
                workspaceModel.append({
                    workspaceId: k,
                    focused: false,
                    occupied: false,
                    urgent: false
                })
            }
        }

        // Parses JSON from `mmsg get all-tags` or one line of `mmsg watch all-tags`.
        //
        // NOTE: the keys (name/output, tags, id/index, active, occupied, urgent)
        // are assumptions about mmsg's JSON. Compare against `mmsg get all-tags`
        // output (logged below) and adjust if they differ.
        function handleMangoUpdate(text) {
            console.log("MMSG RAW:", root.screen.name, text)

            var parsed
            try {
                parsed = JSON.parse(text)
            } catch (e) {
                console.log("MMSG PARSE FAILED:", e)
                return
            }

            var monitors = Array.isArray(parsed) ? parsed : [parsed]
            var mine = null

            for (var i = 0; i < monitors.length; ++i) {
                var m = monitors[i]
                if ((m.name ?? m.output) === root.screen.name) {
                    mine = m
                    break
                }
            }

            if (!mine) {
                console.log("MMSG: no monitor matched", root.screen.name)
                return
            }

            if (!Array.isArray(mine.tags)) {
                console.log("MMSG: monitor has no tags array")
                return
            }

            workspaceModel.clear()

            for (var j = 0; j < mine.tags.length; ++j) {
                var t = mine.tags[j]
                workspaceModel.append({
                    workspaceId: t.id ?? t.index ?? (j + 1),
                    focused: !!t.active,
                    occupied: !!t.occupied,
                    urgent: !!t.urgent
                })
            }
        }

        Process {
            id: mangoInit

            command: ["mmsg", "get", "all-tags"]
            running: false

            stdout: StdioCollector {
                onStreamFinished: root.handleMangoUpdate(this.text)
            }
        }

        Process {
            id: mangoWatcher

            command: ["mmsg", "watch", "all-tags"]
            running: false

            stdout: SplitParser {
                splitMarker: "\n"

                onRead: data => root.handleMangoUpdate(data)
            }

            onExited: (exitCode, exitStatus) => mangoRestartTimer.start()
        }

        Timer {
            id: mangoRestartTimer

            interval: 2000
            repeat: false

            onTriggered: mangoWatcher.running = true
        }

        // =========================
        // Mullvad VPN State
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
        // Bar
        // =========================

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 40
        color: root.background

        // =========================
        // Workspaces
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

                    width: 32
                    height: 28
                    radius: 4

                    color: focused
                        ? root.highlight
                        : root.background

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
                    }

                    // Active indicator: small bar along the bottom edge
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
                        cursorShape: Qt.PointingHandCursor

                        onClicked: root.switchWorkspace(workspaceButton.workspaceId)
                    }
                }
            }
        }

        // =========================
        // REAL AUDIO VISUALIZER
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

            onVisibleChanged: {
                if (visible && !cava.running)
                    cava.running = true
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
        // MULLVAD STATUS INDICATOR
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
                    clockText.text =
                        Qt.formatTime(new Date(), "HH:mm")
                }
            }
        }

        // =========================
        // CONTROL PANEL BUTTON
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

            color: panelOpen
                ? root.highlight
                : root.background

            Text {
                anchors.centerIn: parent

                text: "󰍜"
                color: root.foreground

                font.pixelSize: 20
            }

            MouseArea {
                anchors.fill: parent

                cursorShape: Qt.PointingHandCursor

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
