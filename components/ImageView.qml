import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.12

Window {
    id: imgView
    property var imgs: ['']
    property int idx
    visible: false
    modality: Qt.ApplicationModal
    flags: Qt.CoverWindow | Qt.CustomizeWindowHint | Qt.NoDropShadowWindowHint
           | Qt.WindowStaysOnTopHint
    color: dpalette.base
    Item {
        anchors.fill: parent

        Image {
            id: imgViewImage
            source: imgView.imgs[imgView.idx]
            //                width: parent.width * 1.5
            height: imgView.height
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
            WheelHandler {
                property: "scale"
            }
            DragHandler {
                xAxis.enabled: true
            }
        }
        RoundButton {
            icon.name: "previous"
            icon.width: 40
            icon.height: 40
            radius: 20
            enabled: imgView.idx != 0
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: 40
            }
            onClicked: {
                if (imgView.idx > 0)
                    imgView.idx--
            }
        }
        RoundButton {
            icon.name: "next"
            icon.width: 40
            icon.height: 40
            radius: 20
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 40
            }
            enabled: imgView.idx != imgView.imgs.length - 1
            onClicked: {
                if (imgView.idx < imgView.imgs.length - 1)
                    imgView.idx++
            }
        }
        Button {
            text: qsTr("reset")
            visible: imgViewImage.scale != 1.0
            anchors {
                bottom: parent.bottom
                bottomMargin: 40
                horizontalCenter: parent.horizontalCenter
            }
            onClicked: {
                imgViewImage.y = imgViewImage.x = 0
                imgViewImage.scale = 1.0
            }
        }
    }
    RoundButton {
        icon.name: "dialog-close"
        icon.width: 40
        icon.height: 40
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 5
        radius: 20
        onClicked: imgView.close()
    }
}
