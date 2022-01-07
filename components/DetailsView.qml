import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.12
import "utils.js" as Utils

ScrollView {
    id: root
    //    property string icons
    //    property string name
    //    property string description
    //    property var imgs
    property var infos
    property string category
    property int iconsize: 150
    property int imgheight: 250

    contentWidth: parent.width

    Backend {
        id: backend
        pkg: infos.Pkgname
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
                text: root.infos.Name
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
                        source: root.infos.icons
                        anchors.horizontalCenter: parent.horizontalCenter
                        fillMode: Image.PreserveAspectFit
                    }

                    Button {
                        text: qsTr("install")
                        width: root.iconsize
                        visible: !backend.isInstalled
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            console.error("installing")
                            backend.addTask({
                                                "type": "install",
                                                "category": root.category,
                                                "filename": infos.Filename,
                                                "pkgname": infos.Pkgname,
                                                "name": infos.Name,
                                                "icons": infos.icons
                                            })
                        }
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
                        onClicked: {
                            console.error("updating")
                            backend.addTask({
                                                "type": "update",
                                                "category": root.category,
                                                "filename": infos.Filename,
                                                "pkgname": infos.Pkgname,
                                                "name": infos.Name,
                                                "icons": infos.icons
                                            })
                        }
                    }
                    Button {
                        text: qsTr("uninstall")
                        width: root.iconsize
                        visible: backend.isInstalled
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            console.error("installing")
                            backend.addTask({
                                                "type": "uninstall",
                                                "filename": infos.Filename,
                                                "pkgname": infos.Pkgname,
                                                "name": infos.Name,
                                                "icons": infos.icons
                                            })
                        }
                    }
                }
                Column {
                    ListModel {
                        id: infomodel
                        Component.onCompleted: {
                            let info = []
                            const displayed = ["Version", "Pkgname", "Author", "Contributer", "Website", "Update", "Size"]
                            for (let i in displayed) {
                                infomodel.append({
                                                     "key": displayed[i],
                                                     "val": displayed[i] == "Website" ? "<a href='" + infos[displayed[i]] + "'>" + infos[displayed[i]] + "</a>" : infos[displayed[i]]
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
                text: root.infos.More
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
                model: JSON.parse(root.infos.img_urls || '[]')
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
