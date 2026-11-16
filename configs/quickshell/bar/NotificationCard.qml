import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications

Rectangle {
    id: root


    property var notif: null
    property bool showClose: false
    property string time: ""

    readonly property alias hovered: bg.containsMouse

    signal clicked
    signal actionTaken

    // Local theme (replaces the missing Theme singleton)
    QtObject {
        id: theme

        readonly property color background: "#1c0c05"
        readonly property color foreground: "#cfc3cd"
        readonly property color critical: "#f3c9b7"
        readonly property color main: "#e78f69"
        readonly property string fontFamily: Qt.application.font.family
    }

    readonly property string iconSource: {
        if (!notif)
            return "";
        if (notif.image !== "")
            return notif.image;
        return Quickshell.iconPath(notif.appIcon, true) || "";
    }

    implicitHeight: content.implicitHeight + 24
    radius: 10
    color: Qt.alpha(theme.background, 0.92)
    border.width: 2
    border.color: notif?.urgency === NotificationUrgency.Critical
        ? theme.critical
        : theme.foreground

    MouseArea {
        id: bg

        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }

    Column {
        id: content

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 12
        }
        spacing: 8

        Row {
            width: parent.width
            spacing: 10

            IconImage {
                id: icon

                visible: root.iconSource !== ""
                implicitSize: 48
                source: root.iconSource
            }

            Column {
                width: parent.width - (icon.visible ? 58 : 0) - (root.showClose ? 28 : 0)
                spacing: 2

                Text {
                    width: parent.width
                    text: root.notif?.summary ?? ""
                    color: theme.foreground
                    font.family: theme.fontFamily
                    font.pointSize: 13
                    font.bold: true
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    visible: text !== ""
                    text: root.notif?.body ?? ""
                    color: Qt.alpha(theme.foreground, 0.8)
                    font.family: theme.fontFamily
                    font.pointSize: 11
                    textFormat: Text.StyledText
                    wrapMode: Text.Wrap
                    maximumLineCount: 4
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    visible: text !== ""
                    text: [root.notif?.appName, root.time].filter(s => s).join(" · ")
                    color: Qt.alpha(theme.foreground, 0.5)
                    font.family: theme.fontFamily
                    font.pointSize: 10
                    elide: Text.ElideRight
                }
            }

            Text {
                visible: root.showClose
                text: "󰅖"
                color: closeArea.containsMouse
                    ? theme.critical
                    : Qt.alpha(theme.foreground, 0.6)
                font.family: theme.fontFamily
                font.pointSize: 13

                MouseArea {
                    id: closeArea

                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    onClicked: root.notif?.dismiss()
                }
            }
        }

        Row {
            visible: (root.notif?.actions.length ?? 0) > 0
            spacing: 8

            Repeater {
                model: root.notif?.actions ?? []

                Rectangle {
                    id: actionBtn

                    required property var modelData

                    implicitWidth: actionText.implicitWidth + 20
                    implicitHeight: 26
                    radius: 13
                    color: actionArea.containsMouse
                        ? Qt.alpha(theme.main, 0.45)
                        : Qt.alpha(theme.foreground, 0.12)

                    Text {
                        id: actionText

                        anchors.centerIn: parent
                        text: actionBtn.modelData.text || actionBtn.modelData.identifier
                        color: theme.foreground
                        font.family: theme.fontFamily
                        font.pointSize: 10
                    }

                    MouseArea {
                        id: actionArea

                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            actionBtn.modelData.invoke();
                            root.actionTaken();
                        }
                    }
                }
            }
        }
    }
}
