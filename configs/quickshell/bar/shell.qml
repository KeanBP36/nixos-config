import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris

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
            model: Hyprland.workspaces

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
    }

    // =========================
    // Music
    // =========================

    Row {
        id: music

        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter

        spacing: 8

        property var player: Mpris.players.values.length > 0
            ? Mpris.players.values[0]
            : null

        // =========================
        // Visualizer
        // =========================

        Row {
            id: visualizer

            width: 38
            height: 24
            spacing: 2

            anchors.verticalCenter: parent.verticalCenter

            Repeater {
                model: 8

                Rectangle {
                    property real barHeight: music.player &&
                                              music.player.isPlaying
                                              ? 4 + Math.random() * 16
                                              : 2

                    width: 3
                    height: barHeight

                    anchors.verticalCenter: parent.verticalCenter

                    radius: 2
                    color: root.foreground

                    Behavior on barHeight {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutQuad
                        }
                    }

                    Timer {
                        interval: 180

                        running: music.player !== null &&
                                 music.player.isPlaying

                        repeat: true

                        onTriggered: {
                            barHeight = 4 + Math.random() * 16
                        }
                    }

                    Connections {
                        target: music.player

                        function onIsPlayingChanged() {
                            if (music.player &&
                                music.player.isPlaying) {
                                barHeight = 4 + Math.random() * 16
                            } else {
                                barHeight = 2
                            }
                        }
                    }
                }
            }
        }

        // =========================
        // Previous
        // =========================

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: "󰒮"
            color: root.foreground
            font.pixelSize: 17

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if (music.player &&
                        music.player.canGoPrevious) {
                        music.player.previous()
                    }
                }
            }
        }

        // =========================
        // Play / Pause
        // =========================

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: music.player
                ? (music.player.isPlaying ? "󰏤" : "󰐊")
                : "󰐊"

            color: root.foreground
            font.pixelSize: 18
            font.bold: true

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if (music.player &&
                        music.player.canTogglePlaying) {
                        music.player.togglePlaying()
                    }
                }
            }
        }

        // =========================
        // Next
        // =========================

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: "󰒭"
            color: root.foreground
            font.pixelSize: 17

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if (music.player &&
                        music.player.canGoNext) {
                        music.player.next()
                    }
                }
            }
        }

        // =========================
        // Track
        // =========================

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: music.player
                ? music.player.trackTitle +
                  " — " +
                  music.player.trackArtist
                : "No music"

            color: root.foreground
            font.pixelSize: 14

            elide: Text.ElideRight
            maximumLineCount: 1
            width: 220
        }
    }

    // =========================
    // Clock
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
                parent.text = Qt.formatTime(new Date(), "HH:mm")
            }
        }
    }
}
