import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import "utils.js" as Utils
import singleton.backend 1.0
import singleton.dpalette 1.0

Item {
    id: root
    property var infos
    property string category
    property int iconsize: 150
    property int imgheight: 250

    //    contentWidth: parent.width
    Appinfo {
        id: appinfo
        pkg: infos.Pkgname
        version: infos.Version
    }

    RoundButton {
        id: backButton
        anchors.left: parent.left
        anchors.top: parent.top
        icon.name: "back"
        icon.width: 30
        icon.height: 30
        onClicked: {
            stack.pop()
        }
    }

    Flickable {
        id: scrollView
        clip: true
        anchors.left: backButton.right
        anchors.right: parent.right
        height: parent.height
        contentHeight: col.height

        boundsBehavior: Flickable.DragOverBounds
        flickableDirection: Flickable.VerticalFlick
        Component.onCompleted: console.warn('flickable', flickDeceleration)

        Column {
            id: col
            width: parent.width
            Text {
                text: root.infos.Name
                color: DPalette.text
                font.pointSize: root.iconsize / 4
                font.family: "Noto Serif"
            }

            Row {
                width: parent.width
                Component.onCompleted: console.warn('row', height)
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
                    BusyIndicator {
                        visible: appinfo.isInstalled === -1
                        height: 40
                        dots: 3
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Button {
                        text: qsTr("install")
                        width: root.iconsize
                        visible: appinfo.isInstalled === 0
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            console.error("installing")
                            Backend.addTask({
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
                        text: appinfo.upToDate == 1 ? qsTr("up to date") : qsTr(
                                                          "upgrade")
                        width: root.iconsize
                        visible: appinfo.isInstalled === 1
                        enabled: appinfo.upToDate === 0
                        anchors.horizontalCenter: parent.horizontalCenter
                        ToolTip.text: appinfo.upToDate ? qsTr("up to date") : qsTr(
                                                             "update available")
                        ToolTip.visible: hovered
                        ToolTip.delay: 500
                        onClicked: {
                            console.error("updating")
                            Backend.addTask({
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
                        visible: appinfo.isInstalled === 1
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            console.error("installing")
                            Backend.addTask({
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
                            const displayed = ["Version", "Pkgname", "Author", "Contributor", "Website", "Update", "Size"]
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
                            color: DPalette.text
                            onLinkActivated: Qt.openUrlExternally(link)
                            text: key + ": " + val
                        }
                    }
                }
            }
            Text {
                text: qsTr("Details")
                color: DPalette.text
                width: parent.width
                font.pointSize: root.iconsize / 8
                padding: 3
            }
            Text {
                text: root.infos.More
                color: DPalette.text
                width: parent.width
                wrapMode: Text.Wrap
            }
            Text {
                text: qsTr("Screenshots")
                color: DPalette.text
                font.pointSize: root.iconsize / 8
                padding: 3
            }

            ListView {
                Component.onCompleted: console.warn('column', height,
                                                    contentHeight)
                id: rootImageList
                model: JSON.parse(root.infos.img_urls || '[]')
                orientation: Qt.Horizontal
                clip: true
                width: parent.width
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
                                imgView.imgs = JSON.parse(
                                            root.infos.img_urls || '[]')
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
