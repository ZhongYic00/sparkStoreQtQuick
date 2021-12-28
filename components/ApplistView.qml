import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.15

Column {
    id: root
    //    anchors.fill: parent
    spacing: 20
    property var category: {
        "name": qsTr("network"),
        "url": "network",
        "icon": "net"
    }
    onCategoryChanged: refreshApplist()

    ListModel {
        id: applist
    }
    Text {
        id: applistcount
        color: dpalette.text
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
                    stack.push(detailsViewComponent, {
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
        ScrollIndicator.vertical: ScrollIndicator {}
    }
    Component.onCompleted: refreshApplist()

    function refreshApplist() {
        request("http://d.store.deepinos.org.cn/store/" + root.category.url + "/applist.json",
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