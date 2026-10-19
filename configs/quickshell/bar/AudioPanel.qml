import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Mpris

Column {
    id: root

    signal backRequested()

    spacing: 12

    property var players: Mpris.players.values
    property var player: null

    readonly property color bg: "#151B16"
    readonly property color panel: "#202921"
    readonly property color hover: "#303D2F"
    readonly property color green: "#9BAF75"
    readonly property color fg: "#D5DEC8"
    readonly property color muted: "#849078"
    readonly property color borderColor: "#46563C"
    readonly property color amber: "#E9AD4C"

    function updatePlayer() {
        root.players = Mpris.players.values

        for (let i = 0; i < root.players.length; i++) {
            if (root.players[i].isPlaying) {
                root.player = root.players[i]
                return
            }
        }

        if (root.player && root.players.indexOf(root.player) !== -1)
            return

        root.player = root.players.length > 0 ? root.players[0] : null
    }

    function playPause() {
        if (root.player)
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

    function volumeUp() {
        Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+"])
    }

    function volumeDown() {
        Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"])
    }

    function toggleMute() {
        Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
    }

    Component.onCompleted: updatePlayer()

    Connections {
        target: Mpris.players
        function onValuesChanged() {
            root.updatePlayer()
        }
    }

    // UNSC header
    Row {
        width: parent.width
        height: 38
        spacing: 10

        Rectangle {
            width: 36
            height: 36
            radius: 2
            color: "#303D2F"
            border.width: 1
            border.color: root.green

            Text {
                anchors.centerIn: parent
                text: "U"
                color: root.green
                font.pixelSize: 22
                font.bold: true
                font.family: "monospace"
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                text: "UNSC // AUDIO"
                color: root.fg
                font.pixelSize: 15
                font.bold: true
                font.family: "monospace"
            }

            Text {
                text: root.player
                    ? (root.player.identity || "MEDIA SYSTEM")
                    : "NO MEDIA SOURCE"
                color: root.muted
                font.pixelSize: 9
                font.family: "monospace"
                elide: Text.ElideRight
            }
        }

        Item {
            width: Math.max(0, parent.width - 220)
            height: 1
        }

        Rectangle {
            width: 34
            height: 34
            radius: 2
            color: backMouse.containsMouse ? root.hover : root.panel
            border.width: 1
            border.color: root.borderColor

            Text {
                anchors.centerIn: parent
                text: "‹"
                color: root.green
                font.pixelSize: 25
            }

            MouseArea {
                id: backMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.backRequested()
            }
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        color: root.borderColor
    }

    // Album artwork / fallback
    Rectangle {
        width: 208
        height: 208
        anchors.horizontalCenter: parent.horizontalCenter
        radius: 2
        color: root.panel
        border.width: 1
        border.color: root.borderColor
        clip: true

        Image {
            id: artwork
            anchors.fill: parent
            anchors.margins: 3

            source: root.player ? root.player.trackArtUrl : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            smooth: true
            visible: status === Image.Ready
        }

        Column {
            anchors.centerIn: parent
            spacing: 8
            visible: !artwork.visible

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "♫"
                color: root.green
                font.pixelSize: 54
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "NO SIGNAL"
                color: root.muted
                font.pixelSize: 10
                font.family: "monospace"
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            width: 4
            height: 28
            color: root.green
        }

        Rectangle {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            width: 4
            height: 28
            color: root.green
        }
    }

    // Track metadata
    Column {
        width: parent.width
        spacing: 4

        Text {
            width: parent.width
            text: root.player
                ? (root.player.trackTitle || "NOTHING PLAYING")
                : "NOTHING PLAYING"
            color: root.fg
            font.pixelSize: 15
            font.bold: true
            font.family: "monospace"
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            text: root.player
                ? (root.player.trackArtist || "UNKNOWN ARTIST")
                : "AWAITING MEDIA SOURCE"
            color: root.green
            font.pixelSize: 12
            font.family: "monospace"
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            text: root.player ? (root.player.trackAlbum || "") : ""
            color: root.muted
            font.pixelSize: 10
            font.family: "monospace"
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        color: root.borderColor
    }

    Text {
        text: "PLAYBACK CONTROLS"
        color: root.amber
        font.pixelSize: 9
        font.bold: true
        font.family: "monospace"
    }

    // Playback controls
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 8

        MediaButton {
            width: 46
            height: 42
            icon: "⏮"
            enabled: root.player !== null && root.player.canGoPrevious
            onClicked: root.previous()
        }

        MediaButton {
            width: 54
            height: 46
            icon: root.player && root.player.isPlaying ? "󰏤" : "󰐊"
            accent: true
            enabled: root.player !== null
            onClicked: root.playPause()
        }

        MediaButton {
            width: 46
            height: 42
            icon: "⏭"
            enabled: root.player !== null && root.player.canGoNext
            onClicked: root.next()
        }
    }

    Text {
        width: parent.width
        text: root.player
            ? (root.player.isPlaying ? "▶  TRANSMISSION ACTIVE" : "Ⅱ  PLAYBACK STANDBY")
            : "●  NO ACTIVE TRANSMISSION"
        color: root.player && root.player.isPlaying ? root.green : root.muted
        font.pixelSize: 9
        font.family: "monospace"
        horizontalAlignment: Text.AlignHCenter
    }

    Rectangle {
        width: parent.width
        height: 1
        color: root.borderColor
    }

    Text {
        text: "SYSTEM VOLUME // PIPEWIRE"
        color: root.amber
        font.pixelSize: 9
        font.bold: true
        font.family: "monospace"
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 8

        MediaButton {
            width: 48
            height: 38
            icon: "󰕿"
            onClicked: root.volumeDown()
        }

        MediaButton {
            width: 48
            height: 38
            icon: "󰖁"
            onClicked: root.toggleMute()
        }

        MediaButton {
            width: 48
            height: 38
            icon: "󰕾"
            onClicked: root.volumeUp()
        }
    }

    component MediaButton: Rectangle {
        id: button

        property string icon
        property bool accent: false
        property bool enabled: true

        signal clicked()

        radius: 2
        color: !enabled
            ? "#1A201B"
            : mouse.containsMouse
                ? root.hover
                : (accent ? "#303D2F" : root.panel)

        border.width: 1
        border.color: accent ? root.green : root.borderColor
        opacity: enabled ? 1.0 : 0.4

        Text {
            anchors.centerIn: parent
            text: button.icon
            color: button.accent ? root.green : root.fg
            font.pixelSize: 19
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            enabled: button.enabled
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: button.clicked()
        }
    }
}
