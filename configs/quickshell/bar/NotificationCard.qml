import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications

Rectangle {
    id: root
    MatugenPalette { id: matugen }

    property var notif: null
    property bool showClose: false
    property string time: ""

    readonly property alias hovered: bg.containsMouse

    signal clicked
    signal actionTaken

    // Local theme
    QtObject {
        id: theme

        readonly property color background: matugen.surfaceContainerHigh
        readonly property color foreground: matugen.onSurface
        readonly property color critical: matugen.error
        readonly property color main: matugen.primary
        readonly property string fontFamily: Qt.application.font.family
    }

    readonly property string iconSource: {
        if (!notif)
            return "";
        if (notif.image !== "")
            return notif.image;
        return Quickshell.iconPath(notif.appIcon, true) || "";
    }

    readonly property bool critical:
        notif?.urgency === NotificationUrgency.Critical

    implicitHeight: content.implicitHeight + 28
    radius: 16
    color: Qt.alpha(theme.background, 0.97)

    // Only critical notifications get an outline
    border.width: critical ? 1.5 : 0
    border.color: theme.critical

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
            margins: 14
        }
        spacing: 10

        Row {
            width: parent.width
            spacing: 12

            IconImage {
                id: icon

                visible: root.iconSource !== ""
                implicitSize: 40
                source: root.iconSource
            }

            Column {
                width: parent.width - (icon.visible ? 52 : 0) - (root.showClose ? 28 : 0)
                spacing: 2

                Text {
                    width: parent.width
                    text: root.notif?.summary ?? ""
                    color: theme.foreground
                    font.family: theme.fontFamily
                    font.pointSize: 12
                    font.bold: true
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    visible: text !== ""
                    text: root.notif?.body ?? ""
                    color: Qt.alpha(theme.foreground, 0.8)
                    font.family: theme.fontFamily
                    font.pointSize: 10
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
                    font.pointSize: 9
                    elide: Text.ElideRight
                }
            }

            Text {
                visible: root.showClose
                text: "󰅖"
                color: closeArea.containsMouse
                    ? theme.critical
                    : Qt.alpha(theme.foreground, 0.5)
                font.family: theme.fontFamily
                font.pointSize: 12

                MouseArea {
                    id: closeArea

                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
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

                    implicitWidth: actionText.implicitWidth + 24
                    implicitHeight: 28
                    radius: height / 2

                    color: actionArea.pressed
                        ? theme.main
                        : actionArea.containsMouse
                            ? Qt.alpha(theme.main, 0.65)
                            : Qt.alpha(theme.main, 0.30)

                    Behavior on color {
                        ColorAnimation { duration: 120 }
                    }

                    Text {
                        id: actionText

                        anchors.centerIn: parent
                        text: actionBtn.modelData.text || actionBtn.modelData.identifier
                        color: actionArea.pressed ? matugen.onPrimary : theme.foreground
                        font.family: theme.fontFamily
                        font.pointSize: 10
                    }

                    MouseArea {
                        id: actionArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
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
