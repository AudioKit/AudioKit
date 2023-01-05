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
    var initialJobs = Vec<RenderJobIndex>(count: 1024, { _ in 0 })

    /// Number of initial jobs.
    var initialJobCount = 0

    /// Index of this worker.
    var workerIndex: Int

    private var runQueues: Vec<WorkStealingQueue<Int>>

    var workgroup: WorkGroup?

    var joinToken: WorkGroup.JoinToken?

    init(index: Int,
         runQueues: Vec<WorkStealingQueue<Int>>,
         prod: DispatchSemaphore,
         done: DispatchSemaphore,
         workgroup: WorkGroup? = nil) {
        self.workerIndex = index
        self.runQueues = runQueues
        self.prod = prod
        self.done = done
        self.workgroup = workgroup
    }

    /// Add a job for the worker.
    ///
    /// MUST call this before the worker is awakened.
    func add(job: RenderJobIndex) {
        initialJobs[initialJobCount] = job
        initialJobCount += 1
    }

    override func main() {

        if let workgroup = workgroup {
            var tbinfo = mach_timebase_info_data_t()
            mach_timebase_info(&tbinfo)

            let seconds = (Double(tbinfo.denom) / Double(tbinfo.numer)) * 1_000_000_000

            // Guessing what the parameters would be for 128 frame buffer at 44.1kHz
            let period = (128.0/44100.0) * seconds
            let constraint = 0.5 * period
            let comp = 0.5 * constraint

            if !set_realtime(period: UInt32(period), computation: UInt32(comp), constraint: UInt32(constraint)) {
                print("failed to set worker thread to realtime priority")
            }

            joinToken = workgroup.join()
        }

        while true {
            prod.wait()

            if !run {
                break
            }

            for i in 0..<initialJobCount {
                runQueues[workerIndex].push(initialJobs[i])
            }
            initialJobCount = 0

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

        if let joinToken = joinToken {
            workgroup?.leave(token: joinToken)
        }
    }

    func exit() {
        run = false
        prod.signal()
    }
}
