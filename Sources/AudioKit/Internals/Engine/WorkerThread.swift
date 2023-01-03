// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioUnit
import AVFoundation
import AudioToolbox

extension Int: DefaultInit {
    public init() { self = 0 }
}

class WorkerThread: Thread {

    var run = true
    var prod: DispatchSemaphore
    var done: DispatchSemaphore
    var program: AudioProgram?
    var actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>!
    var timeStamp: UnsafePointer<AudioTimeStamp>!
    var frameCount: AUAudioFrameCount = 0
    var outputBufferList: UnsafeMutablePointer<AudioBufferList>?

    /// Queue for submitting jobs to the worker.
    var inputQueue = RingBuffer<Int>()

    private var runQueue = WorkStealingQueue<Int>()
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

            while let index = inputQueue.pop() {
                runQueue.push(index)
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