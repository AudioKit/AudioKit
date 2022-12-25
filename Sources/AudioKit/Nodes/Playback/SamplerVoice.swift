// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AVFoundation
import Atomics

struct SampleHolder {

    /// To keep the buffer alive.
    var pcmBuffer: AVAudioPCMBuffer

    /// Buffer to play.
    var bufferList: UnsafeMutableAudioBufferListPointer

    /// Are we done using this sample?
    var done: Bool = false
}

/// Voice struct used by the audio thread.
struct SamplerVoice {

    /// Is the voice in use?
    var inUse: Bool = false

    /// Sample we're playing.
    var sample: UnsafeMutablePointer<SampleHolder>?

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
        if inUse, let sample = self.sample {
            for frame in 0..<Int(frameCount) {

                // Our playhead must be in range.
                if playhead >= 0 && playhead < sampleFrames {

                    let data = sample.pointee.bufferList

                    for channel in 0 ..< data.count where channel < outputPtr.count {
                        outputPtr[channel][frame] += data[channel][playhead]
                    }

                }

                // Advance playhead by a frame.
                playhead += 1

                // Are we done playing?
                if playhead >= sampleFrames {
                    inUse = false
                    sample.pointee.done = true
                    self.sample = nil
                    break
                }
            }
        }
    }
}
