pragma Singleton

import QtQuick 2.0
import Process 1.0

Item {
    id: root

    property var tasklist: []
    property var addTask: function (task) {
        tasklist.push(task)
        taskworker.pickNext()
        taskAdded(task.pkgname)
    }

    signal taskFinished(var task, int exitcode)
    signal taskAdded(string pkgname)

    Worker {
        id: taskworker
        function pickNext() {
            console.warn("pickNext", tasklist)
            if (tasklist.length && taskworker.idle()) {
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
            console.warn("runTask"
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
            console.warn("install", filename, url)
            taskworker.start("/usr/bin/curl", ["-o", filename, url]).then(
                        (ec, stdout, stderr) => {
                            console.warn("download finished", ec,
                                         stdout, stderr)
                            if (ec === 0)
                            return {
                                "exec": "pkexec",
                                "args": ["ssinstall", filename]
                            }
                            else
                            return {}
                        }).then((ec, stdout, stderr) => {
                                    console.warn("install finished", ec,
                                                 stdout, stderr)
                                    root.taskFinished(task, ec)
                                    return {}
                                }).run()
        }
        function uninstall(task) {
            taskworker.start("pkexec",
                             ["apt", "purge", "-y", task.pkgname]).then(
                        (ec, stdout, stderr) => {
                            console.warn("uninstall finished", ec,
                                         stdout, stderr)
                            root.taskFinished(task, ec)
                            return {}
                        }).run()
        }
    }
}
