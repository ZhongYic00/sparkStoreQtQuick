import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.1
import Process 1.0
import "utils.js" as Utils
import singleton.dpalette 1.0

Rectangle {
    id: root
    property string server: "https://d.store.deepinos.org.cn/"
    property string source
    visible: false
    color: DPalette.base
    anchors.fill: parent
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
        anchors.fill: parent

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            Text {
                text: qsTr("Server Settings")
                font.pointSize: 30
            }
            Pane {
                anchors.left: parent.left
                anchors.right: parent.right
                Column {
                    Text {
                        text: qsTr("Server Url")
                        font.pointSize: 20
                    }
                    ComboBox {
                        id: serverCombo
                        model: ["https://d.store.deepinos.org.cn/", "http://localhost:8080"]
                        onActivated: root.server = currentText
                        Component.onCompleted: currentIndex = find(root.server)
                    }
                    Text {
                        text: qsTr("Deb Source")
                        font.pointSize: 20
                    }
                    Row {
                        spacing: 5
                        Text {
                            text: "deb [by-hash=force]"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        TextField {
                            id: sourceInput
                            text: root.source
                            Component.onCompleted: {
                                Utils.request(
                                            "file:///etc/apt/sources.list.d/sparkstore.list",
                                            xhr => {
                                                root.source = xhr.responseText.replace(
                                                    "deb [by-hash=force]", "")
                                            })
                            }
                        }
                    }
                }
            }
        }
        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            spacing: 10
            Text {
                text: qsTr("Client Settings")
                font.pointSize: 30
            }
            Pane {
                anchors.left: parent.left
                anchors.right: parent.right
                RowLayout {
                    anchors.fill: parent
                    Text {
                        text: qsTr("Cache Autoclean")
                    }

                    Switch {
                        Layout.alignment: Qt.AlignRight
                    }
                }
            }
            Pane {
                anchors.left: parent.left
                anchors.right: parent.right
                RowLayout {
                    anchors.fill: parent

                    Text {
                        text: qsTr("Cache Position")
                    }
                    TextField {
                        enabled: false
                        text: qsTr("/tmp/sparkstore")
                        Layout.alignment: Qt.AlignRight
                    }
                }
            }
        }
        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            spacing: 10
            Text {
                text: qsTr("Deb Source Test")
                font.pointSize: 30
            }
            Pane {
                anchors.left: parent.left
                anchors.right: parent.right
                RowLayout {
                    anchors.fill: parent
                    Text {
                        text: qsTr("run apt update")
                    }
                    Text {
                        id: result
                        text: "[empty]"
                        maximumLineCount: 1
                        elide: Qt.ElideRight
                        ToolTip.text: text
                        HoverHandler {
                            onHoveredChanged: parent.ToolTip.visible = hovered
                        }
                    }

                    Switch {
                        id: swtch
                        Layout.alignment: Qt.AlignRight
                        onToggled: {
                            console.error("running")
                            process.start("pkexec", ["aptitude", "update"])
                            enabled = false
                        }
                    }
                }
                Process {
                    id: process
                    onFinished: {
                        console.error("ready")
                        result.text = readAll()
                        swtch.enabled = true
                    }
                }
            }
        }
    }

    Settings {
        property alias server: root.server
        property alias source: root.source
    }
}
