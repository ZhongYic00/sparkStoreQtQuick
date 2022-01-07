import QtQuick 2.0
import Process 1.0

Item {
    id: root
    Process {
        id: process
        onFinished: next()
        property var steps: []
        property bool idle: true
        function next() {
            idle = false
            //            console.error("Worker::next", steps.length, isReadable())
            if (steps.length) {
                let step
                if (isReadable())
                    step = steps.shift()(exitCode(), readStdout(), readStderr())
                else
                    step = steps.shift()()
                //                console.error("step:", step, step.exec, step.args)
                if (step.exec) {
                    start(step.exec, step.args)
                } else {
                    idle = true
                }
            } else {
                idle = true
            }
        }
    }
    property var idle: () => process.idle
    property var start: (exec, args) => {
                            process.steps.push(() => {
                                                   return {
                                                       "exec": exec,
                                                       "args": args
                                                   }
                                               })
                            return root
                        }
    property var then: step => {
                           process.steps.push(step)
                           return root
                       }
    property var run: () => {
                          process.next()
                      }
}
