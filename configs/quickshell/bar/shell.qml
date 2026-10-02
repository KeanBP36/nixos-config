import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Io

PanelWindow {
    id: root

    // =========================
    // Nvim-style Theme
    // =========================

    readonly property color background: "#1f1f1f"
    readonly property color foreground: "#d4d4d4"
    readonly property color highlight: "#3a3a3a"

    // =========================
    // Bar
    // =========================

    screen: Quickshell.screens[1]

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
            model: ScriptModel {
                values: Hyprland.workspaces.values.filter(
                    ws => !ws.name.startsWith("special:")
                )
            }

            Rectangle {
                required property var modelData

                width: 32
                height: 28
                radius: 4

                color: modelData.focused
                    ? root.highlight
                    : root.background

                Text {
                    anchors.centerIn: parent

                    text: modelData.name

                    color: root.foreground

                    font.pixelSize: 14
                    font.bold: modelData.focused
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        modelData.activate()
                    }
                }
            }
        }

        // =========================
        // Special Workspace
        // =========================

        Rectangle {
            width: 32
            height: 28
            radius: 4

            color: root.background

            Text {
                anchors.centerIn: parent

                text: "✦"

                color: root.foreground

                font.pixelSize: 16
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent

                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    console.log("SCRATCHPAD CLICKED")

                    Quickshell.execDetached([
                        "hyprctl",
                        "dispatch",
                        'hl.dsp.workspace.toggle_special("magic")'
                    ])
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

        // =========================
        // CAVA FFT PROCESS
        // =========================

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

        // =========================
        // RESTART CAVA IF IT DIES
        // =========================

        onVisibleChanged: {
            if (visible && !cava.running)
                cava.running = true
        }

        // =========================
        // FFT BARS
        // =========================

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
    // CLOCK
    // =========================

    Text {
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
                parent.text =
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
