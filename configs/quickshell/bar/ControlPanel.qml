import QtQuick
import Quickshell

PopupWindow {
    id: popup
    MatugenPalette { id: matugen }

    property Item anchorItem
    property string page: "main"

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Right

    implicitWidth: 340
    implicitHeight: 500

    color: "transparent"

    grabFocus: true

    // Always reopen on the main page
    onVisibleChanged: {
        if (!visible)
            page = "main";
    }

    Rectangle {
        anchors.fill: parent

        color: Qt.alpha(matugen.surfaceContainerHigh, 0.97)
        radius: 16

        border.width: 1
        border.color: Qt.alpha(matugen.outlineVariant, 0.25)

        // =================================
        // Main menu
        // =================================

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            visible: popup.page === "main"

            Text {
                text: "Control Panel"
                color: matugen.onSurface
                font.pixelSize: 18
                font.bold: true
                bottomPadding: 6
            }

            Row {
                width: parent.width
                spacing: 8

                QuickButton {
                    width: (parent.width - 8) / 2
                    icon: "󰕾"
                    label: "Audio"
                    onClicked: popup.page = "audio"
                }

                QuickButton {
                    width: (parent.width - 8) / 2
                    icon: "󰤨"
                    label: "Network"
                    onClicked: popup.page = "network"
                }
            }

            Row {
                width: parent.width
                spacing: 8

                QuickButton {
                    width: (parent.width - 8) / 2
                    icon: "󰂯"
                    label: "Bluetooth"
                    onClicked: popup.page = "bluetooth"
                }

                QuickButton {
                    width: (parent.width - 8) / 2
                    icon: "󰂚"
                    label: "Notifications"
                    onClicked: popup.page = "notifications"
                }
            }

            Item { width: 1; height: 8 }

            Row {
                width: parent.width
                spacing: 8

                QuickButton {
                    width: (parent.width - 8) / 2
                    icon: "󰌾"
                    label: "Lock"
                    onClicked: Quickshell.execDetached(["hyprlock"])
                }

                QuickButton {
                    width: (parent.width - 8) / 2
                    icon: "󰒲"
                    label: "Sleep"
                    onClicked: Quickshell.execDetached(["systemctl", "suspend"])
                }
            }

            Row {
                width: parent.width
                spacing: 8

                QuickButton {
                    width: (parent.width - 8) / 2
                    icon: "󰜉"
                    label: "Reboot"
                    onClicked: Quickshell.execDetached(["systemctl", "reboot"])
                }

                QuickButton {
                    width: (parent.width - 8) / 2
                    icon: "󰍃"
                    label: "Logout"
                    onClicked: Quickshell.execDetached([
                        "loginctl",
                        "terminate-user",
                        "keanbp"
                    ])
                }
            }

            QuickButton {
                width: parent.width
                icon: "󰐥"
                label: "Power Off"
                onClicked: Quickshell.execDetached(["systemctl", "poweroff"])
            }
        }

        // Submenus
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

        NotificationPanel {
            anchors.fill: parent
            anchors.margins: 16
            visible: popup.page === "notifications"
            onBackRequested: popup.page = "main"
        }
    }

    // Reusable pill button
    component QuickButton: Rectangle {
        id: button

        property string icon
        property string label

        signal clicked()

        height: 46
        radius: height / 2

        color: mouse.pressed
            ? matugen.primary
            : mouse.containsMouse
                ? Qt.alpha(matugen.primary, 0.48)
                : Qt.alpha(matugen.primary, 0.24)

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        Row {
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: button.icon
                color: mouse.pressed ? matugen.onPrimary : matugen.onSurface
                font.pixelSize: 18
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: button.label
                color: mouse.pressed ? matugen.onPrimary : matugen.onSurface
                font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter
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
