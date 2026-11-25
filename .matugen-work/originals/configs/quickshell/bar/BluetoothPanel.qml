import QtQuick
import Quickshell
import Quickshell.Bluetooth

Column {
    id: root

    signal backRequested()

    spacing: 10

    property var adapter: Bluetooth.defaultAdapter

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
                ? "#3a3a3a"
                : "#252525"

            Text {
                anchors.centerIn: parent

                text: "󰁍"
                color: "#ffffff"

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
            text: "Bluetooth"

            color: "#ffffff"

            font.pixelSize: 20
            font.bold: true

            anchors.verticalCenter:
                parent.verticalCenter
        }
    }

    Rectangle {
        width: parent.width
        height: 1

        color: Qt.rgba(0.83, 0.83, 0.83, 0.15)
    }

    // =================================
    // Bluetooth power
    // =================================

    Row {
        width: parent.width
        height: 40

        Text {
            width: parent.width - 80

            text: root.adapter
                ? (
                    root.adapter.enabled
                        ? "Bluetooth On"
                        : "Bluetooth Off"
                  )
                : "No Bluetooth adapter"

            color: "#ffffff"

            font.pixelSize: 13

            anchors.verticalCenter:
                parent.verticalCenter
        }

        Rectangle {
            width: 70
            height: 32

            radius: 6

            color: toggleMouse.containsMouse
                ? "#3a3a3a"
                : "#252525"

            Text {
                anchors.centerIn: parent

                text: root.adapter
                    && root.adapter.enabled
                    ? "ON"
                    : "OFF"

                color: "#ffffff"

                font.pixelSize: 11
                font.bold: true
            }

            MouseArea {
                id: toggleMouse

                anchors.fill: parent

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    if (root.adapter) {
                        root.adapter.enabled =
                            !root.adapter.enabled
                    }
                }
            }
        }
    }

    Rectangle {
        width: parent.width
        height: 1

        color: Qt.rgba(0.83, 0.83, 0.83, 0.15)
    }

    // =================================
    // Devices
    // =================================

    Text {
        text: "Devices"

        color: "#ffffff"

        font.pixelSize: 14
        font.bold: true
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
        visible:
            root.adapter
            && root.adapter.devices.length === 0

        text: root.adapter && root.adapter.enabled
            ? "No paired devices"
            : "Bluetooth is off"

        color: "#888888"

        font.pixelSize: 12
    }

    // =================================
    // Bluetooth device
    // =================================

    component BluetoothItem: Rectangle {
        id: deviceItem

        property var device

        height: 48

        radius: 6

        color: deviceMouse.containsMouse
            ? "#3a3a3a"
            : "#252525"

        Row {
            anchors.fill: parent

            anchors.leftMargin: 10
            anchors.rightMargin: 8

            spacing: 8

            Text {
                text: "󰂯"

                color: "#ffffff"

                font.pixelSize: 18

                anchors.verticalCenter:
                    parent.verticalCenter
            }

            Column {
                width: parent.width - 110

                anchors.verticalCenter:
                    parent.verticalCenter

                spacing: 2

                Text {
                    width: parent.width

                    text: device
                        ? device.name
                        : "Unknown device"

                    color: "#ffffff"

                    font.pixelSize: 12

                    elide: Text.ElideRight
                }

                Text {
                    text:
                        device && device.connected
                            ? "Connected"
                            : device && device.paired
                                ? "Paired"
                                : "Not paired"

                    color:
                        device && device.connected
                            ? "#4ec9b0"
                            : "#888888"

                    font.pixelSize: 10
                }
            }

            Rectangle {
                width: 70
                height: 30

                radius: 5

                anchors.verticalCenter:
                    parent.verticalCenter

                color: "#202020"

                Text {
                    anchors.centerIn: parent

                    text:
                        device && device.connected
                            ? "Disconnect"
                            : device && device.paired
                                ? "Connect"
                                : "Pair"

                    color: "#ffffff"

                    font.pixelSize: 10
                }

                MouseArea {
                    anchors.fill: parent

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        if (!device)
                            return

                        if (device.connected) {
                            device.disconnect()
                        } else if (device.paired) {
                            device.connect()
                        } else {
                            device.pair()
                        }
                    }
                }
            }
        }

        MouseArea {
            id: deviceMouse

            anchors.fill: parent

            hoverEnabled: true

            cursorShape:
                Qt.PointingHandCursor

            z: -1
        }
    }
}
