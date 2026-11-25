import QtQuick
import Quickshell
import Quickshell.Io

// Shows mako's notification history (reads `makoctl history`),
// stacked by app, with per-message / per-stack / clear-all and click-to-open-app.
Column {
    id: root
    MatugenPalette { id: matugen }

    signal backRequested()

    // Emitted after jumping to an app so the control panel can close.
    // Optional: in ControlPanel.qml add  onCloseRequested: popup.visible = false
    signal closeRequested()

    spacing: 12

    // =================================
    // State
    // =================================

    property var allRows: []
    property var hidden: ({})          // notification ids cleared in this panel
    property var expandedGroups: ({})  // app name -> true when expanded
    property var expandedItems: ({})
    property int visibleCount: 0
    property string lastText: "\u0000"

    ListModel {
        id: rowsModel
    }

    // =================================
    // Parsing
    // =================================

    function refresh() {
        if (!historyProc.running)
            historyProc.running = true
    }

    // Strip busctl-style {"type": ..., "data": ...} wrappers
    function unwrap(v) {
        if (v === null || v === undefined)
            return v

        if (Array.isArray(v))
            return v.map(unwrap)

        if (typeof v === "object") {
            if ("type" in v && "data" in v)
                return unwrap(v.data)

            var out = {}
            for (var k in v)
                out[k] = unwrap(v[k])
            return out
        }

        return v
    }

    // Collect every object that looks like a notification
    function collect(v, out) {
        if (Array.isArray(v)) {
            for (var i = 0; i < v.length; ++i)
                collect(v[i], out)
        } else if (v && typeof v === "object") {
            if ("summary" in v)
                out.push(v)
            else
                for (var k in v)
                    collect(v[k], out)
        }
    }

    function isCritical(u) {
        return u === 2 || u === "2" || u === "critical"
    }

    function parseJson(text) {
        var parsed = unwrap(JSON.parse(text))
        var found = []
        collect(parsed, found)

        var rows = []
        for (var i = 0; i < found.length; ++i) {
            var n = found[i]
            rows.push({
                nid: Number(n["id"] ?? i),
                summary: String(n["summary"] ?? ""),
                body: String(n["body"] ?? ""),
                appName: String(n["app-name"] ?? n["app_name"] ?? ""),
                desktop: String(n["desktop-entry"] ?? n["desktop_entry"] ?? ""),
                critical: isCritical(n["urgency"])
            })
        }
        return rows
    }

    // Fallback for older mako: "Notification 12: Summary" blocks
    function parseText(text) {
        var rows = []
        var lines = text.split("\n")
        var current = null

        for (var i = 0; i < lines.length; ++i) {
            var m = lines[i].match(/^Notification (\d+): (.*)$/)

            if (m) {
                current = {
                    nid: Number(m[1]),
                    summary: m[2],
                    body: "",
                    appName: "",
                    desktop: "",
                    critical: false
                }
                rows.push(current)
                continue
            }

            if (!current)
                continue

            var a = lines[i].match(/^\s+App name: (.*)$/)
            if (a)
                current.appName = a[1]

            var u = lines[i].match(/^\s+Urgency: (.*)$/)
            if (u)
                current.critical = isCritical(u[1].trim())

            var b = lines[i].match(/^\s+Body: (.*)$/)
            if (b)
                current.body = b[1]
        }

        return rows
    }

    function handleOutput(text) {
        // Nothing changed since the last refresh: keep scroll position
        if (text === root.lastText)
            return

        root.lastText = text

        var trimmed = text.trim()
        var rows = []

        if (trimmed.length > 0) {
            try {
                rows = parseJson(trimmed)
            } catch (e) {
                rows = parseText(trimmed)
            }
        }

        root.allRows = rows
        root.rebuild()
    }

    // =================================
    // Grouping / clearing
    // =================================

    function groupOf(r) {
        return r.appName !== "" ? r.appName : "Other"
    }

    function addRow(kind, r, key, count, expanded) {
        rowsModel.append({
            kind: kind,
            nid: r.nid,
            summary: r.summary,
            body: r.body,
            appName: r.appName,
            desktop: r.desktop,
            critical: r.critical,
            groupKey: key,
            groupCount: count,
            isExpanded: expanded
        })
    }

    function rebuild() {
        var groups = {}
        var order = []
        var total = 0

        for (var i = 0; i < root.allRows.length; ++i) {
            var r = root.allRows[i]

            if (root.hidden[r.nid])
                continue

            var key = root.groupOf(r)

            if (!groups[key]) {
                groups[key] = []
                order.push(key)
            }

            groups[key].push(r)
            total++
        }

        var oldY = list.contentY

        rowsModel.clear()

        for (var g = 0; g < order.length; ++g) {
            var k = order[g]
            var items = groups[k]

            if (items.length === 1) {
                root.addRow("item", items[0], k, 1, false)
            } else if (root.expandedGroups[k]) {
                root.addRow("header", items[0], k, items.length, true)

                for (var j = 0; j < items.length; ++j)
                    root.addRow("item", items[j], k, items.length, true)
            } else {
                root.addRow("stack", items[0], k, items.length, false)
            }
        }

        root.visibleCount = total

        Qt.callLater(function () {
            var maxY = Math.max(0, list.contentHeight - list.height)
            list.contentY = Math.min(oldY, maxY)
        })
    }

    function hideIds(ids) {
        var h = {}

        for (var k in root.hidden)
            h[k] = true

        for (var i = 0; i < ids.length; ++i)
            h[ids[i]] = true

        root.hidden = h
        root.rebuild()
    }

    function groupIds(key) {
        var ids = []

        for (var i = 0; i < root.allRows.length; ++i) {
            var r = root.allRows[i]

            if (!root.hidden[r.nid] && root.groupOf(r) === key)
                ids.push(r.nid)
        }

        return ids
    }

    function clearAll() {
        var ids = []

        for (var i = 0; i < root.allRows.length; ++i)
            ids.push(root.allRows[i].nid)

        root.hideIds(ids)
    }

    function toggleGroup(key) {
        var e = {}

        for (var k in root.expandedGroups)
            e[k] = root.expandedGroups[k]

        e[key] = !root.expandedGroups[key]

        root.expandedGroups = e
        root.rebuild()
    }

    function toggleItem(nid) {
        var e = {}

        for (var k in root.expandedItems)
            e[k] = root.expandedItems[k]

        e[nid] = !root.expandedItems[nid]
        root.expandedItems = e
    }

    // Focus the app's window (Hyprland), then mark the notification as read
    function openApp(nid, appName, desktop) {
        var name = appName

        if (name === "" && desktop !== "") {
            var parts = desktop.replace(/\.desktop$/, "").split(".")
            name = parts[parts.length - 1]
        }

        if (name !== "") {
            var pattern = name.replace(/[^A-Za-z0-9]/g, ".")

            Quickshell.execDetached([
                "sh",
                "-c",
                "[ -n \"$HYPRLAND_INSTANCE_SIGNATURE\" ] && hyprctl dispatch focuswindow \"class:(?i).*$0.*\"",
                pattern
            ])
        }

        root.hideIds([nid])
        root.closeRequested()
    }

    Process {
        id: historyProc

        command: [
            "busctl", "--user", "--json=short",
            "call",
            "org.freedesktop.Notifications",
            "/fr/emersion/Mako",
            "fr.emersion.Mako",
            "ListHistory"
        ]
        running: false

        stdout: StdioCollector {
            onStreamFinished: root.handleOutput(this.text)
        }

        stderr: SplitParser {
            splitMarker: "\n"

            onRead: data => console.log("MAKOCTL:", data)
        }
    }

    // Refresh while the page is open
    Timer {
        interval: 2000
        repeat: true
        running: root.visible
        triggeredOnStart: true

        onTriggered: root.refresh()
    }

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
            text: "Notifications"
            color: matugen.onSurface
            font.pixelSize: 18
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // =================================
    // Count + Clear all
    // =================================

    Row {
        width: parent.width
        height: 28

        Text {
            width: parent.width - 84
            leftPadding: 4

            text: root.visibleCount + (
                root.visibleCount === 1
                    ? " notification"
                    : " notifications"
            )

            color: Qt.lighter(matugen.outline, 1.6)
            font.pixelSize: 12

            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: 80
            height: 28
            radius: height / 2

            visible: root.visibleCount > 0

            color: clearAllMouse.pressed
                ? matugen.primary
                : clearAllMouse.containsMouse
                    ? Qt.alpha(matugen.primary, 0.65)
                    : Qt.alpha(matugen.primary, 0.30)

            Behavior on color {
                ColorAnimation { duration: 120 }
            }

            Text {
                anchors.centerIn: parent
                text: "Clear all"
                color: clearAllMouse.pressed ? matugen.onPrimary : matugen.onSurface
                font.pixelSize: 11
            }

            MouseArea {
                id: clearAllMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.clearAll()
            }
        }
    }

    // =================================
    // List
    // =================================

    ListView {
        id: list

        width: root.width
        height: Math.max(100, root.height - 88)

        clip: true
        spacing: 8

        model: rowsModel

        delegate: Item {
            id: row

            required property string kind
            required property int nid
            required property string summary
            required property string body
            required property string appName
            required property string desktop
            required property bool critical
            required property string groupKey
            required property int groupCount
            required property bool isExpanded

            width: list.width

            height: row.kind === "header"
                ? 28
                : card.height + (row.kind === "stack" ? 8 : 0)

            // ---- Group header (expanded stacks) ----

            Rectangle {
                visible: row.kind === "header"

                width: parent.width
                height: 28
                radius: height / 2

                color: headerMouse.containsMouse
                    ? Qt.alpha(matugen.primary, 0.48)
                    : Qt.alpha(matugen.primary, 0.24)

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter

                    text: "▾  " + row.groupKey + " (" + row.groupCount + ")"

                    color: matugen.onSurface
                    font.pixelSize: 12
                    font.bold: true
                }

                MouseArea {
                    id: headerMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: root.toggleGroup(row.groupKey)
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter

                    width: 52
                    height: 20
                    radius: height / 2

                    color: groupClearMouse.pressed
                        ? matugen.primary
                        : groupClearMouse.containsMouse
                            ? Qt.alpha(matugen.primary, 0.65)
                            : Qt.alpha(matugen.primary, 0.30)

                    Text {
                        anchors.centerIn: parent
                        text: "Clear"
                        color: groupClearMouse.pressed ? matugen.onPrimary : matugen.onSurface
                        font.pixelSize: 10
                    }

                    MouseArea {
                        id: groupClearMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: root.hideIds(root.groupIds(row.groupKey))
                    }
                }
            }

            // ---- Stack layers behind the top card ----

            Rectangle {
                visible: row.kind === "stack"

                x: 12
                y: 8

                width: parent.width - 24
                height: card.height
                radius: 14

                color: Qt.alpha(matugen.primary, 0.14)
            }

            Rectangle {
                visible: row.kind === "stack"

                x: 6
                y: 4

                width: parent.width - 12
                height: card.height
                radius: 14

                color: Qt.alpha(matugen.primary, 0.18)
            }

            // ---- Card ----

            NotificationItem {
                id: card

                visible: row.kind !== "header"

                width: parent.width

                title: row.summary
                text: row.body

                app: row.kind === "stack"
                    ? row.appName + "  ·  +" + (row.groupCount - 1) + " more"
                    : row.appName

                urgent: row.critical

                expanded: root.expandedItems[row.nid] === true
                canExpand: row.kind !== "stack"
                onExpandToggled: root.toggleItem(row.nid)

                onActivated: {
                    if (row.kind === "stack")
                        root.toggleGroup(row.groupKey)
                    else
                        root.openApp(row.nid, row.appName, row.desktop)
                }

                onClosed: {
                    if (row.kind === "stack")
                        root.hideIds(root.groupIds(row.groupKey))
                    else
                        root.hideIds([row.nid])
                }
            }
        }
    }

    Text {
        visible: root.visibleCount === 0

        text: "No notifications"

        color: Qt.lighter(matugen.outline, 1.6)
        font.pixelSize: 12
        leftPadding: 4
    }

    // =================================
    // Notification card
    // =================================

    component NotificationItem: Rectangle {
        id: item

        property string title
        property string text
        property string app
        property bool urgent
        property bool expanded: false
        property bool canExpand: true

        signal activated()
        signal closed()
        signal expandToggled()

        height: content.implicitHeight + 24

        radius: 14

        color: cardMouse.containsMouse
            ? Qt.alpha(matugen.primary, 0.38)
            : Qt.alpha(matugen.primary, 0.24)

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        // Only critical notifications get an outline
        border.width: item.urgent ? 1.5 : 0
        border.color: matugen.error

        MouseArea {
            id: cardMouse

            anchors.fill: parent

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: item.activated()
        }

        Row {
            id: content

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 12

            spacing: 8

            Column {
                width: parent.width - 28
                spacing: 2

                Text {
                    width: parent.width

                    text: item.title

                    color: matugen.onSurface
                    font.pixelSize: 13
                    font.bold: true

                    elide: Text.ElideRight
                }

                Text {
                    id: bodyText

                    width: parent.width

                    visible: item.text !== ""
                    text: item.text

                    color: Qt.alpha(matugen.onSurface, 0.8)
                    font.pixelSize: 11

                    wrapMode: Text.Wrap
                    maximumLineCount: item.expanded ? 1000 : 2
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width

                    visible: item.app !== ""
                    text: item.app

                    color: Qt.lighter(matugen.outline, 1.6)
                    font.pixelSize: 10

                    elide: Text.ElideRight
                }
            }

            Column {
                width: 20
                spacing: 6

                Text {
                    text: "󰅖"

                    color: closeMouse.containsMouse
                        ? matugen.error
                        : Qt.lighter(matugen.outline, 1.6)

                    font.pixelSize: 16

                    MouseArea {
                        id: closeMouse

                        anchors.fill: parent
                        anchors.margins: -4

                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: item.closed()
                    }
                }

                Text {
                    visible: item.canExpand
                        && (bodyText.truncated || item.expanded)

                    text: item.expanded ? "▴" : "▾"
                    color: expandMouse.containsMouse ? matugen.onSurface : Qt.lighter(matugen.outline, 1.6)
                    font.pixelSize: 14

                    MouseArea {
                        id: expandMouse

                        anchors.fill: parent
                        anchors.margins: -4

                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: item.expandToggled()
                    }
                }
            }
        }
    }
}
