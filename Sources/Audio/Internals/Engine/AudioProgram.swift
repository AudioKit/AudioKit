// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Atomics
import AudioToolbox
import AudioUnit
import AVFoundation
import Foundation

/// Information about what the engine needs to run on the audio thread.
final class AudioProgram {
    /// List of information about AudioUnits we're executing.
    private let jobs: Vec<RenderJob>

    /// Nodes that we start processing first.
    let generatorIndices: UnsafeBufferPointer<Int>

    private var finished: Vec<ManagedAtomic<Int32>>

    private var remaining = ManagedAtomic<Int32>(0)

    init(jobs: [RenderJob], generatorIndices: [Int]) {
        self.jobs = Vec<RenderJob>(jobs)
        finished = Vec<ManagedAtomic<Int32>>(count: jobs.count, { _ in ManagedAtomic<Int32>(0) })

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
        for i in 0 ..< finished.count {
            finished[i].store(0, ordering: .relaxed)
        }
        remaining.store(Int32(jobs.count), ordering: .relaxed)
    }

    func run(actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
             timeStamp: UnsafePointer<AudioTimeStamp>,
             frameCount: AUAudioFrameCount,
             outputBufferList: UnsafeMutablePointer<AudioBufferList>,
             workerIndex: Int,
             runQueues: Vec<WorkStealingQueue>)
    {
        let exec = { index in
            let job = self.jobs[index]

            job.render(actionFlags: actionFlags,
                       timeStamp: timeStamp,
                       frameCount: frameCount,
                       outputBufferList: (index == self.jobs.count - 1) ? outputBufferList : nil)

            // Increment outputs.
            for outputIndex in job.outputIndices {
                if self.finished[outputIndex].wrappingIncrementThenLoad(ordering: .relaxed) == self.jobs[outputIndex].inputCount {
                    runQueues[workerIndex].push(outputIndex)
                }
            }

            self.remaining.wrappingDecrement(ordering: .relaxed)
        }

        while remaining.load(ordering: .relaxed) > 0 {
            // Pop an index off our queue.
            if let index = runQueues[workerIndex].pop() {
                exec(index)
            } else {
                // Try to steal an index. Start with the next worker and wrap around,
                // but don't steal from ourselves.
                for i in 0 ..< runQueues.count - 1 {
                    let victim = (workerIndex + i) % runQueues.count
                    if let index = runQueues[victim].steal() {
                        exec(index)
                        break
                    }
                }
            }
        }
    }
}

extension AudioProgram: AtomicReference {}
