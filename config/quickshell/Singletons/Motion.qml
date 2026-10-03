pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property bool reduceMotion: false
    readonly property real mult: reduceMotion ? 0.4 : 1

    // ── Durations (milliseconds) ──────────────────────────────────
    readonly property int layerIn:    Math.round(500 * mult)   // layersIn
    readonly property int layerOut:   Math.round(400 * mult)   // layersOut
    readonly property int move:       Math.round(600 * mult)   // windowsMove, workspaces
    readonly property int fadeTime:   Math.round(500 * mult)   // fadeLayers
    readonly property int colorTime:  Math.round(600 * mult)   // fade, border

    readonly property int fast:       Math.round(140 * mult)
    readonly property int standard:   Math.round(300 * mult)
    readonly property int morph:      Math.round(420 * mult)
    readonly property int shapeshift: Math.round(820 * mult)
    readonly property int glide:      Math.round(260 * mult)
    readonly property int heat:       Math.round(1100 * mult)
    readonly property int pulse:      Math.round(420 * mult)

    // ── Easing types ─────────────────────────────────────────────
    readonly property int easeStandard: Easing.OutCubic
    readonly property int easeMorph:    Easing.BezierSpline

    // ── Material 3 curves (bezier spline control points) ─────────
    //
    // Format: [c1x, c1y, c2x, c2y, endX, endY] — a single cubic segment
    // from (0,0) to (1,1). Pass as `easing.bezierCurve` with
    // `easing.type: Easing.BezierSpline`.

    // Emphasized — spatial motion, expressive. Fast start, soft settle.
    // Use for: x/y position, scale, width/height, rotation.
    readonly property var emphasized:        [0.2, 0, 0, 1, 1, 1]
    readonly property var emphasizedAccel:   [0.3, 0, 0.8, 0.15, 1, 1]
    readonly property var emphasizedDecel:   [0.05, 0.7, 0.1, 1, 1, 1]

    // Standard — general-purpose state changes.
    // Use for: expand/collapse, color, subtle transforms.
    readonly property var standardCurve:     [0.2, 0, 0, 1, 1, 1]
    readonly property var standardAccel:     [0.3, 0, 1, 1, 1, 1]
    readonly property var standardDecel:     [0, 0, 0, 1, 1, 1]

    // Expressive — bouncy, playful. Use for hero moments.
    readonly property var expressiveFast:    [0.42, 1.67, 0.21, 0.9, 1, 1]
    readonly property var expressiveDefault: [0.38, 1.21, 0.22, 1.0, 1, 1]
    readonly property var expressiveSlow:    [0.34, 1.56, 0.64, 1, 1, 1]

    // ── Legacy alias — keep for existing call sites ──────────────
    // Liquid morph curve, cubic-bezier(0.16, 1, 0.3, 1). Front-loaded
    // like an exponential chase with a long, visible settle tail.
    readonly property var morphCurve: [0.16, 1, 0.3, 1, 1, 1]

    // ── Radii ────────────────────────────────────────────────────
    readonly property real rSmall: 7
    readonly property real rTile:  13
}
