import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.15
import "utils.js" as Utils
import singleton.dpalette 1.0

Column {
    id: root
    anchors.fill: parent
    objectName: "applistView"
    spacing: 20
    property var category: {
        "name": qsTr("network"),
        "url": "network",
        "icon": "net"
    }
    onCategoryChanged: refreshApplist()
    property bool enabled: true
    onEnabledChanged: console.error('enabled changed')

    ListModel {
        id: applist
    }
    Text {
        id: applistcount
        color: DPalette.text
        text: qsTr(applist.count + " apps")
    }
    Component {
        id: detailsViewComponent
        DetailsView {
            id: detailsView
        }
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
        cellWidth: itemwidth + cellmargin
        cellHeight: itemheight + cellmargin
        cacheBuffer: cellHeight * 2
        topMargin: cellmargin
        leftMargin: cellmargin
        clip: true
        flickDeceleration: 3000

        model: applist
        delegate: Rectangle {
            radius: smallRadius
            property int shadowradius: smallRadius
            color: DPalette.window
            width: view.itemwidth
            height: view.itemheight
            layer.enabled: true
            layer.effect: DropShadow {
                radius: shadowradius
                samples: 17
                color: DPalette.dark
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
                onTapped: {
                    var infos = obj
                    let limg_urls = JSON.parse(obj.img_urls || '[]')
                    console.error(limg_urls)
                    for (let i in limg_urls)
                        console.error(limg_urls[i])
                    stack.push(detailsViewComponent, {
                                   "infos": infos,
                                   "category": category.url
                               })
                }
            }

            Row {
                spacing: 10
                Image {
                    width: view.itemheight - 2 * 5
                    height: width
                    anchors.verticalCenter: parent.verticalCenter
                    source: obj.icons
                            || `https://d.store.deepinos.org.cn//store/${category.name}/${obj.Pkgname}/icon.png`
                    fillMode: Image.PreserveAspectFit
                }
                Column {
                    Text {
                        text: obj.Name
                        color: DPalette.text
                        width: view.textwidth
                        height: view.itemheight * 0.4
                        fontSizeMode: Text.VerticalFit
                        font.pointSize: height - 5
                        elide: Text.ElideRight
                    }

                    Text {
                        text: obj.More
                        color: DPalette.text
                        width: view.textwidth
                        height: view.itemheight * 0.6
                        elide: Text.ElideRight
                        wrapMode: Text.Wrap
                        font.weight: Font.Thin
                        ToolTip.text: obj.More
                        ToolTip.delay: 1000
                        ToolTip.visible: hoverHandler.hovered && root.enabled
                        HoverHandler {
                            id: hoverHandler
                        }
                    }
                }
            }
        }
    }
    Component.onCompleted: refreshApplist()
    function refreshApplist() {
        Utils.request(
                    "http://d.store.deepinos.org.cn/store/" + root.category.url + "/applist.json",
                    function (o) {
                        // translate response into object
                        console.error("applist.json get")
                        var d = JSON.parse(o.responseText)
                        const defaulticon = ""
                        applist.clear()
                        for (var i = 0; i < d.length && i < 100; i++) {
                            d[i].icons = d[i].icons || defaulticon
                            applist.append({
                                               "obj": d[i]
                                           })
                        }
                    })
    }
}
