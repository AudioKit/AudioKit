// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Atomics
import AVFoundation
import CoreAudioTypes
import Foundation

/// A buffer of audio with memory synchronization so we can
/// share it between threads.
public class SynchronizedAudioBufferList {
    /// Just to keep the buffer alive.
    private var pcmBuffer: AVAudioPCMBuffer

    /// Underlying audio buffer.
    var abl: UnsafeMutablePointer<AudioBufferList>

    /// For syncrhonization.
    private var atomic = ManagedAtomic<Int32>(0)

    public init(_ pcmBuffer: AVAudioPCMBuffer) {
        self.pcmBuffer = pcmBuffer
        abl = pcmBuffer.mutableAudioBufferList
    }

    /// Indicate that we're done writing to the buffer.
    func endWriting() {
        atomic.wrappingIncrement(ordering: .releasing)
    }

    /// Indicate that we're ready to read from the buffer.
    func beginReading() {
        atomic.wrappingIncrement(ordering: .acquiring)
    }
}
