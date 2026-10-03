pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string dir: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    property var list: []
    property string current: ""
    property string previewPath: ""
    property bool scanning: false

    readonly property string script: "topia wallpaper -f"

    function rescan() {
        if (scanProc.running) return;
        scanProc.running = true;
        scanning = true;
    }

    // Not used for now
    function preview(path) {
        if (path === previewPath) return;
        previewPath = path;
        previewProc.command = ["bash", script, "preview", path];
        previewProc.running = false;
        previewProc.running = true;
    }

    function stopPreview() {
        if (previewPath === "") return;
        previewPath = "";
        if (current !== "")
            preview(current);
    }

    function setWallpaper(path) {
        previewPath = "";
        setProc.command = ["topia", "wallpaper", "-f", path];
        setProc.running = false;
        setProc.running = true;
    }

    Process {
        id: scanProc
        command: ["sh", "-c",
            "find \"$1\" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) | sort",
            "_", root.dir]
        stdout: StdioCollector {
            onStreamFinished: {
                root.list = this.text.split("\n").filter(l => l.length > 0);
                root.scanning = false;
            }
        }
    }

    Process {
        id: previewProc
        onExited: function(code) {
            if (code !== 0)
                console.log("preview failed:", code);
        }
    }

    Process {
        id: setProc
        onExited: function(code) {
            if (code === 0) {
                root.current = setProc.command[3];
            }
        }
    }

    IpcHandler {
        target: "wallpaper"
        function get(): string { return root.current; }
        function set(path: string): void { root.setWallpaper(path); }
        function list(): var { return root.list; }
        function rescan(): void { root.rescan(); }
    }

    Component.onCompleted: rescan()
}