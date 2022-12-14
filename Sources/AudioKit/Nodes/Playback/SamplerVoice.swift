// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AVFoundation
import Atomics

/// Voice struct used by the audio thread.
struct SamplerVoice {

    /// Three usage states allow us to allocate voices on multiple threads.
    ///
    /// Typically the main thread (immediate playback) and the render thread (midi).
    enum State: Int, AtomicValue {

        /// Not in use.
        case free

        /// Being set up for rendering.
        case allocated

        /// Available for rendering.
        case active

        /// Finished rendering.
        case done
    }

    /// Is the voice in use?
    var state: ManagedAtomic<State> = .init(.free)

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

extension AudioBuffer {
    subscript(index:Int) -> Float {
        get {
            return mData!.bindMemory(to: Float.self, capacity: Int(mDataByteSize) / MemoryLayout<Float>.size)[index]
        }
        set(newElm) {
            mData!.bindMemory(to: Float.self, capacity: Int(mDataByteSize) / MemoryLayout<Float>.size)[index] = newElm
        }
    }
}

extension SamplerVoice {
    mutating func render(to outputPtr: UnsafeMutableAudioBufferListPointer,
                         frameCount: AVAudioFrameCount) {
        if state.load(ordering: .relaxed) == .active, let data = self.data {
            for frame in 0..<Int(frameCount) {

                // Our playhead must be in range.
                if playhead >= 0 && playhead < sampleFrames {

                    for channel in 0 ..< data.count where channel < outputPtr.count {
                        outputPtr[channel][frame] += data[channel][playhead]
                    }

                }

                // Advance playhead by a frame.
                playhead += 1

                // Are we done playing?
                if playhead >= sampleFrames {
                    state.store(.done, ordering: .relaxed)
                    break
                }
            }
        }
    }
}
