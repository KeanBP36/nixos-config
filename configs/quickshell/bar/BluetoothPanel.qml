import QtQuick
import Quickshell
import Quickshell.Bluetooth

Column {
    id: root
    MatugenPalette { id: matugen }

    signal backRequested()

    spacing: 12

    property var adapter: Bluetooth.defaultAdapter

    // =================================
    // Header
    // =================================

    Row {
        width: parent.width
        height: 34
        spacing: 10

        Rectangle {
            width: 34
            height: 34
            radius: width / 2

            color: backMouse.pressed
                ? Qt.alpha(matugen.primary, 0.65)
                : backMouse.containsMouse
                    ? Qt.alpha(matugen.primary, 0.48)
                    : Qt.alpha(matugen.primary, 0.24)

            Behavior on color {
                ColorAnimation { duration: 120 }
            }

            Text {
                anchors.centerIn: parent
                text: "󰁍"
                color: matugen.onSurface
                font.pixelSize: 18
            }

            MouseArea {
                id: backMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.backRequested()
            }
        }

        Text {
            text: "Bluetooth"
            color: matugen.onSurface
            font.pixelSize: 18
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // =================================
    // Power switch
    // =================================

    Rectangle {
        width: parent.width
        height: 46
        radius: height / 2
        color: Qt.alpha(matugen.primary, 0.24)

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 18
            anchors.verticalCenter: parent.verticalCenter

            text: root.adapter
                ? (root.adapter.enabled ? "Bluetooth on" : "Bluetooth off")
                : "No Bluetooth adapter"

            color: matugen.onSurface
            font.pixelSize: 13
        }

        // Switch
        Rectangle {
            id: track

            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter

            width: 44
            height: 24
            radius: height / 2

            readonly property bool on: root.adapter && root.adapter.enabled

            color: on ? matugen.primary : Qt.alpha(matugen.onSurface, 0.30)

            Behavior on color {
                ColorAnimation { duration: 120 }
            }

            Rectangle {
                width: 16
                height: 16
                radius: 8
                anchors.verticalCenter: parent.verticalCenter

                x: track.on ? parent.width - width - 4 : 4

                color: track.on ? matugen.onPrimary : Qt.lighter(matugen.outline, 1.6)

                Behavior on x {
                    NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                if (root.adapter)
                    root.adapter.enabled = !root.adapter.enabled
            }
        }
    }

    // =================================
    // Devices
    // =================================

    Text {
        text: "Devices"
        color: Qt.lighter(matugen.outline, 1.6)
        font.pixelSize: 12
        font.bold: true
        leftPadding: 4
    }

    Repeater {
        model: root.adapter
            ? root.adapter.devices
            : []

        delegate: BluetoothItem {
            width: root.width
            device: modelData
        }
    }

    Text {
        visible: root.adapter
            && root.adapter.devices.length === 0

        text: root.adapter && root.adapter.enabled
            ? "No paired devices"
            : "Bluetooth is off"

        color: Qt.lighter(matugen.outline, 1.6)
        font.pixelSize: 12
        leftPadding: 4
    }

    // =================================
    // Bluetooth device
    // =================================

    component BluetoothItem: Rectangle {
        id: deviceItem

        property var device

        readonly property bool connected: device && device.connected

        height: 48
        radius: 14

        color: connected
            ? Qt.alpha(matugen.primary, 0.48)
            : deviceMouse.containsMouse
                ? Qt.alpha(matugen.primary, 0.36)
                : Qt.alpha(matugen.primary, 0.18)

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        MouseArea {
            id: deviceMouse
            anchors.fill: parent
            hoverEnabled: true
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 10

            spacing: 10

            Text {
                text: "󰂯"
                color: matugen.onSurface
                font.pixelSize: 18
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                width: parent.width - 110
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text {
                    width: parent.width

                    text: device ? device.name : "Unknown device"

                    color: matugen.onSurface
                    font.pixelSize: 12
                    elide: Text.ElideRight
                }

                Text {
                    text: device && device.connected
                        ? "Connected"
                        : device && device.paired
                            ? "Paired"
                            : "Not paired"

                    color: device && device.connected
                        ? matugen.onSurface
                        : Qt.lighter(matugen.outline, 1.6)

                    font.pixelSize: 10
                }
            }

            Rectangle {
                width: 72
                height: 28
                radius: height / 2
                anchors.verticalCenter: parent.verticalCenter

                color: actionMouse.pressed
                    ? matugen.primary
                    : actionMouse.containsMouse
                        ? Qt.alpha(matugen.primary, 0.65)
                        : Qt.alpha(matugen.primary, 0.30)

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                Text {
                    anchors.centerIn: parent

                    text: device && device.connected
                        ? "Disconnect"
                        : device && device.paired
                            ? "Connect"
                            : "Pair"

                    color: actionMouse.pressed ? matugen.onPrimary : matugen.onSurface
                    font.pixelSize: 10
                }

                MouseArea {
                    id: actionMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (!device)
                            return

                        if (device.connected)
                            device.disconnect()
                        else if (device.paired)
                            device.connect()
                        else
                            device.pair()
                    }
                }
            }
        }
    }
}
