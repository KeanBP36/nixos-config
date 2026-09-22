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
        players = Mpris.players.values
        player = players.length > 0 ? players[0] : null
    }

    function playPause() {
        if (!player)
            return

        if (player.isPlaying)
            player.pause()
        else
            player.play()
    }

    function previous() {
        if (player)
            player.previous()
    }

    function next() {
        if (player)
            player.next()
    }

    function rewind() {
        if (player && player.canSeek)
            player.seek(-10)
    }

    function forward() {
        if (player && player.canSeek)
            player.seek(10)
    }

    Component.onCompleted: updatePlayer()

    Connections {
        target: Mpris.players

        function onValuesChanged() {
            root.updatePlayer()
        }
    }

    // ─────────────────────────────
    // Header
    // ─────────────────────────────

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

    // ─────────────────────────────
    // Album artwork
    // ─────────────────────────────

    Rectangle {
        width: 230
        height: 230

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

    // ─────────────────────────────
    // Track information
    // ─────────────────────────────

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

    // ─────────────────────────────
    // Playback controls
    // ─────────────────────────────

    Row {
        anchors.horizontalCenter: parent.horizontalCenter

        spacing: 7

        // ─────────────
        // Rewind
        // ─────────────

        Rectangle {
            width: 42
            height: 42
            radius: 11

            color: rewindMouse.containsMouse
                ? "#3a3a3a"
                : "#292929"

            opacity: root.player ? 1.0 : 0.45

            Text {
                anchors.centerIn: parent

                text: "↶"

                color: "#d4d4d4"

                font.pixelSize: 21
            }

            MouseArea {
                id: rewindMouse

                anchors.fill: parent

                hoverEnabled: true

                enabled: root.player !== null

                cursorShape: Qt.PointingHandCursor

                onClicked: root.rewind()
            }
        }

        // ─────────────
        // Previous
        // ─────────────

        Rectangle {
            width: 42
            height: 42
            radius: 11

            color: previousMouse.containsMouse
                ? "#3a3a3a"
                : "#292929"

            opacity: root.player ? 1.0 : 0.45

            Text {
                anchors.centerIn: parent

                text: "⏮"

                color: "#d4d4d4"

                font.pixelSize: 17
            }

            MouseArea {
                id: previousMouse

                anchors.fill: parent

                hoverEnabled: true

                enabled: root.player !== null

                cursorShape: Qt.PointingHandCursor

                onClicked: root.previous()
            }
        }

        // ─────────────
        // Play / Pause
        // ─────────────

        Rectangle {
            width: 54
            height: 54

            radius: 27

            anchors.verticalCenter: parent.verticalCenter

            color: playMouse.containsMouse
                ? "#6aa9df"
                : "#569cd6"

            opacity: root.player ? 1.0 : 0.45

            Text {
                anchors.centerIn: parent

                text: root.player && root.player.isPlaying
                    ? "Ⅱ"
                    : "▶"

                color: "#ffffff"

                font.pixelSize: 18
                font.bold: true
            }

            MouseArea {
                id: playMouse

                anchors.fill: parent

                hoverEnabled: true

                enabled: root.player !== null

                cursorShape: Qt.PointingHandCursor

                onClicked: root.playPause()
            }
        }

        // ─────────────
        // Next
        // ─────────────

        Rectangle {
            width: 42
            height: 42
            radius: 11

            color: nextMouse.containsMouse
                ? "#3a3a3a"
                : "#292929"

            opacity: root.player ? 1.0 : 0.45

            Text {
                anchors.centerIn: parent

                text: "⏭"

                color: "#d4d4d4"

                font.pixelSize: 17
            }

            MouseArea {
                id: nextMouse

                anchors.fill: parent

                hoverEnabled: true

                enabled: root.player !== null

                cursorShape: Qt.PointingHandCursor

                onClicked: root.next()
            }
        }

        // ─────────────
        // Forward
        // ─────────────

        Rectangle {
            width: 42
            height: 42
            radius: 11

            color: forwardMouse.containsMouse
                ? "#3a3a3a"
                : "#292929"

            opacity: root.player ? 1.0 : 0.45

            Text {
                anchors.centerIn: parent

                text: "↷"

                color: "#d4d4d4"

                font.pixelSize: 21
            }

            MouseArea {
                id: forwardMouse

                anchors.fill: parent

                hoverEnabled: true

                enabled: root.player !== null

                cursorShape: Qt.PointingHandCursor

                onClicked: root.forward()
            }
        }
    }

    // ─────────────────────────────
    // Status
    // ─────────────────────────────

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
