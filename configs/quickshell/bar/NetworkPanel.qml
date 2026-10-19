import QtQuick
import Quickshell
import Quickshell.Networking

Column {
    id: root

    signal backRequested()

    spacing: 10

    readonly property color panel: "#202921"
    readonly property color hover: "#303D2F"
    readonly property color green: "#9BAF75"
    readonly property color fg: "#D5DEC8"
    readonly property color muted: "#849078"
    readonly property color borderColor: "#46563C"
    readonly property color amber: "#E9AD4C"

    // UNSC header
    Row {
        width: parent.width
        height: 36
        spacing: 10

        Rectangle {
            width: 34
            height: 34
            radius: 2
            color: root.panel
            border.width: 1
            border.color: root.borderColor

            Text {
                anchors.centerIn: parent
                text: "‹"
                color: root.green
                font.pixelSize: 26
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
            spacing: 2

            Text {
                text: "UNSC // NETWORK"
                color: root.fg
                font.pixelSize: 15
                font.bold: true
                font.family: "monospace"
            }

            Text {
                text: "COMMUNICATIONS & LINK STATUS"
                color: root.muted
                font.pixelSize: 9
                font.family: "monospace"
            }
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        color: root.borderColor
    }

    Text {
        text: "AVAILABLE INTERFACES"
        color: root.amber
        font.pixelSize: 10
        font.bold: true
        font.family: "monospace"
    }

    Repeater {
        model: Networking.devices

        delegate: DeviceSection {
            width: root.width
            device: modelData
        }
    }

    Text {
        visible: Networking.devices.length === 0
        text: "NO NETWORK INTERFACES DETECTED"
        color: root.muted
        font.pixelSize: 10
        font.family: "monospace"
    }

    Item {
        width: parent.width
        height: 1
    }

    Text {
        width: parent.width
        text: "UNSC // SECURE COMMUNICATIONS"
        color: root.muted
        font.pixelSize: 9
        font.family: "monospace"
        horizontalAlignment: Text.AlignHCenter
    }

    // Network device section
    component DeviceSection: Column {
        id: deviceSection

        property var device

        spacing: 6

        Rectangle {
            width: parent.width
            height: 54
            radius: 2
            color: root.panel
            border.width: 1
            border.color: root.borderColor

            Rectangle {
                width: 3
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: deviceSection.device && deviceSection.device.connected
                    ? root.green
                    : root.muted
            }

            Column {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    width: parent.width
                    text: deviceSection.device
                        ? deviceSection.device.name
                        : "NETWORK INTERFACE"
                    color: root.fg
                    font.pixelSize: 12
                    font.bold: true
                    font.family: "monospace"
                    elide: Text.ElideRight
                }

                Text {
                    text: deviceSection.device && deviceSection.device.connected
                        ? "● LINK ESTABLISHED"
                        : "○ LINK DISCONNECTED"
                    color: deviceSection.device && deviceSection.device.connected
                        ? root.green
                        : root.muted
                    font.pixelSize: 9
                    font.family: "monospace"
                }
            }
        }

        Text {
            text: "DETECTED NETWORKS"
            color: root.amber
            font.pixelSize: 9
            font.bold: true
            font.family: "monospace"
            visible: deviceSection.device
                && deviceSection.device.networks.length > 0
        }

        Repeater {
            model: deviceSection.device
                ? deviceSection.device.networks
                : []

            delegate: NetworkItem {
                width: deviceSection.width
                network: modelData
            }
        }

        Text {
            visible: deviceSection.device
                && deviceSection.device.connected
                && deviceSection.device.networks.length === 0
            text: "LINK ACTIVE // NO NETWORKS LISTED"
            color: root.muted
            font.pixelSize: 9
            font.family: "monospace"
        }

        Rectangle {
            width: parent.width
            height: 34
            radius: 2
            visible: deviceSection.device && deviceSection.device.connected
            color: disconnectMouse.containsMouse ? root.hover : root.panel
            border.width: 1
            border.color: root.borderColor

            Text {
                anchors.centerIn: parent
                text: "DISCONNECT INTERFACE"
                color: root.fg
                font.pixelSize: 10
                font.bold: true
                font.family: "monospace"
            }

            MouseArea {
                id: disconnectMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (deviceSection.device)
                        deviceSection.device.disconnect()
                }
            }
        }
    }

    // Individual network
    component NetworkItem: Rectangle {
        id: networkItem

        property var network

        height: 40
        radius: 2

        color: networkMouse.containsMouse ? root.hover : root.panel

        border.width: 1
        border.color: network && network.connected
            ? root.green
            : root.borderColor

        Row {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 8
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: networkItem.network && networkItem.network.connected
                    ? "󰤨"
                    : "󰤯"
                color: networkItem.network && networkItem.network.connected
                    ? root.green
                    : root.muted
                font.pixelSize: 17
            }

            Column {
                width: Math.max(40, parent.width - 100)
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    width: parent.width
                    text: networkItem.network
                        ? networkItem.network.name
                        : "UNKNOWN NETWORK"
                    color: root.fg
                    font.pixelSize: 11
                    font.family: "monospace"
                    elide: Text.ElideRight
                }

                Text {
                    text: networkItem.network && networkItem.network.connected
                        ? "CONNECTED"
                        : networkItem.network && networkItem.network.known
                            ? "KNOWN NETWORK"
                            : "UNREGISTERED"
                    color: networkItem.network && networkItem.network.connected
                        ? root.green
                        : root.muted
                    font.pixelSize: 9
                    font.family: "monospace"
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: networkItem.network && networkItem.network.connected
                    ? "ACTIVE"
                    : networkItem.network && networkItem.network.known
                        ? "CONNECT"
                        : "—"
                color: networkItem.network && networkItem.network.connected
                    ? root.green
                    : root.amber
                font.pixelSize: 9
                font.bold: true
                font.family: "monospace"
            }
        }

        MouseArea {
            id: networkMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                if (!networkItem.network)
                    return

                if (networkItem.network.connected)
                    networkItem.network.disconnect()
                else if (networkItem.network.known)
                    networkItem.network.connect()
            }
        }
    }
}
