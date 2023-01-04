// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

/// Pool of worker threads.
///
/// The CLAP host example uses two semaphores. See https://github.com/free-audio/clap-host/blob/56e5d267ac24593788ac1874e3643f670112cdaf/host/plugin-host.hh#L229
final class ThreadPool {

    /// For waking up the threads.
    private var prod = DispatchSemaphore(value: 0)

    /// For waiting for the workers to finish.
    private var done = DispatchSemaphore(value: 0)

    /// Worker threads.
    var workers: Vec<WorkerThread>

    /// Initial guess for the number of worker threads.
    let workerCount = 4 // XXX: Need to query for actual worker count.

    init() {
        workers = .init(count: workerCount, { [prod, done] in WorkerThread(prod: prod, done: done) })
        for worker in workers {
            worker.start()
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
            worker.exit()
        }

    }
}
