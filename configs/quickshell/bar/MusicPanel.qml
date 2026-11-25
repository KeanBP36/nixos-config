import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Mpris

Column {
    id: root

    MatugenPalette { id: matugen }

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

    Component.onCompleted: updatePlayer()

    Connections {
        target: Mpris.players

        function onValuesChanged() {
            root.updatePlayer()
        }
    }

    // =================================
    // Header
    // =================================

    Row {
        width: parent.width
        height: 34
        spacing: 10

        RoundButton {
            width: 34
            height: 34
            icon: "󰁍"
            onClicked: root.backRequested()
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Text {
                text: "Music"
                color: matugen.onSurface
                font.pixelSize: 18
                font.bold: true
            }

            Text {
                text: root.player
                    ? (root.player.identity || "Media")
                    : "No player"

                color: Qt.lighter(matugen.outline, 1.6)
                font.pixelSize: 11
            }
        }
    }

    // =================================
    // Artwork
    // =================================

    Rectangle {
        width: 150
        height: 150
        anchors.horizontalCenter: parent.horizontalCenter
        radius: 20
        color: Qt.alpha(matugen.primary, 0.24)
        clip: true

        Image {
            id: artwork
            anchors.fill: parent

            source: root.player ? root.player.trackArtUrl : ""

            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            smooth: true

            visible: status === Image.Ready
        }

        Text {
            anchors.centerIn: parent
            text: "♫"
            color: Qt.alpha(matugen.onSurface, 0.5)
            font.pixelSize: 56
            visible: !artwork.visible
        }
    }

    // =================================
    // Track info
    // =================================

    Column {
        width: parent.width
        spacing: 3

        Text {
            width: parent.width

            text: root.player
                ? (root.player.trackTitle || "Nothing playing")
                : "Nothing playing"

            color: matugen.onSurface
            font.pixelSize: 16
            font.bold: true

            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        Text {
            width: parent.width

            text: root.player
                ? (root.player.trackArtist || "Unknown artist")
                : ""

            color: Qt.lighter(matugen.outline, 1.6)
            font.pixelSize: 12

            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        Text {
            width: parent.width

            visible: text !== ""
            text: root.player ? (root.player.trackAlbum || "") : ""

            color: Qt.alpha(Qt.lighter(matugen.outline, 1.6), 0.8)
            font.pixelSize: 11

            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }

    // =================================
    // Controls
    // =================================

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        RoundButton {
            width: 40
            height: 40
            icon: "󰒮"
            enabled: root.player !== null
            onClicked: {
                if (root.player)
                    root.player.previous()
            }
        }

        RoundButton {
            width: 48
            height: 48
            icon: root.player && root.player.isPlaying ? "󰏤" : "󰐊"
            iconSize: 20
            filled: true
            enabled: root.player !== null
            onClicked: {
                if (root.player)
                    root.player.togglePlaying()
            }
        }

        RoundButton {
            width: 40
            height: 40
            icon: "󰒭"
            enabled: root.player !== null
            onClicked: {
                if (root.player)
                    root.player.next()
            }
        }
    }

    // Round icon button
    component RoundButton: Rectangle {
        id: btn

        property string icon
        property int iconSize: 18
        property bool filled: false

        signal clicked()

        radius: width / 2

        color: filled
            ? (btnMouse.containsMouse ? Qt.lighter(matugen.primary, 1.1) : matugen.primary)
            : btnMouse.pressed
                ? Qt.alpha(matugen.primary, 0.65)
                : btnMouse.containsMouse
                    ? Qt.alpha(matugen.primary, 0.48)
                    : Qt.alpha(matugen.primary, 0.24)

        opacity: enabled ? 1.0 : 0.4

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        Text {
            anchors.centerIn: parent
            text: btn.icon
            color: btn.filled ? matugen.onPrimary : matugen.onSurface
            font.pixelSize: btn.iconSize
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }
}
