import QtQuick
import Quickshell

PopupWindow {
    id: popup

    property Item anchorItem
    property string page: "main"

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Right

    implicitWidth: 340
    implicitHeight: 440

    color: "transparent"

    grabFocus: true

    Rectangle {
        anchors.fill: parent

        // Dark transparent glass
        color: Qt.rgba(0.08, 0.08, 0.08, 0.88)

        radius: 10

        border.width: 1
        border.color: Qt.rgba(0.83, 0.83, 0.83, 0.18)

        // =================================
        // Main menu
        // =================================

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            visible: popup.page === "main"

            Text {
                text: "Control Panel"

                color: "#ffffff"

                font.pixelSize: 20
                font.bold: true
            }

            Rectangle {
                width: parent.width
                height: 1

                color: Qt.rgba(0.83, 0.83, 0.83, 0.15)
            }

            // =========================
            // Audio / Network
            // =========================

            Row {
                width: parent.width
                spacing: 8

                QuickButton {
                    width: (parent.width - 8) / 2

                    icon: "󰕾"
                    label: "Audio"

                    onClicked: {
                        popup.page = "audio"
                    }
                }

                QuickButton {
                    width: (parent.width - 8) / 2

                    icon: "󰤨"
                    label: "Network"

                    onClicked: {
                        popup.page = "network"
                    }
                }
            }

            // =========================
            // Bluetooth / Lock
            // =========================

            Row {
                width: parent.width
                spacing: 8

                QuickButton {
                    width: (parent.width - 8) / 2

                    icon: "󰂯"
                    label: "Bluetooth"

                    onClicked: {
                        popup.page = "bluetooth"
                    }
                }

                QuickButton {
                    width: (parent.width - 8) / 2

                    icon: "󰌾"
                    label: "Lock"

                    onClicked: {
                        Quickshell.execDetached([
                            "hyprlock"
                        ])
                    }
                }
            }

            // =========================
            // Separator
            // =========================

            Rectangle {
                width: parent.width
                height: 1

                color: Qt.rgba(0.83, 0.83, 0.83, 0.15)
            }

            // =========================
            // Power
            // =========================

            QuickButton {
                width: parent.width

                icon: "󰐥"
                label: "Power Off"

                onClicked: {
                    Quickshell.execDetached([
                        "systemctl",
                        "poweroff"
                    ])
                }
            }

            QuickButton {
                width: parent.width

                icon: "󰜉"
                label: "Reboot"

                onClicked: {
                    Quickshell.execDetached([
                        "systemctl",
                        "reboot"
                    ])
                }
            }
        }

        // =================================
        // Audio submenu
        // =================================

        AudioPanel {
            anchors.fill: parent
            anchors.margins: 16

            visible: popup.page === "audio"

            onBackRequested: {
                popup.page = "main"
            }
        }

        // =================================
        // Network submenu
        // =================================

        NetworkPanel {
            anchors.fill: parent
            anchors.margins: 16

            visible: popup.page === "network"

            onBackRequested: {
                popup.page = "main"
            }
        }

        // =================================
        // Bluetooth submenu
        // =================================

        BluetoothPanel {
            anchors.fill: parent
            anchors.margins: 16

            visible: popup.page === "bluetooth"

            onBackRequested: {
                popup.page = "main"
            }
        }
    }

    // =================================
    // Reusable button
    // =================================

    component QuickButton: Rectangle {
        id: button

        property string icon
        property string label

        signal clicked()

        height: 52

        radius: 7

        color: mouse.containsMouse
            ? Qt.rgba(0.23, 0.23, 0.23, 0.82)
            : Qt.rgba(0.16, 0.16, 0.16, 0.72)

        border.width: 1
        border.color: Qt.rgba(0.83, 0.83, 0.83, 0.12)

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }

        Row {
            anchors.centerIn: parent

            spacing: 10

            Text {
                text: button.icon

                color: "#ffffff"

                font.pixelSize: 20
            }

            Text {
                text: button.label

                color: "#ffffff"

                font.pixelSize: 14

                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            id: mouse

            anchors.fill: parent

            hoverEnabled: true

            cursorShape: Qt.PointingHandCursor

            onClicked: {
                button.clicked()
            }
        }
    }
}
