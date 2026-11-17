import QtQuick
import Quickshell.Io

Item {
    id: root

    visible: false
    width: 0
    height: 0

    FileView {
        id: paletteFile
        path: "/home/keanbp/.config/quickshell/generated/colors.json"
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
    }

    readonly property var colors: {
        try {
            const data = paletteFile.text()
            return data.length > 0 ? JSON.parse(data) : ({})
        } catch (error) {
            console.warn("Matugen palette load failed:", error)
            return ({})
        }
    }

    readonly property color background: colors.background || "#110d11"
    readonly property color surface: colors.surface || background
    readonly property color surfaceContainer: colors.surface_container || surface
    readonly property color surfaceContainerLow: colors.surface_container_low || surfaceContainer
    readonly property color surfaceContainerHigh: colors.surface_container_high || surfaceContainer
    readonly property color surfaceContainerHighest: colors.surface_container_highest || surfaceContainerHigh
    readonly property color onSurface: colors.on_surface || colors.foreground || "#eae0e7"
    readonly property color onSurfaceVariant: colors.on_surface_variant || onSurface
    readonly property color primary: colors.primary || onSurface
    readonly property color onPrimary: colors.on_primary || onSurface
    readonly property color secondary: colors.secondary || primary
    readonly property color tertiary: colors.tertiary || primary
    readonly property color error: colors.error || primary
    readonly property color outline: colors.outline || onSurfaceVariant
    readonly property color outlineVariant: colors.outline_variant || outline
}
