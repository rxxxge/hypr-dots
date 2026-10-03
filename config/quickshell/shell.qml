import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
// import Quickshell.Shape
import QtQuick
import QtQuick.Layouts
import "Singletons"

PanelWindow {
    id: mainStatusBar

    WlrLayershell.namespace: "quickshell:bar"
    WlrLayershell.layer: WlrLayershell.Top
    // WlrLayershell.keyboardFocus: panel.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors { top: true; left: true; right: true }
    
    implicitHeight: screen.height
    exclusiveZone: 28
    color: "transparent"
    // color: "#c7050301" // temp color
    // color: Qt.rgba(0, 0, 0, 0.78)

    mask: Region {
        Region {
            x: 0; y: 0
            width: mainStatusBar.width
            height: 28
        }
        // Region {
        //     x: Math.floor(panel.x); y: Math.floor(panel.y)
        //     width:  panel.open ? Math.ceil(panel.width)  : 0
        //     height: panel.open ? Math.ceil(panel.height) : 0
        // }
    }

    Rectangle {
        id: bar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 28
        // color: Theme.tileBg
        color: Qt.alpha(Theme.tileBg, 0.78)

        // Click anywhere on the bar to toggle the panel.
        // MouseArea {
        //     anchors.fill: parent
        //     onClicked: panel.open = !panel.open
        // }

        Item {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8

            // Left group
            RowLayout {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Text { text: "󰣇"; color: Theme.cream; font.family: Theme.font; font.pointSize: 12 }
                // Text { text: ""; color: "#fff"; font.family: "FiraCode Nerd Font Med"; font.pointSize: 10 }

                Workspaces {
                    screenName: "DP-2"   // or whatever your monitor's name variable is
                    s: 1.25
                }
            }

            // Center group — truly centered
            // RowLayout {
            //     anchors.horizontalCenter: parent.horizontalCenter
            //     anchors.verticalCenter: parent.verticalCenter
            //     spacing: 8
            //     Text { text: "Bar"; color: "#fff"; font.family: Theme.font; font.pointSize: 10 }
            // }

            // Right group
            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                Text { text: "CPU"; color: Theme.cream; font.family: Theme.font; font.pointSize: 10 }
                Text { text: "RAM"; color: Theme.cream; font.family: Theme.font; font.pointSize: 10 }
            }
        }
    }


    // ── Expandable panel ───────────────────────────────────────────────
    // ── Expandable panel — grows down out of the bar ──────────────────
    //

    // Rectangle {
    //     id: panel
    //
    //     // anchors.top: bar.bottom              // flush with bar's bottom edge
    //     anchors.horizontalCenter: parent.horizontalCenter
    //     // anchors.verticalCenter: parent.verticalCenter
    //     property bool open: false
    //     property bool showBody: false
    //     onOpenChanged: {
    //         if (open) {
    //             showBody = true
    //         } else {
    //             hideTimer.restart()
    //         }
    //     }
    //
    //     Timer {
    //         id: hideTimer
    //         interval: 150                // ≈ text fade time
    //         onTriggered: panel.showBody = false
    //     }
    //
    //     width: open ? wallpaperGrid.implicitWidth : 0
    //     height: open ? wallpaperGrid.implicitHeight : 0
    //     // opacity: showBody ? 1 : 0
    //
    //     // y slides between "off the bottom" and "centered"
    //     readonly property real centeredY: parent.height - height
    //     readonly property real offscreenY: parent.height + 20
    //     // y: showBody ? centeredY : offscreenY
    //     y: centeredY
    //
    //
    //     opacity: open ? 1 : 0
    //     // scale:   open ? 1 : 0.4          // popin 87%
    //     transformOrigin: Item.Center
    //     visible: opacity > 0
    //
    //     // Square top (merges into the bar, no seam),
    //     // rounded bottom that arrives with the grow.
    //     topLeftRadius:  5
    //     topRightRadius: 5
    //     bottomLeftRadius: 0
    //     bottomRightRadius: 0
    //
    //     // Same colour as the bar so they read as one surface.
    //     color: Qt.alpha(Theme.tileBg, 0.78)
    //     clip: true

        // Behavior on scale {
        //     NumberAnimation {
        //         duration: panel.open ? Motion.layerOut : Motion.layerOut
        //         easing.type: Easing.BezierSpline
        //         easing.bezierCurve: panel.open ? Motion.emphasizedDecel : Motion.emphasizedDecel
        //     }
        // }

        // Behavior on width {
        //     NumberAnimation {
        //         duration: panel.open ? Motion.layerOut : Motion.layerOut
        //         easing.type: Easing.BezierSpline
        //         easing.bezierCurve: panel.open ? Motion.emphasizedDecel : Motion.emphasizedDecel
        //     }
        // }
        //
        // Behavior on height {
        //     NumberAnimation {
        //         duration: panel.open ? Motion.layerOut : Motion.layerOut
        //         easing.type: Easing.BezierSpline
        //         easing.bezierCurve: panel.open ? Motion.emphasizedDecel : Motion.emphasizedDecel
        //     }
        // }
        //
        // // fade: speed 6, standard
        // Behavior on opacity {
        //     NumberAnimation {
        //         duration: Motion.fast
        //         easing.type: Easing.BezierSpline
        //         easing.bezierCurve: Motion.standardCurve
        //     }
        // }

        // WallpaperGrid {
        //     id: wallpaperGrid
        //     // anchors.fill: parent
        //     width: implicitWidth
        //     height: implicitHeight
        //     anchors.horizontalCenter: parent.horizontalCenter
        //     anchors.bottom: parent.bottom
        //
        //     transformOrigin: Item.Bottom
        //     scale: implicitWidth > 0 ? panel.width / implicitWidth : 0
        //     // visible: panel.showBody
        //     onCloseRequested: panel.open = false
        // }
    // }

}
