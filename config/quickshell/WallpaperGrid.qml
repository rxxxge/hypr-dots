import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import "Singletons"

Item {
    id: root
    property string dir: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    property string cacheDir: Quickshell.env("HOME") + "/.local/quickshell/thumbs"

    property int cols: 4
    property int rows: 3
    property int cellW: 280
    property int cellH: Math.round(cellW * 9 / 16)   // 16:9 thumbnails
    property int pad: 16

    implicitWidth:  cols * cellW + pad * 2
    implicitHeight: rows * cellH + pad * 2

    signal closeRequested()

    Process { id: setter }

    function apply(path) {
        // put your own command here; the image path is passed as $1
        setter.command = ["topia", "wallpaper", "-f", path]
        setter.running = true
    }


    onVisibleChanged: if (visible) grid.forceActiveFocus()

    GridView {
        id: grid
        anchors.fill: parent
        anchors.margins: root.pad
        cellWidth: root.cellW
        cellHeight: root.cellH
        clip: true
        keyNavigationEnabled: true
        // snapMode: GridView.SnapOneRow

        model: FolderListModel {
            folder: "file://" + root.cacheDir
            nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
            showDirs: false
        }

        Keys.onReturnPressed: if (currentItem) { 
            root.apply(currentItem.path)
            root.closeRequested()
        }
        Keys.onEscapePressed: root.closeRequested()

        delegate: Item {
            id: cell
            required property int index
            required property string filePath
            required property url fileUrl
            property string path: filePath

            width: grid.cellWidth
            height: grid.cellHeight

            Image {
                anchors.fill: parent
                anchors.margins: 6
                source: cell.fileUrl
                sourceSize.width: 480
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }
            Rectangle {
                anchors.fill: parent
                anchors.margins: 6
                color: "transparent"
                radius: 0
                border.width: cell.GridView.isCurrentItem ? 2 : 0
                border.color: Theme.cream
            }
            MouseArea {
                anchors.fill: parent
                onClicked: { grid.currentIndex = cell.index; root.apply(cell.filePath) }
            }
        }
    }
}
