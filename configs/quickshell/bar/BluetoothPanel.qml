import QtQuick
import Quickshell
import Quickshell.Bluetooth

Column {
    id: root

    signal backRequested()

    spacing: 10

    property var adapter: Bluetooth.defaultAdapter

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
                text: "UNSC // BLUETOOTH"
                color: root.fg
                font.pixelSize: 15
                font.bold: true
                font.family: "monospace"
            }

            Text {
                text: "WIRELESS DEVICE MANAGEMENT"
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
        text: "ADAPTER STATUS"
        color: root.amber
        font.pixelSize: 10
        font.bold: true
        font.family: "monospace"
    }

    // Bluetooth power
    Rectangle {
        width: parent.width
        height: 52
        color: root.panel
        border.width: 1
        border.color: root.borderColor
        radius: 2

        Rectangle {
            width: 3
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            color: root.adapter && root.adapter.enabled
                ? root.green
                : root.muted
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 8
            spacing: 8

            Column {
                width: parent.width - 88
                anchors.verticalCenter: parent.verticalCenter
                spacing: 3

                Text {
                    width: parent.width
                    text: root.adapter
                        ? (root.adapter.enabled
                            ? "Bluetooth Online"
                            : "Bluetooth Offline")
                        : "No Adapter Detected"
                    color: root.fg
                    font.pixelSize: 12
                    font.bold: true
                    font.family: "monospace"
                    elide: Text.ElideRight
                }

                Text {
                    text: root.adapter && root.adapter.enabled
                        ? "RADIO SYSTEM READY"
                        : "RADIO SYSTEM STANDBY"
                    color: root.muted
                    font.pixelSize: 9
                    font.family: "monospace"
                }
            }

            Rectangle {
                width: 70
                height: 30
                anchors.verticalCenter: parent.verticalCenter
                radius: 2
                color: toggleMouse.containsMouse
                    ? root.hover
                    : "#171D18"
                border.width: 1
                border.color: root.adapter && root.adapter.enabled
                    ? root.green
                    : root.borderColor

                Text {
                    anchors.centerIn: parent
                    text: root.adapter && root.adapter.enabled ? "ON" : "OFF"
                    color: root.adapter && root.adapter.enabled
                        ? root.green
                        : root.muted
                    font.pixelSize: 11
                    font.bold: true
                    font.family: "monospace"
                }

                MouseArea {
                    id: toggleMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: root.adapter !== null
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.adapter)
                            root.adapter.enabled = !root.adapter.enabled
                    }
                }
            }
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        color: root.borderColor
    }

    Row {
        width: parent.width
        spacing: 8

        Text {
            text: "REGISTERED DEVICES"
            color: root.amber
            font.pixelSize: 10
            font.bold: true
            font.family: "monospace"
        }

        Item {
            width: Math.max(0, parent.width - 155)
            height: 1
        }

        Text {
            text: root.adapter ? String(root.adapter.devices.length) + " FOUND" : "0 FOUND"
            color: root.muted
            font.pixelSize: 9
            font.family: "monospace"
        }
    }

    Repeater {
        model: root.adapter ? root.adapter.devices : []

        delegate: BluetoothItem {
            width: root.width
            device: modelData
        }
    }

    Rectangle {
        width: parent.width
        height: 54
        visible: !root.adapter || !root.adapter.enabled
        color: root.panel
        border.width: 1
        border.color: root.borderColor
        radius: 2

        Text {
            anchors.centerIn: parent
            text: "RADIO DISABLED"
            color: root.muted
            font.pixelSize: 11
            font.family: "monospace"
        }
    }

    Text {
        visible: root.adapter && root.adapter.enabled
            && root.adapter.devices.length === 0
        text: "NO PAIRED DEVICES DETECTED"
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
        text: "UNSC // WIRELESS COMMUNICATIONS"
        color: root.muted
        font.pixelSize: 9
        font.family: "monospace"
        horizontalAlignment: Text.AlignHCenter
    }

    component BluetoothItem: Rectangle {
        id: deviceItem

        property var device

        height: 54
        radius: 2

        color: deviceMouse.containsMouse ? root.hover : root.panel
        border.width: 1
        border.color: deviceMouse.containsMouse
            ? root.green
            : root.borderColor

        Row {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 8
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "󰂯"
                color: root.green
                font.pixelSize: 19
            }

            Column {
                width: Math.max(40, parent.width - 112)
                anchors.verticalCenter: parent.verticalCenter
                spacing: 3

                Text {
                    width: parent.width
                    text: deviceItem.device
                        ? deviceItem.device.name
                        : "Unknown Device"
                    color: root.fg
                    font.pixelSize: 11
                    font.bold: true
                    font.family: "monospace"
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: {
                        if (!deviceItem.device)
                            return "DEVICE UNAVAILABLE"
                        if (deviceItem.device.connected)
                            return "● CONNECTED"
                        if (deviceItem.device.paired)
                            return "PAIRED // STANDBY"
                        return "UNPAIRED"
                    }
                    color: deviceItem.device && deviceItem.device.connected
                        ? root.green
                        : root.muted
                    font.pixelSize: 9
                    font.family: "monospace"
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                width: 70
                height: 30
                anchors.verticalCenter: parent.verticalCenter
                radius: 2
                color: actionMouse.containsMouse ? root.hover : "#171D18"
                border.width: 1
                border.color: actionMouse.containsMouse
                    ? root.green
                    : root.borderColor

                Text {
                    anchors.centerIn: parent
                    text: {
                        if (!deviceItem.device)
                            return "N/A"
                        if (deviceItem.device.connected)
                            return "DISCONNECT"
                        if (deviceItem.device.paired)
                            return "CONNECT"
                        return "PAIR"
                    }
                    color: root.fg
                    font.pixelSize: 9
                    font.bold: true
                    font.family: "monospace"
                }

                MouseArea {
                    id: actionMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: deviceItem.device !== null
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (!deviceItem.device)
                            return

                        if (deviceItem.device.connected) {
                            deviceItem.device.disconnect()
                        } else if (deviceItem.device.paired) {
                            deviceItem.device.connect()
                        } else {
                            deviceItem.device.pair()
                        }
                    }
                }
            }
        }

        MouseArea {
            id: deviceMouse
            anchors.fill: parent
            hoverEnabled: true
            z: -1
        }
    }
}
