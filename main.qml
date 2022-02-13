import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.15
import "./components"
import "qrc:/dtk"
import singleton.dpalette 1.0

Rectangle {
    id: window
    implicitWidth: 800
    implicitHeight: 600

    color: DPalette.base
    StackView {
        id: stack
        initialItem: mainViewComponent
        anchors.fill: parent
    }
    Connections {
        target: SettingsAction
        function onTriggered() {
            stack.push(settingsViewComponent)
        }
    }
    Connections {
        target: TasklistAction
        function onTriggered() {
            stack.push(tasklistViewComponent)
        }
    }

    Component {
        id: settingsViewComponent
        SettingsView {
            id: settingsView
        }
    }

    Component {
        id: tasklistViewComponent
        Tasklist {}
    }

    Component {
        id: mainViewComponent
        Item {
            id: mainView
            objectName: "mainViewComponent"
            TabBar {
                id: tabBar
                anchors.left: parent.left
                anchors.right: parent.right
                implicitWidth: window.width
                font.pointSize: 14
                isScrollEnabled: false
                Repeater {
                    model: ["network", "chat", "music", "video", "image_graphics", "games", "office", "reading", "tools"]
                    TabButton {
                        text: modelData
                        property var category: {
                            "name": modelData,
                            "url": modelData,
                            "icon": modelData
                        }
                    }
                }
            }
            ApplistView {
                id: applistView
                width: parent.width
                anchors.top: tabBar.bottom
                anchors.bottom: parent.bottom
                category: tabBar.currentItem.category
                enabled: stack.currentItem == mainView
            }
        }
    }
}
