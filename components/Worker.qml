import QtQuick 2.0
import Process 1.0

Item {
    id: root
    Process {
        id: process
        onFinished: next()
        property var steps: []
        property bool idle: true
        property var laststep
        function next() {
            idle = false
            //            console.error("Worker::next", steps.length, isReadable())
            if (steps.length) {
                let step = steps.shift()(exitCode(), readStdout() || "",
                                         readStderr() || "") || {}
                //                console.error("step:", "exec" in step, step.exec, step.args)
                if ("exec" in step && step.exec) {
                    start(step.exec, step.args)
                } else {
                    next()
                }
            } else {
                idle = true
                if (laststep)
                    laststep()
            }
        }
    }
    readonly property var idle: () => process.idle
    readonly property var start: (exec, args) => {
                                     process.steps.push(() => {
                                                            return {
                                                                "exec": exec,
                                                                "args": args
                                                            }
                                                        })
                                     return root
                                 }
    readonly property var then: step => {
                                    process.steps.push(step)
                                    return root
                                }
    readonly property var run: () => {
                                   process.next()
                               }
    readonly property var setLaststep: laststep => {
                                           process.laststep = laststep
                                       }
    readonly property var kill: () => {
                                    process.steps = []
                                    process.kill()
                                }
    readonly property var stop: () => {//                                    process.stop()
                                }
}
