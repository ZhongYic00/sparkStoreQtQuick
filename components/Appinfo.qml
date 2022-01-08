import QtQuick 2.0
import Process 1.0
import singleton.backend 1.0

Item {
    id: root

    property string pkg
    property string version
    property int isInstalled
    property int upToDate

    Worker {
        id: dpkgworker
    }
    onPkgChanged: updateStatus()
    Component.onCompleted: {
        Backend.taskAdded.connect(block)
        Backend.taskFinished.connect(updateStatus)
    }
    function block(pkgname) {
        if (pkgname === pkg)
            isInstalled = pkgname = -1
    }

    function updateStatus() {
        console.warn("Backend::updateStatus")
        upToDate = isInstalled = -1
        dpkgworker.start("dpkg", ["-s", pkg]).then((ec, stdout, stderr) => {
                                                       console.log(
                                                           'dpkg -s:',
                                                           stdout, stderr,
                                                           stderr.toString(
                                                               ).length)
                                                       isInstalled = stderr.toString(
                                                           ).length === 0
                                                       if (isInstalled) {
                                                           return {
                                                               "exec": "dpkg-query",
                                                               "args": ["--showformat=${Version}", "--show", pkg]
                                                           }
                                                       } else {
                                                           return {}
                                                       }
                                                   }).then(
                    (ec, stdout, stderr) => {
                        let localVer = stdout
                        console.log('localversion', localVer,
                                    'version', version)
                        return {
                            "exec": "dpkg",
                            "args": ["--compare-versions", localVer, "ge", version]
                        }
                    }).then((ec, stdout, stderr) => {
                                console.log("dpkg --compare-versions:", ec)
                                upToDate = (ec === 0)
                                return {}
                            }).run()
    }
}
