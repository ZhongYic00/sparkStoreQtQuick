import QtQuick 2.0
import Process 1.0

Item {
    id: root
    property string pkg
    property string version
    property bool isInstalled
    property bool upToDate
    Process {
        id: worker0
        onFinished: {
            let stderr = readStderr()
            isInstalled = stderr.toString().length == 0
            //            console.error(stderr, stderr.toString().length)
        }
    }
    Process {
        id: worker1
    }

    onPkgChanged: {
        worker0.start("dpkg", ["-s", pkg])
        worker1.start("dpkg-query", ["--showformat=${Version}", "--show", pkg])
        console.error("here")
        worker0.wait()
        worker1.wait()
        console.error("wait end")
        if (isInstalled) {
            let localVer = worker1.readStdout().toString()
            worker1.start("dpkg",
                          ["--compare-versions", localVer, "ge", version])
            worker1.wait()
            let ec = worker1.exitCode()
            console.error('localversion', localVer, 'version', version,
                          'result', ec == 0)
            upToDate = (ec == 0)
        }
    }
}
