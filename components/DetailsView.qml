import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.12

ScrollView {
    id: root
    property string icons
    property string name
    property string description
    property int iconsize: 150
    property var imgs
    property var infos
    property int imgheight: 250

    contentWidth: parent.width

    Backend {
        id: backend
        pkg: infos.Package
        version: infos.Version
    }

    Row {
        RoundButton {
            icon.name: "back"
            icon.width: 30
            icon.height: 30
            onClicked: {
                root.contentWidth = 0
                stack.pop()
            }
        }
        Column {
            Text {
                text: root.name
                color: dpalette.text
                font.pointSize: root.iconsize / 4
                font.family: "Noto Serif"
            }

            Row {
                spacing: 10
                Column {
                    spacing: 10
                    Image {
                        height: root.iconsize
                        width: height
                        source: root.icons
                        anchors.horizontalCenter: parent.horizontalCenter
                        fillMode: Image.PreserveAspectFit
                    }

                    Button {
                        text: qsTr("install")
                        width: root.iconsize
                        visible: !backend.isInstalled
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Button {
                        text: backend.upToDate ? qsTr("up to date") : qsTr(
                                                     "upgrade")
                        width: root.iconsize
                        visible: backend.isInstalled
                        enabled: !backend.upToDate
                        anchors.horizontalCenter: parent.horizontalCenter
                        ToolTip.text: backend.upToDate ? qsTr("up to date") : qsTr(
                                                             "update available")
                        ToolTip.visible: hovered
                        ToolTip.delay: 500
                    }
                    Button {
                        text: qsTr("uninstall")
                        width: root.iconsize
                        visible: backend.isInstalled
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
                Column {
                    ListModel {
                        id: infomodel
                        Component.onCompleted: {
                            let info = []
                            for (let i in root.infos) {
                                infomodel.append({
                                                     "key": i,
                                                     "val": infos[i]
                                                 })
                            }
                        }
                    }

                    Repeater {
                        model: infomodel

                        Text {
                            color: dpalette.text
                            onLinkActivated: Qt.openUrlExternally(link)
                            text: key + ": " + val
                        }
                    }
                }
            }
            Text {
                text: qsTr("Details")
                color: dpalette.text
                width: parent.width
                font.pointSize: root.iconsize / 8
                padding: 3
            }
            Text {
                text: root.description
                color: dpalette.text
                width: parent.width
                wrapMode: Text.Wrap
            }
            Text {
                text: qsTr("Screenshots")
                color: dpalette.text
                font.pointSize: root.iconsize / 8
                padding: 3
            }

            ListModel {
                id: imgsmodel
            }

            ListView {
                id: rootImageList
                model: root.imgs
                orientation: Qt.Horizontal
                clip: true
                width: root.width
                height: root.imgheight
                boundsBehavior: Flickable.DragOverBounds
                spacing: 10
                delegate: Row {
                    Image {
                        source: modelData
                        height: root.imgheight
                        fillMode: Image.PreserveAspectFit
                        ToolTip.text: modelData
                        TapHandler {
                            onTapped: {
                                imgView.imgs = root.imgs
                                imgView.idx = index
                                imgView.showMaximized()
                            }
                        }
                    }
                }
            }
        }
    }
    ImageView {
        id: imgView
    }
}
