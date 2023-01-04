// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioUnit
import AVFoundation
import AudioToolbox
import Atomics

/// Information about what the engine needs to run on the audio thread.
final class AudioProgram {

    /// List of information about AudioUnits we're executing.
    private let jobs: Vec<RenderJob>

    /// Nodes that we start processing first.
    let generatorIndices: UnsafeBufferPointer<Int>

    private var finished: Vec<ManagedAtomic<Int32>>

    private var remaining = ManagedAtomic<Int32>(0)

    init(jobs: [RenderJob], generatorIndices: [Int]) {
        self.jobs = Vec(jobs)
        self.finished = Vec<ManagedAtomic<Int32>>(count: jobs.count, { _ in .init(0) })

        let ptr = UnsafeMutableBufferPointer<Int>.allocate(capacity: generatorIndices.count)
        for i in generatorIndices.indices {
            ptr[i] = generatorIndices[i]
        }
        self.generatorIndices = .init(ptr)
    }

    deinit {
        generatorIndices.deallocate()
    }

    func reset() {
        for i in 0..<finished.count {
            finished[i].store(0, ordering: .relaxed)
        }
        remaining.store(Int32(jobs.count), ordering: .relaxed)
    }

    func run(actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
             timeStamp: UnsafePointer<AudioTimeStamp>,
             frameCount: AUAudioFrameCount,
             outputBufferList: UnsafeMutablePointer<AudioBufferList>,
             runQueue: WorkStealingQueue<Int>) {

        while remaining.load(ordering: .relaxed) > 0 {

            // Pop an index off our queue.
            if let index = runQueue.pop() {

                let info = jobs[index]

                info.render(actionFlags: actionFlags,
                            timeStamp: timeStamp,
                            frameCount: frameCount,
                            outputBufferList: (index == jobs.count-1) ? outputBufferList : nil)

                // Increment outputs.
                for outputIndex in jobs[index].outputIndices {
                    if finished[outputIndex].wrappingIncrementThenLoad(ordering: .relaxed) == jobs[outputIndex].inputCount {
                        runQueue.push(outputIndex)
                    }
                }

                remaining.wrappingDecrement(ordering: .relaxed)
            }
        }
    }
}

extension AudioProgram: AtomicReference {

}
