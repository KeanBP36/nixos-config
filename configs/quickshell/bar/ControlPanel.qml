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
    implicitHeight: 600
    color: "transparent"
    grabFocus: true

    readonly property color bg: "#151B16"
    readonly property color panel: "#202921"
    readonly property color panelHover: "#303D2F"
    readonly property color green: "#9BAF75"
    readonly property color textColor: "#D5DEC8"
    readonly property color muted: "#849078"
    readonly property color borderColor: "#46563C"
    readonly property color amber: "#E9AD4C"
    readonly property color danger: "#D66D5B"

    Rectangle {
        anchors.fill: parent
        color: popup.bg
        radius: 4
        border.width: 2
        border.color: popup.borderColor
        clip: true

        // UNSC header stripe
        Rectangle {
            anchors.top: parent.top
            width: parent.width
            height: 4
            color: popup.green
        }

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            visible: popup.page === "main"

            Row {
                width: parent.width
                spacing: 10

                Rectangle {
                    width: 34
                    height: 34
                    color: "#303D2F"
                    border.color: popup.green
                    border.width: 1
                    radius: 2

                    Text {
                        anchors.centerIn: parent
                        text: "U"
                        color: popup.green
                        font.pixelSize: 22
                        font.bold: true
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: "UNSC // SYSTEMS"
                        color: popup.textColor
                        font.pixelSize: 16
                        font.bold: true
                        font.family: "monospace"
                    }

                    Text {
                        text: "TACTICAL CONTROL INTERFACE"
                        color: popup.muted
                        font.pixelSize: 9
                        font.family: "monospace"
                    }
                }

                Item {
                    width: 1
                    height: 1
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: popup.borderColor
            }

            Text {
                text: "QUICK ACCESS"
                color: popup.amber
                font.pixelSize: 10
                font.bold: true
                font.family: "monospace"
            }

            Row {
                width: parent.width
                spacing: 8

                QuickButton {
                    width: (parent.width - 8) / 2
                    icon: "󰕾"
                    label: "AUDIO"
                    onClicked: popup.page = "audio"
                }

                QuickButton {
                    width: (parent.width - 8) / 2
                    icon: "󰤨"
                    label: "NETWORK"
                    onClicked: popup.page = "network"
                }
            }

            Row {
                width: parent.width
                spacing: 8

                QuickButton {
                    width: (parent.width - 8) / 2
                    icon: "󰂯"
                    label: "BLUETOOTH"
                    onClicked: popup.page = "bluetooth"
                }

                QuickButton {
                    width: (parent.width - 8) / 2
                    icon: "󰌾"
                    label: "LOCK"
                    onClicked: Quickshell.execDetached(["hyprlock"])
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: popup.borderColor
            }

            Text {
                text: "POWER MANAGEMENT"
                color: popup.amber
                font.pixelSize: 10
                font.bold: true
                font.family: "monospace"
            }

            QuickButton {
                width: parent.width
                icon: "󰐥"
                label: "POWER OFF"
                accent: popup.danger
                onClicked: Quickshell.execDetached(["systemctl", "poweroff"])
            }

            QuickButton {
                width: parent.width
                icon: "󰜉"
                label: "REBOOT SYSTEM"
                onClicked: Quickshell.execDetached(["systemctl", "reboot"])
            }

            QuickButton {
                width: parent.width
                icon: "󰒲"
                label: "SUSPEND"
                onClicked: Quickshell.execDetached(["systemctl", "suspend"])
            }

            QuickButton {
                width: parent.width
                icon: "󰍃"
                label: "LOG OUT"
                onClicked: Quickshell.execDetached([
                    "loginctl", "terminate-user", "keanbp"
                ])
            }

            Item {
                width: parent.width
                height: 1
            }

            Text {
                text: "UNSC // PERSONNEL TERMINAL"
                color: popup.muted
                font.pixelSize: 9
                font.family: "monospace"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        AudioPanel {
            anchors.fill: parent
            anchors.margins: 16
            visible: popup.page === "audio"
            onBackRequested: popup.page = "main"
        }

        NetworkPanel {
            anchors.fill: parent
            anchors.margins: 16
            visible: popup.page === "network"
            onBackRequested: popup.page = "main"
        }

        BluetoothPanel {
            anchors.fill: parent
            anchors.margins: 16
            visible: popup.page === "bluetooth"
            onBackRequested: popup.page = "main"
        }
    }

    component QuickButton: Rectangle {
        id: button

        property string icon
        property string label
        property color accent: popup.green

        signal clicked()

        height: 42
        radius: 2

        color: mouse.containsMouse ? popup.panelHover : popup.panel

        border.width: 1
        border.color: mouse.containsMouse ? button.accent : popup.borderColor

        Behavior on color {
            ColorAnimation { duration: 100 }
        }

        Rectangle {
            width: 3
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            color: mouse.containsMouse ? button.accent : "#394536"
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 10
            spacing: 10

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: button.icon
                color: button.accent
                font.pixelSize: 19
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: button.label
                color: popup.textColor
                font.pixelSize: 12
                font.bold: true
                font.family: "monospace"
            }

            Item {
                width: Math.max(0, parent.width - 150)
                height: 1
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "›"
                color: popup.muted
                font.pixelSize: 18
                visible: button.label === "AUDIO"
                    || button.label === "NETWORK"
                    || button.label === "BLUETOOTH"
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }
}
