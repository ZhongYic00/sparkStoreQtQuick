import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.15
import Qt.labs.settings 1.1

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
        initialItem: mainView
        anchors.fill: parent
    }
    Connections {
        target: SettingsAction
        function onTriggered() {
            stack.push(settingsView)
        }
    }

    Item {
        id: detailView
        property string icons
        property string name
        property string description
        property int iconsize: 150
        property var info
        property var imgs
        property int imgheight: 250
        visible: false

        ScrollView {
            anchors.fill: parent
            contentWidth: parent.width
            Row {
                RoundButton {
                    icon.name: "back"
                    icon.width: 30
                    icon.height: 30
                    onClicked: stack.pop()
                }
                Column {
                    Text {
                        text: detailView.name
                        color: dpalette.text
                        font.pointSize: detailView.iconsize / 4
                        font.family: "Noto Serif"
                    }

                    Row {
                        spacing: 10
                        Column {
                            spacing: 10
                            Image {
                                height: detailView.iconsize
                                width: height
                                source: detailView.icons
                                anchors.horizontalCenter: parent.horizontalCenter
                                fillMode: Image.PreserveAspectFit
                            }
                            Button {
                                text: qsTr("install")
                                width: detailView.iconsize
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                        Column {
                            Repeater {
                                model: detailView.info
                                Text {
                                    color: dpalette.text
                                    onLinkActivated: Qt.openUrlExternally(link)
                                    text: modelData.key + ": " + modelData.val
                                }
                            }
                        }
                    }
                    Text {
                        text: qsTr("Details")
                        color: dpalette.text
                        width: parent.width
                        font.pointSize: detailView.iconsize / 8
                        padding: 3
                    }
                    Text {
                        text: detailView.description
                        color: dpalette.text
                        width: parent.width
                        wrapMode: Text.Wrap
                    }
                    Text {
                        text: qsTr("Screenshots")
                        color: dpalette.text
                        font.pointSize: detailView.iconsize / 8
                        padding: 3
                    }

                    ListModel {
                        id: imgsmodel
                    }

                    ListView {
                        id: detailViewImageList
                        model: detailView.imgs
                        orientation: Qt.Horizontal
                        clip: true
                        width: detailView.width
                        height: detailView.imgheight
                        boundsBehavior: Flickable.DragOverBounds
                        spacing: 10
                        delegate: Row {
                            Image {
                                source: modelData
                                height: detailView.imgheight
                                fillMode: Image.PreserveAspectFit
                                ToolTip.text: modelData
                                TapHandler {
                                    onTapped: {
                                        imgView.imgs = detailView.imgs
                                        imgView.idx = index
                                        imgView.showMaximized()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    Window {
        id: imgView
        property var imgs: ['']
        property int idx
        visible: false
        modality: Qt.ApplicationModal
        flags: Qt.CoverWindow | Qt.CustomizeWindowHint
               | Qt.NoDropShadowWindowHint | Qt.WindowStaysOnTopHint
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
    Column {
        id: mainView
        //        anchors.fill: parent
        spacing: 20
        ListModel {
            id: applist
        }

        Text {
            id: applistcount
            color: dpalette.text
            text: qsTr(applist.count + " apps")
        }
        GridView {
            id: view
            implicitWidth: parent.width
            x: (parent.width % cellWidth) / 2
            implicitHeight: parent.height - applistcount.height
            property int textheight: 20
            property int itemheight: 100
            property int textwidth: 2 * itemheight
            property int itemwidth: itemheight + textwidth
            property int cellmargin: bigRadius
            property string defaulticon: ""
            cellWidth: itemwidth + cellmargin
            cellHeight: itemheight + cellmargin
            cacheBuffer: cellHeight * 2
            leftMargin: cellmargin
            clip: true
            model: applist
            delegate: Rectangle {
                radius: smallRadius
                property int shadowradius: smallRadius
                color: dpalette.window
                width: view.itemwidth
                height: view.itemheight
                layer.enabled: true
                layer.effect: DropShadow {
                    radius: shadowradius
                    samples: 17
                    color: dpalette.dark
                    transparentBorder: true
                }
                HoverHandler {
                    onHoveredChanged: parent.shadowradius = hovered ? bigRadius : smallRadius
                }
                Behavior on shadowradius {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.OutExpo
                    }
                }
                TapHandler {
                    onTapped: function () {
                        var infos = {
                            "Package": Pkgname,
                            "Version": Version,
                            "Author": Author,
                            "Website": '<a href=\"' + Website + '\">' + Website + '</a>',
                            "Contributor": Contributor,
                            "Size": Size
                        }
                        let info = []
                        for (let i in infos) {
                            info.push({
                                          "key": i,
                                          "val": infos[i]
                                      })
                        }
                        let limg_urls = JSON.parse(img_urls || '[]')
                        console.error(limg_urls)
                        for (let i in limg_urls)
                            console.error(limg_urls[i])
                        stack.push(detailView, {
                                       "icons": icons,
                                       "name": Name,
                                       "description": More,
                                       "info": info,
                                       "imgs": limg_urls
                                   })
                    }
                }

                Row {
                    spacing: 10
                    Image {
                        width: view.itemheight - 2 * 5
                        height: width
                        anchors.verticalCenter: parent.verticalCenter
                        source: icons || view.defaulticon
                        fillMode: Image.PreserveAspectFit
                    }
                    Column {
                        Text {
                            text: Name
                            color: dpalette.text
                            width: view.textwidth
                            height: view.itemheight * 0.4
                            fontSizeMode: Text.VerticalFit
                            font.pointSize: height - 5
                            elide: Text.ElideRight
                        }

                        Text {
                            text: More
                            color: dpalette.text
                            width: view.textwidth
                            height: view.itemheight * 0.6
                            elide: Text.ElideRight
                            wrapMode: Text.Wrap
                            font.weight: Font.Thin
                            ToolTip.text: More
                            ToolTip.delay: 1000
                            HoverHandler {
                                onHoveredChanged: parent.ToolTip.visible = hovered
                            }
                        }
                    }
                }
            }
        }
    }
    Component.onCompleted: refreshApplist()
    Rectangle {
        id: settingsView
        property string server: "https://d.store.deepinos.org.cn/"
        property string source
        visible: false
        color: dpalette.base
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
            padding: 20

            Column {
                Text {
                    text: qsTr("Server Settings")
                    font.pointSize: 30
                }
                Pane {
                    width: settingsView.width - 2 * 20
                    ColumnLayout {
                        Text {
                            text: qsTr("Server Url")
                            font.pointSize: 20
                        }
                        ComboBox {
                            id: settingsViewServerCombo
                            model: ["https://d.store.deepinos.org.cn/", "http://localhost:8080"]
                            onActivated: settingsView.server = currentText
                            Component.onCompleted: currentIndex = find(
                                                       settingsView.server)
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
                                id: settingsViewSourceInput
                                text: settingsView.source
                                Component.onCompleted: {
                                    request("file:///etc/apt/sources.list.d/sparkstore.list",
                                            xhr => {
                                                settingsView.source = xhr.responseText.replace(
                                                    "deb [by-hash=force]", "")
                                            })
                                }
                            }
                        }
                    }
                }
            }
            Column {
                Text {
                    text: qsTr("Client Settings")
                    font.pointSize: 30
                }
                Pane {
                    width: settingsView.width - 2 * 20
                    ColumnLayout {
                        Row {
                            width: settingsView.width
                            Text {
                                text: qsTr("Cache Autoclean")
                            }
                            Switch {//                                anchors.right: parent.right
                            }
                        }
                        Row {
                            width: settingsView.width
                            Text {
                                text: qsTr("Cache Position")
                            }
                            Text {
                                //                                anchors.right: parent.right
                                text: qsTr("/tmp/sparkstore")
                            }
                        }
                    }
                }
            }
        }

        Settings {
            property alias server: settingsView.server
            property alias source: settingsView.source
        }
    }

    function refreshApplist() {
        request("http://d.store.deepinos.org.cn/store/network/applist.json",
                function (o) {
                    // translate response into object
                    console.error("applist.json get")
                    var d = JSON.parse(o.responseText)
                    applist.clear()
                    for (var i = 0; i < d.length && i < 100; i++) {
                        applist.append(d[i])
                    }
                })
    }

    // this function is included locally, but you can also include separately via a header definition
    function request(url, callback) {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = (function (myxhr) {
            return function () {
                if (myxhr.readyState == 4)
                    callback(myxhr)
            }
        })(xhr)
        xhr.open('GET', url, true)
        xhr.send('')
    }
}
