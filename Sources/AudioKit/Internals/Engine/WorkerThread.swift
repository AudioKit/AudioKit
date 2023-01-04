// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioUnit
import AVFoundation
import AudioToolbox

extension Int: DefaultInit {
    public init() { self = 0 }
}

final class WorkerThread: Thread {

    /// Used to exit the worker thread.
    private var run = true

    /// Used to wake the worker.
    private var prod: DispatchSemaphore

    /// Used to wait for the worker to finish a cycle.
    private var done: DispatchSemaphore

    /// Information about rendering jobs.
    var program: AudioProgram?

    /// AU stuff.
    var actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>!

    /// AU stuff.
    var timeStamp: UnsafePointer<AudioTimeStamp>!

    /// Number of audio frames to render.
    var frameCount: AUAudioFrameCount = 0

    /// Our main output buffer.
    var outputBufferList: UnsafeMutablePointer<AudioBufferList>?

    /// Queue for submitting jobs to the worker.
    ///
    /// Once we implement stealing, we could simply have workers steal from a main queue.
    var inputQueue = RingBuffer<Int>()

    /// Index of this worker.
    var workerIndex: Int

    private var runQueues: Vec<WorkStealingQueue<Int>>

    init(index: Int,
         runQueues: Vec<WorkStealingQueue<Int>>,
         prod: DispatchSemaphore,
         done: DispatchSemaphore) {
        self.workerIndex = index
        self.runQueues = runQueues
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

        while true {
            prod.wait()

            if !run {
                break
            }

            while let index = inputQueue.pop() {
                runQueues[workerIndex].push(index)
            }

            // print("worker starting")

            if let program = program {
                program.run(actionFlags: actionFlags,
                            timeStamp: timeStamp,
                            frameCount: frameCount,
                            outputBufferList: outputBufferList!,
                            workerIndex: workerIndex,
                            runQueues: runQueues)
            } else {
                print("worker has no program!")
            }

            // print("worker done")
            done.signal()
        }
    }

    func exit() {
        run = false
        prod.signal()
    }
}
