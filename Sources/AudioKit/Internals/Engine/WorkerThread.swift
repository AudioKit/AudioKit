// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioUnit
import AVFoundation
import AudioToolbox

class WorkerThread: Thread {

    var run = true
    var prod: DispatchSemaphore
    var done: DispatchSemaphore
    var program: AudioProgram?
    var actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>!
    var timeStamp: UnsafePointer<AudioTimeStamp>!
    var frameCount: AUAudioFrameCount = 0
    var outputBufferList: UnsafeMutablePointer<AudioBufferList>?
    var runQueue = AtomicList(size: 0)
    var finishedInputs = FinishedInputs()

    init(prod: DispatchSemaphore, done: DispatchSemaphore) {
        self.prod = prod
        self.done = done
    }

    override func main() {

        var tbinfo = mach_timebase_info_data_t()
        mach_timebase_info(&tbinfo)

        let seconds = (Double(tbinfo.denom) / Double(tbinfo.numer)) * 1_000_000_000

        // Guessing what the parameters would be for 128 frame buffer at 44.1kHz
        let period = (128.0/44100.0) * seconds
        let constraint = 0.5 * period
        let comp = 0.5 * constraint

//        if !set_realtime(period: UInt32(period), computation: UInt32(comp), constraint: UInt32(constraint)) {
//            print("failed to set worker thread to realtime priority")
//        }

        while run {
            prod.wait()

            // Without this we get "worker has no program" on shutdown.
            if !run {
                return
            }

            // print("worker starting")

            if let program = program {
                program.run(actionFlags: actionFlags,
                            timeStamp: timeStamp,
                            frameCount: frameCount,
                            outputBufferList: outputBufferList!,
                            runQueue: runQueue,
                            finishedInputs: finishedInputs)
            } else {
                print("worker has no program!")
            }

            // print("worker done")
            done.signal()
        }
    }
}

/// Pool of worker threads.
///
/// The CLAP host example uses two semaphores. See https://github.com/free-audio/clap-host/blob/56e5d267ac24593788ac1874e3643f670112cdaf/host/plugin-host.hh#L229
class ThreadPool {

    var prod: DispatchSemaphore
    var done: DispatchSemaphore
    var workers: [WorkerThread] = []

    // Initial guess for the number of worker threads.
    let workerCount = 4 // XXX: disable worker threads for now

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
