import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Column {
    id: root

    signal backRequested()

    spacing: 10

    // =================================
    // PipeWire object tracking
    // =================================

    PwObjectTracker {
        objects: Pipewire.nodes
    }

    // =================================
    // Header
    // =================================

    Row {
        width: parent.width
        height: 32
        spacing: 8

        Rectangle {
            width: 32
            height: 32
            radius: 6

            color: backMouse.containsMouse
                ? "#3a3a3a"
                : "#252525"

            Text {
                anchors.centerIn: parent

                text: "󰁍"
                color: "#ffffff"

                font.pixelSize: 18
            }

            MouseArea {
                id: backMouse

                anchors.fill: parent

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    root.backRequested()
                }
            }
        }

        Text {
            text: "Audio"

            color: "#ffffff"

            font.pixelSize: 20
            font.bold: true

            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Rectangle {
        width: parent.width
        height: 1

        color: Qt.rgba(0.83, 0.83, 0.83, 0.15)
    }

    // =================================
    // Outputs
    // =================================

    Text {
        text: "Outputs"

        color: "#ffffff"

        font.pixelSize: 14
        font.bold: true
    }

    Repeater {
        model: ScriptModel {
            values: Pipewire.nodes.filter(function(node) {
                return node.audio !== null
                    && node.isSink
                    && !node.isStream
                    && node.ready
            })
        }

        delegate: AudioItem {
            width: root.width
            node: modelData
        }
    }

    // =================================
    // Applications
    // =================================

    Text {
        text: "Applications"

        color: "#ffffff"

        font.pixelSize: 14
        font.bold: true

        topPadding: 4
    }

    Repeater {
        model: ScriptModel {
            values: Pipewire.nodes.filter(function(node) {
                return node.audio !== null
                    && node.isStream
                    && !node.isSink
                    && node.ready
            })
        }

        delegate: AudioItem {
            width: root.width
            node: modelData
        }
    }

    // =================================
    // Audio item
    // =================================

    component AudioItem: Column {
        id: item

        property var node

        spacing: 4

        Text {
            width: parent.width

            text: item.node
                ? (
                    item.node.description
                    || item.node.name
                    || "Unknown"
                )
                : "Unknown"

            color: "#d4d4d4"

            font.pixelSize: 12

            elide: Text.ElideRight
        }

        Row {
            width: parent.width

            spacing: 8

            // =========================
            // Mute button
            // =========================

            Rectangle {
                width: 28
                height: 26

                radius: 5

                color: muteMouse.containsMouse
                    ? "#3a3a3a"
                    : "#252525"

                Text {
                    anchors.centerIn: parent

                    text: item.node
                        && item.node.audio
                        && item.node.audio.muted
                        ? "󰝟"
                        : "󰕾"

                    color: "#ffffff"

                    font.pixelSize: 16
                }

                MouseArea {
                    id: muteMouse

                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (item.node && item.node.audio) {
                            item.node.audio.muted =
                                !item.node.audio.muted
                        }
                    }
                }
            }

            // =========================
            // Volume slider
            // =========================

            Rectangle {
                id: slider

                width: parent.width - 36
                height: 26

                radius: 6

                color: "#252525"

                Rectangle {
                    width: {
                        if (!item.node || !item.node.audio)
                            return 0

                        return Math.max(
                            0,
                            Math.min(
                                slider.width,
                                slider.width
                                    * item.node.audio.volume
                            )
                        )
                    }

                    height: parent.height

                    radius: 6

                    color: "#d4d4d4"
                }

                MouseArea {
                    anchors.fill: parent

                    cursorShape: Qt.PointingHandCursor

                    onClicked: function(mouse) {
                        if (!item.node || !item.node.audio)
                            return

                        item.node.audio.volume =
                            Math.max(
                                0,
                                Math.min(
                                    1,
                                    mouse.x / slider.width
                                )
                            )
                    }

                    onPositionChanged: function(mouse) {
                        if (!pressed)
                            return

                        if (!item.node || !item.node.audio)
                            return

                        item.node.audio.volume =
                            Math.max(
                                0,
                                Math.min(
                                    1,
                                    mouse.x / slider.width
                                )
                            )
                    }
                }

                Text {
                    anchors.centerIn: parent

                    text: item.node && item.node.audio
                        ? Math.round(
                            item.node.audio.volume * 100
                          ) + "%"
                        : "0%"

                    color: "#ffffff"

                    font.pixelSize: 11
                }
            }
        }
    }
}

