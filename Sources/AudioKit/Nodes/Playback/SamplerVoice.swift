// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AVFoundation
import Atomics

/// Voice struct used by the audio thread.
struct SamplerVoice {

    /// Is the voice in use?
    var inUse: ManagedAtomic<Bool> = .init(false)

    /// Hopefully we can keep the PCMBuffer alive from the audio thread while
    /// still being rt-safe.
    var pcmBuffer: AVAudioPCMBuffer?

    /// Sample data we're playing. Use AudioBufferList directly because we AVAudioPCMBuffer isn't rt-safe.
    ///
    /// Note that we shouldn't actually be mutating this, but the type is more convenient.
    var data: UnsafeMutableAudioBufferListPointer?

    /// Number of frames in the buffer for sake of convenience.
    var sampleFrames: Int = 0

    /// Current frame we're playing. Could be negative to indicate number of frames to wait before playing.
    var playhead: Int = 0

    // Envelope state, etc. would go here.
}

extension SamplerVoice {
    mutating func render(to outputPtr: UnsafeMutableAudioBufferListPointer,
                         frameCount: AVAudioFrameCount) {
        if inUse.load(ordering: .relaxed), let data = self.data {
            for frame in 0..<Int(frameCount) {

                // Our playhead must be in range.
                if playhead >= 0 && playhead < sampleFrames {

                    for channel in 0 ..< data.count where channel < outputPtr.count {

                        let outP = outputPtr[channel].mData!.bindMemory(to: Float.self,
                                                                        capacity: Int(frameCount))

                        let inP = data[channel].mData!.bindMemory(to: Float.self,
                                                                  capacity: Int(self.sampleFrames))

                        outP[frame] += inP[playhead]
                    }

                }

                // Advance playhead by a frame.
                playhead += 1

                // Are we done playing?
                if playhead >= sampleFrames {
                    inUse.store(false, ordering: .relaxed)
                    break
                }
            }
        }
    }
}
