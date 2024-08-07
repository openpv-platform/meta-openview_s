import QtQuick 2.11
import QtQuick.Window 2.11
import org.wpewebkit.qtwpe 1.0

Window {
    visible: true
    visibility: "FullScreen"
	width: 800
	height: 480
    flags: Qt.FramelessWindowHint
    title: qsTr("OpenPV Browser")

    WPEView {
        url: initialUrl
        focus: true
        anchors.fill: parent
    }
}
