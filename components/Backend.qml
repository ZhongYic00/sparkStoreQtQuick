pragma Singleton

import QtQuick 2.0
import Process 1.0

Item {
    id: root

    readonly property string defaulticon: ""

    readonly property var tasklist: model
    readonly property var addTask: function (task) {
        console.warn("addtask", task.type, task.pkgname)
        model.append(task)
        taskworker.pickNext()
        taskAdded(task.pkgname)
    }
    readonly property var isInTasklist: pkgname => {
        for (var i = 0; i < model.count; i++) {
            let item = model.get(i)
            if (item.pkgname === pkgname)
            return true
        }
        return false
    }

    readonly property var taskStat: function (idx) {
        if (idx === 0 && !taskworker.idle())
            return "running"
        else
            return "pending"
    }
    readonly property var pause: function (idx) {
        if (idx === 0)
            taskworker.stop()
    }
    readonly property var stop: function (idx) {
        if (idx === 0)
            taskworker.kill()
        else
            model.remove(idx)
    }

    signal taskFinished(var task, int exitcode)
    signal taskAdded(string pkgname)

    ListModel {
        id: model
        property var shift: () => {
            if (count == 0)
            return null
            let rt = get(0)
            remove(0)
            return rt
        }

        ListElement {
            type: "test"
        }
        ListElement {
            type: "test"
        }
        ListElement {
            type: "test"
        }
    }

    Worker {
        id: taskworker
        Component.onCompleted: setLaststep(() => {
                                               taskFinished(model[0], 0)
                                               model.shift()
                                               pickNext()
                                           })
        property var pickNext: function pickNext() {
            console.warn("pickNext", model, taskworker.idle())
            if (model.count && taskworker.idle()) {
                let task = model.get(0)
                try {
                    runTask(task)
                } catch (e) {
                    console.error("runTask error:", e)
                }
            }
        }
        function runTask(task) {
            console.warn("runTask")
            if (task.type === "install")
                install(task)
            else if (task.type === "update")
                update(task)
            else if (task.type === "uninstall")
                uninstall(task)
            else
                test(task)
        }
        function test(task) {
            console.warn("Backend::test", task.type)
            taskworker.start("sleep", ["3"]).then(() => {
                                                      console.warn(
                                                          "exit Backend::test")
                                                  }).run()
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
                                    return {}
                                }).run()
        }
        function uninstall(task) {
            taskworker.start("pkexec",
                             ["apt", "purge", "-y", task.pkgname]).then(
                        (ec, stdout, stderr) => {
                            console.warn("uninstall finished", ec,
                                         stdout, stderr)
                            return {}
                        }).run()
        }
    }
}
