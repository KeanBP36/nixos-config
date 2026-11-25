pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Single shared notification receiver for the whole shell.
// Only one program can own org.freedesktop.Notifications, so stop mako first.
Singleton {
    id: store

    readonly property alias server: server
    readonly property var notifications: server.trackedNotifications
    readonly property int count: server.trackedNotifications.values.length

    function clearAll() {
        const list = server.trackedNotifications.values.slice();
        for (let i = 0; i < list.length; ++i)
            list[i].dismiss();
    }

    NotificationServer {
        id: server

        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true

        onNotification: notification => {
            // Required, otherwise the notification is dropped after this handler
            notification.tracked = true;
        }
    }
}

