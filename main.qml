import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.15
import "./components"

Rectangle {
    id: window
    implicitWidth: 800
    implicitHeight: 600
    SystemPalette {
        id: dpalette
        colorGroup: SystemPalette.Active
        property color lightLively: Qt.lighter(highlight, 4 / 3)
        property color darkLively: Qt.lighter(highlight, 11 / 10)
        property color textWarning: Qt.darker(highlight, 10 / 9)
    }
    color: dpalette.base
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
    Component {
        id: settingsViewComponent
        SettingsView {
            id: settingsView
        }
    }

    Component {
        id: mainViewComponent
        ColumnLayout {
            TabBar {
                id: tabBar
                Layout.fillWidth: true
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
                Layout.fillHeight: true
                Layout.fillWidth: true
                category: tabBar.currentItem.category
            }
        }
    }
}
