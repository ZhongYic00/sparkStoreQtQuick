import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import singleton.backend 1.0
import singleton.dpalette 1.0

Item {
    id: root
    //    anchors.fill: parent
    RoundButton {
        icon.name: "dialog-close"
        icon.width: 40
        icon.height: 40
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 5
        radius: 20
        onClicked: stack.pop()
    }
    Column {

        Text {
            text: qsTr("Tasks")
            font.pointSize: 40
        }
        Text {
            text: Backend.tasklist.count + qsTr("remaining")
        }

        ListView {
            id: view
            model: Backend.tasklist
            clip: true
            implicitHeight: root.height - 80
            implicitWidth: root.width
            leftMargin: 20
            rightMargin: 20
            readonly property int itemHeight: 40
            readonly property int itemWidth: width - 2 * leftMargin
            delegate: Rectangle {
                height: view.itemHeight
                width: view.itemWidth
                radius: smallRadius
                color: index % 2 ? DPalette.base : DPalette.itemBackground
                Row {
                    id: content
                    anchors.fill: parent
                    anchors.leftMargin: 5
                    anchors.rightMargin: 10
                    Component.onCompleted: console.error("item", model.pkgname
                                                         || "null", width,
                                                         content.width)
                    Row {
                        height: parent.height
                        Image {
                            source: model.icons || Backend.defaulticon
                            width: height
                            height: view.itemHeight - 10
                            fillMode: Image.PreserveAspectFit
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            width: parent.parent.width * 0.35 - view.itemHeight
                            text: model.name || qsTr("Unknown Application")
                            anchors.verticalCenter: parent.verticalCenter
                            elide: Text.ElideRight
                            Component.onCompleted: console.error(width)
                        }
                    }

                    Text {
                        text: `${model.type} <i>` + (model.pkgname || qsTr(
                                                         "Unknown Package")) + "</i>"
                        width: parent.width * 0.25
                        elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    RowLayout {
                        width: content.width * 0.4
                        height: parent.height
                        spacing: 0
                        Row {
                            Text {
                                text: Backend.taskStat(index)
                                Layout.alignment: Qt.AlignRight
                            }
                            BusyIndicator {
                                height: view.itemHeight - 10
                                width: height
                                dots: 3
                                visible: Backend.taskStat(index) === "running"
                            }
                            Layout.alignment: Qt.AlignRight
                        }
                        Row {
                            objectName: "buttonGroup"
                            spacing: 10
                            RoundButton {
                                icon.name: "tiny-pause"
                                onClicked: Backend.pause(index)
                                enabled: false
                            }
                            RoundButton {
                                icon.name: "cancel"
                                onClicked: Backend.stop(index)
                            }
                            Layout.alignment: Qt.AlignRight
                        }
                    }
                }
            }
        }
    }
}
