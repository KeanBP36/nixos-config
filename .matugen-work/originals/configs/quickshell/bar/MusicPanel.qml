import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Mpris

Column {
    id: root

    signal backRequested()

    spacing: 14

    property var players: Mpris.players.values
    property var player: players.length > 0 ? players[0] : null

    function updatePlayer() {
        root.players = Mpris.players.values
        root.player = root.players.length > 0
            ? root.players[0]
            : null
    }

    function playPause() {
        if (!root.player)
            return

        root.player.togglePlaying()
    }

    function previous() {
        if (root.player && root.player.canGoPrevious)
            root.player.previous()
    }

    function next() {
        if (root.player && root.player.canGoNext)
            root.player.next()
    }

    Component.onCompleted: updatePlayer()

    Connections {
        target: Mpris.players

        function onValuesChanged() {
            root.updatePlayer()
        }
    }

    // Header
    Row {
        width: parent.width
        height: 38
        spacing: 10

        Rectangle {
            width: 38
            height: 38
            radius: 10
            color: backMouse.containsMouse
                ? "#3a3a3a"
                : "#292929"

            Text {
                anchors.centerIn: parent
                text: "‹"
                color: "#d4d4d4"
                font.pixelSize: 27
            }

            MouseArea {
                id: backMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: root.backRequested()
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Text {
                text: "Music"
                color: "#d4d4d4"
                font.pixelSize: 19
                font.bold: true
            }

            Text {
                text: root.player
                    ? (root.player.identity || "Media")
                    : "No player"

                color: "#666666"
                font.pixelSize: 11
            }
        }
    }

    // Album artwork
    Rectangle {
        width: 150
        height: 150
        anchors.horizontalCenter: parent.horizontalCenter
        radius: 18
        color: "#292929"
        clip: true

        Image {
            id: artwork
            anchors.fill: parent

            source: root.player
                ? root.player.trackArtUrl
                : ""

            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            smooth: true

            visible: status === Image.Ready
        }

        Text {
            anchors.centerIn: parent

            text: "♫"
            color: "#555555"
            font.pixelSize: 64

            visible: !artwork.visible
        }
    }

    // Track information
    Column {
        width: parent.width
        spacing: 3

        Text {
            width: parent.width

            text: root.player
                ? (root.player.trackTitle || "Nothing playing")
                : "Nothing playing"

            color: "#d4d4d4"
            font.pixelSize: 17
            font.bold: true

            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        Text {
            width: parent.width

            text: root.player
                ? (root.player.trackArtist || "Unknown artist")
                : ""

            color: "#999999"
            font.pixelSize: 13

            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        Text {
            width: parent.width

            text: root.player
                ? (root.player.trackAlbum || "")
                : ""

            color: "#666666"
            font.pixelSize: 11

            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }

    // Media controls
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 8

        // Previous
        Rectangle {
            width: 46
            height: 46
            radius: 8

            color: previousMouse.containsMouse
                ? "#3a3a3a"
                : "#292929"

            border.width: 1
            border.color: "#444444"

            Text {
                anchors.centerIn: parent
                text: "󰒮"
                color: "#d4d4d4"
                font.pixelSize: 19
            }

            MouseArea {
                id: previousMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    if (root.player)
                        root.player.previous()
                }
            }
        }

        // Play / Pause
        Rectangle {
            width: 46
            height: 46
            radius: 8

            color: playMouse.containsMouse
                ? "#3a3a3a"
                : "#292929"

            border.width: 1
            border.color: "#444444"

            Text {
                anchors.centerIn: parent

                text: root.player && root.player.isPlaying
                    ? "󰏤"
                    : "󰐊"

                color: "#d4d4d4"
                font.pixelSize: 20
            }

            MouseArea {
                id: playMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    if (root.player)
                        root.player.togglePlaying()
                }
            }
        }

        // Next
        Rectangle {
            width: 46
            height: 46
            radius: 8

            color: nextMouse.containsMouse
                ? "#3a3a3a"
                : "#292929"

            border.width: 1
            border.color: "#444444"

            Text {
                anchors.centerIn: parent
                text: "󰒭"
                color: "#d4d4d4"
                font.pixelSize: 19
            }

            MouseArea {
                id: nextMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    if (root.player)
                        root.player.next()
                }
            }
        }
    }

    // Status
    Text {
        width: parent.width

        text: root.player
            ? (root.player.isPlaying ? "Playing" : "Paused")
            : "Nothing playing"

        color: "#666666"
        font.pixelSize: 11

        horizontalAlignment: Text.AlignHCenter
   }
}
