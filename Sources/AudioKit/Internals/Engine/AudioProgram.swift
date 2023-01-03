// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioUnit
import AVFoundation
import AudioToolbox
import Atomics

/// Information about what the engine needs to run on the audio thread.
final class AudioProgram {

    /// List of information about AudioUnits we're executing.
    let infos: Vec<RenderJob>

    /// Nodes that we start processing first.
    let generatorIndices: UnsafeBufferPointer<Int>

    var finished = Vec<ManagedAtomic<Int32>>(count: 1024, { .init(0) })

    var remaining = ManagedAtomic<Int32>(0)

    init(infos: [RenderJob], generatorIndices: [Int]) {
        self.infos = Vec(infos)

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
        remaining.store(Int32(infos.count), ordering: .relaxed)
    }

    func run(actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
             timeStamp: UnsafePointer<AudioTimeStamp>,
             frameCount: AUAudioFrameCount,
             outputBufferList: UnsafeMutablePointer<AudioBufferList>,
             runQueue: WorkStealingQueue<Int>) {

        while remaining.load(ordering: .relaxed) > 0 {

            // Pop an index off our queue.
            if let index = runQueue.pop() {

                let info = infos[index]

                info.render(actionFlags: actionFlags,
                            timeStamp: timeStamp,
                            frameCount: frameCount,
                            outputBufferList: (index == infos.count-1) ? outputBufferList : nil)

                // Increment outputs.
                for outputIndex in infos[index].outputIndices {
                    if finished[outputIndex].wrappingIncrementThenLoad(ordering: .relaxed) == infos[outputIndex].inputCount {
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
