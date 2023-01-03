// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

/// Pool of worker threads.
///
/// The CLAP host example uses two semaphores. See https://github.com/free-audio/clap-host/blob/56e5d267ac24593788ac1874e3643f670112cdaf/host/plugin-host.hh#L229
class ThreadPool {

    /// For waking up the threads.
    private var prod: DispatchSemaphore

    /// For waiting for the workers to finish.
    private var done: DispatchSemaphore

    /// Worker threads.
    var workers: [WorkerThread] = []

    /// Initial guess for the number of worker threads.
    let workerCount = 8 // XXX: Need to query for actual worker count.

    init() {

        prod = DispatchSemaphore(value: 0)
        done = DispatchSemaphore(value: 0)

        // Start workers.
        for _ in 0..<workerCount {
            let worker = WorkerThread(prod: prod, done: done)
            worker.start()
            workers.append(worker)
        }
    }

    /// Wake the threads.
    func start() {
        for _ in 0..<workerCount {
            prod.signal()
        }
    }

    /// Wait for threads to finish work.
    func wait() {
        for _ in 0..<workerCount {
            done.wait()
        }
    }

    deinit {

        // Shut down workers.
        for worker in workers {
            worker.run = false
            worker.prod.signal()
        }

    }
}
