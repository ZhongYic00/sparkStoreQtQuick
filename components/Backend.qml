import QtQuick 2.0
import Process 1.0

Item {
    id: root
    property string pkg
    property string version
    property bool isInstalled
    property bool upToDate
    property var tasklist: []
    property var addTask: function (task) {
        tasklist.push(task)
        testworker.pickNext()
    }

    signal taskFinished(var task, int exitcode)

    Process {
        id: worker0
        onFinished: {
            let stderr = readStderr()
            isInstalled = stderr.toString().length === 0
            //            console.error(stderr, stderr.toString().length)
        }
    }
    Process {
        id: worker1
    }

    Worker {
        id: testworker
        function pickNext() {
            console.error("pickNext", tasklist)
            if (tasklist.length && testworker.idle()) {
                let task = tasklist[0]
                try {
                    runTask(task)
                } catch (e) {
                    console.error("runTask error:", e)
                }
                tasklist.pop()
            }
        }
        function runTask(task) {
            console.error("runTask"
                          /*task.type, task.pkgname, task.icons,
                          task.filename*/ )
            if (task.type === "install")
                install(task)
            else if (task.type === "update")
                update(task)
            else if (task.type === "uninstall")
                uninstall(task)
        }
        function update(task) {
            install(task)
        }
        function install(task) {
            let url = `https://d.store.deepinos.org.cn/store/${task.category}/${task.pkgname}/${task.filename}`
            let filename = "/tmp/spark-download-" + task.filename
            console.error("install", filename, url)
            testworker.start("/usr/bin/curl", ["-o", filename, url]).then(
                        (ec, stdout, stderr) => {
                            console.error("download finished", ec,
                                          stdout, stderr)
                            if (ec === 0)
                            return {
                                "exec": "pkexec",
                                "args": ["ssinstall", filename]
                            }
                            else
                            return {}
                        }).then((ec, stdout, stderr) => {
                                    console.error("install finished", ec,
                                                  stdout, stderr)
                                    root.taskFinished(task, ec)
                                    return {}
                                }).run()
        }
        function uninstall(task) {
            testworker.start("pkexec",
                             ["apt", "purge", "-y", task.pkgname]).then(
                        (ec, stdout, stderr) => {
                            console.error("uninstall finished", ec,
                                          stdout, stderr)
                            root.taskFinished(task, ec)
                            return {}
                        }).run()
        }
    }

    Process {
        id: dlworker
    }
    Process {
        id: insworker
    }

    onTasklistChanged: {
        console.error("onTasklistChanged", dlworker.Running)
    }

    onPkgChanged: updateStatus()
    onTaskFinished: updateStatus()
    function updateStatus() {
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
                          'result', ec === 0)
            upToDate = (ec === 0)
        }
    }
}
