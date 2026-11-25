import QtQuick
import Quickshell
import Quickshell.Networking

Column {
    id: root
    MatugenPalette { id: matugen }

    signal backRequested()

    spacing: 12

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
            text: "Network"
            color: matugen.onSurface
            font.pixelSize: 18
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // =================================
    // Network devices
    // =================================

    Repeater {
        model: Networking.devices

        delegate: DeviceSection {
            width: root.width
            device: modelData
        }
    }

    // =================================
    // Device section
    // =================================

    component DeviceSection: Column {
        id: deviceSection

        property var device

        spacing: 6

        Row {
            width: parent.width
            spacing: 8
            leftPadding: 4

            Rectangle {
                width: 8
                height: 8
                radius: 4
                anchors.verticalCenter: parent.verticalCenter

                color: device && device.connected
                    ? matugen.primary
                    : "transparent"

                border.width: device && device.connected ? 0 : 1.5
                border.color: Qt.darker(Qt.lighter(matugen.outline, 1.6), 1.2)
            }

            Text {
                text: device ? device.name : "Network device"
                color: matugen.onSurface
                font.pixelSize: 13
                font.bold: true
            }

            Text {
                text: device && device.connected ? "Connected" : "Disconnected"
                color: Qt.lighter(matugen.outline, 1.6)
                font.pixelSize: 11
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Wi-Fi networks
        Repeater {
            model: device ? device.networks : []

            delegate: NetworkItem {
                width: deviceSection.width
                network: modelData
            }
        }

        // Disconnect
        Rectangle {
            width: parent.width
            height: 34
            radius: height / 2

            visible: device && device.connected

            color: disconnectMouse.pressed
                ? matugen.primary
                : disconnectMouse.containsMouse
                    ? Qt.alpha(matugen.primary, 0.48)
                    : Qt.alpha(matugen.primary, 0.24)

            Behavior on color {
                ColorAnimation { duration: 120 }
            }

            Text {
                anchors.centerIn: parent
                text: "Disconnect"
                color: disconnectMouse.pressed ? matugen.onPrimary : matugen.onSurface
                font.pixelSize: 12
            }

            MouseArea {
                id: disconnectMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    if (device)
                        device.disconnect()
                }
            }
        }
    }

    // =================================
    // Wi-Fi network item
    // =================================

    component NetworkItem: Rectangle {
        id: networkItem

        property var network

        height: 40
        radius: height / 2

        color: network && network.connected
            ? Qt.alpha(matugen.primary, 0.48)
            : networkMouse.containsMouse
                ? Qt.alpha(matugen.primary, 0.36)
                : Qt.alpha(matugen.primary, 0.18)

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            spacing: 10

            Text {
                text: network && network.connected ? "󰤨" : "󰤯"
                color: matugen.onSurface
                font.pixelSize: 16
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                width: parent.width - 30

                text: network ? network.name : "Unknown"

                color: matugen.onSurface
                font.pixelSize: 12
                elide: Text.ElideRight

                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            id: networkMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                if (!network)
                    return

                if (network.connected)
                    network.disconnect()
                else if (network.known)
                    network.connect()
            }
        }
    }
}
