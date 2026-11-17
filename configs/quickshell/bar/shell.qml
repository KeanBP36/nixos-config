import QtQuick
import Quickshell
import Quickshell.Hyprland
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

        FileView {
            id: paletteFile
            path: "/home/keanbp/.config/quickshell/generated/colors.json"
            blockLoading: true
            watchChanges: true
            onFileChanged: reload()
        }

        readonly property var matugenColors: {
            try {
                const data = paletteFile.text()
                return data.length > 0 ? JSON.parse(data) : ({})
            } catch (error) {
                console.warn("Could not load Matugen palette:", error)
                return ({})
            }
        }

        readonly property color background:
            matugenColors.surface || matugenColors.background || "#110d11"
        readonly property color barBackground: Qt.alpha(background, 0.85)
        readonly property color foreground:
            matugenColors.foreground || "#4c444c"
        readonly property color highlight:
            matugenColors.primary || "#1f1a1f"
        readonly property color urgent:
            matugenColors.error || "#f28c9a"

        // =========================
        // BAR WINDOW
        // =========================

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 48
        // Space reserved for windows. Lower = windows sit closer to the pill.
        exclusiveZone: implicitHeight - 4
        color: "transparent"

        // =========================
        // COMPOSITOR DETECTION
        // =========================

        property string compositor: ""

        function activateCompositor(name) {
            root.compositor = name

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

            command: ["sh", "-c", "printf '%s' \"$HYPRLAND_INSTANCE_SIGNATURE\""]
            running: true

            stdout: StdioCollector {
                onStreamFinished: {
                    root.activateCompositor(
                        this.text.trim().length > 0 ? "hyprland" : "mango"
                    )
                }
            }
        }

        // =========================
        // WORKSPACES (MODEL)
        // =========================

        ListModel {
            id: workspaceModel
        }

        function switchWorkspace(id) {
            if (root.compositor === "hyprland") {
                Hyprland.dispatch("workspace " + id)
            } else if (root.compositor === "mango") {
                Quickshell.execDetached(["mmsg", "dispatch", "view," + id])
            }
        }

        // ---- Hyprland ----

        ScriptModel {
            id: hyprWorkspaceModel

            values: {
                if (root.compositor !== "hyprland")
                    return []

                var mon = Hyprland.monitorFor(root.screen)
                var all = Hyprland.workspaces.values
                var result = []

                for (var i = 0; i < all.length; ++i) {
                    var ws = all[i]

                    if (ws.id <= 0)
                        continue

                    var sameMonitor = ws.monitor
                        && (ws.monitor === mon
                            || ws.monitor.name === root.screen.name)

                    if (sameMonitor)
                        result.push(ws)
                }

                result.sort((a, b) => a.id - b.id)
                return result
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
                if (root.compositor === "mango" && !mangoWatcher.running)
                    mangoWatcher.running = true
            }
        }

        // =========================
        // FLOATING PILL
        // =========================

        Rectangle {
            id: pill

            anchors.fill: parent
            anchors.topMargin: 8
            anchors.bottomMargin: 0
            anchors.leftMargin: 8 
            anchors.rightMargin: 8 

            radius: height / 2
            color: root.barBackground

            border.width: 1
            border.color: Qt.alpha(root.foreground, 0.12)

            // =========================
            // WORKSPACE DOTS (MANGO)
            // =========================

            Row {
                id: workspaces

                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter

                spacing: 9
                visible: root.compositor !== "hyprland"

                Repeater {
                    model: workspaceModel

                    Rectangle {
                        id: dot

                        required property var workspaceId
                        required property bool focused
                        required property bool occupied
                        required property bool urgent

                        property bool hovered: false

                        width: 12
                        height: 12
                        radius: width / 2

                        color: dot.urgent
                            ? root.urgent
                            : dot.focused
                                ? root.highlight
                                : dot.occupied
                                    ? Qt.alpha(root.highlight, 0.45)
                                    : "transparent"

                        border.width: dot.focused || dot.occupied || dot.urgent ? 0 : 1.5
                        border.color: dot.hovered
                            ? root.foreground
                            : Qt.darker(root.foreground, 1.2)

                        scale: dot.hovered ? 1.15 : 1.0

                        Behavior on color { ColorAnimation { duration: 120 } }
                        Behavior on border.color { ColorAnimation { duration: 120 } }
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onEntered: dot.hovered = true
                            onExited: dot.hovered = false
                            onClicked: root.switchWorkspace(dot.workspaceId)
                        }
                    }
                }
            }

            // =========================
            // WORKSPACE DOTS (HYPRLAND)
            // =========================

            Row {
                id: hyprWorkspaces

                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter

                spacing: 9
                visible: root.compositor === "hyprland"

                Repeater {
                    model: hyprWorkspaceModel

                    Rectangle {
                        id: hdot

                        required property var modelData

                        property bool hovered: false

                        readonly property bool active:
                            modelData.monitor
                            && modelData.monitor.activeWorkspace === modelData

                        width: 12
                        height: 12
                        radius: width / 2

                        color: modelData.urgent
                            ? root.urgent
                            : hdot.active
                                ? root.highlight
                                : Qt.alpha(root.highlight, 0.45)

                        border.width: 0
                        scale: hdot.hovered ? 1.15 : 1.0

                        Behavior on color { ColorAnimation { duration: 120 } }
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onEntered: hdot.hovered = true
                            onExited: hdot.hovered = false
                            onClicked: hdot.modelData.activate()
                        }
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
                font.pixelSize: 15
                font.bold: true

                text: Qt.formatTime(new Date(), "HH:mm")

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: clockText.text = Qt.formatTime(new Date(), "HH:mm")
                }
            }

            // =========================
            // CONTROL BUTTON
            // =========================

            Rectangle {
                id: controlButton

                anchors.right: parent.right
                anchors.rightMargin: 18
                anchors.verticalCenter: parent.verticalCenter

                width: 28
                height: 28
                radius: width / 2

                property bool panelOpen: false
                property bool hovered: false

                color: panelOpen
                    ? root.highlight
                    : hovered
                        ? Qt.alpha(root.highlight, 0.45)
                        : "transparent"

                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: "󰍜"
                    color: root.foreground
                    font.pixelSize: 18
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onEntered: controlButton.hovered = true
                    onExited: controlButton.hovered = false
                    onClicked: controlButton.panelOpen = !controlButton.panelOpen
                }
            }

            // =========================
            // AUDIO VISUALIZER
            // =========================

            Row {
                id: visualizer

                anchors.right: controlButton.left
                anchors.rightMargin: 18
                anchors.verticalCenter: parent.verticalCenter

                width: 38
                height: 24
                spacing: 2

                property var levels: [0, 0, 0, 0, 0, 0, 0, 0]

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

                                newLevels.push(Math.max(0, Math.min(1, value / 100)))
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

                    Rectangle {
                        required property int index

                        width: 3
                        radius: 1.5
                        anchors.verticalCenter: parent.verticalCenter

                        property real audioLevel: visualizer.levels[index] ?? 0

                        height: audioLevel > 0.01 ? 3 + audioLevel * 19 : 3

                        color: root.foreground
                        opacity: audioLevel > 0.01 ? 1.0 : 0.4

                        Behavior on height {
                            NumberAnimation {
                                duration: 45
                                easing.type: Easing.OutQuad
                            }
                        }

                        Behavior on opacity { NumberAnimation { duration: 120 } }
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
}
