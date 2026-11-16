import QtQuick
import Quickshell
import Quickshell.Networking

Column {
    id: root

    signal backRequested()

    spacing: 10

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
                ? "#1f1a1f"
                : "#110d11"

            Text {
                anchors.centerIn: parent

                text: "󰁍"
                color: "#eae0e7"

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
            text: "Network"

            color: "#eae0e7"

            font.pixelSize: 20
            font.bold: true

            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Rectangle {
        width: parent.width
        height: 1

        color: Qt.rgba(0.2980, 0.2667, 0.2980, 0.15)
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

        Text {
            width: parent.width

            text: device
                ? device.name
                : "Network device"

            color: "#eae0e7"

            font.pixelSize: 14
            font.bold: true
        }

        Text {
            text: device && device.connected
                ? "Connected"
                : "Disconnected"

            color: device && device.connected
                ? "#df6a38"
                : "#2e282e"

            font.pixelSize: 11
        }

        // =================================
        // Wi-Fi networks
        // =================================

        Repeater {
            model: device ? device.networks : []

            delegate: NetworkItem {
                width: deviceSection.width
                network: modelData
            }
        }

        // =================================
        // Disconnect
        // =================================

        Rectangle {
            width: parent.width
            height: 32

            radius: 6

            visible: device && device.connected

            color: disconnectMouse.containsMouse
                ? "#1f1a1f"
                : "#110d11"

            Text {
                anchors.centerIn: parent

                text: "Disconnect"

                color: "#eae0e7"

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

        height: 38

        radius: 6

        color: networkMouse.containsMouse
            ? "#1f1a1f"
            : "#110d11"

        border.width:
            network && network.connected
                ? 1
                : 0

        border.color: "#eae0e7"

        Row {
            anchors.fill: parent

            anchors.leftMargin: 10
            anchors.rightMargin: 10

            spacing: 8

            Text {
                text: network && network.connected
                    ? "󰤨"
                    : "󰤯"

                color: "#eae0e7"

                font.pixelSize: 17

                anchors.verticalCenter:
                    parent.verticalCenter
            }

            Text {
                width: parent.width - 30

                text: network
                    ? network.name
                    : "Unknown"

                color: "#4c444c"

                font.pixelSize: 12

                elide: Text.ElideRight

                anchors.verticalCenter:
                    parent.verticalCenter
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
