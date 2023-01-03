// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import Atomics
import CoreAudioTypes
import AVFoundation

public class SynchronizedAudioBufferList {

    /// Just to keep the buffer alive.
    private var pcmBuffer: AVAudioPCMBuffer

    var abl: UnsafeMutablePointer<AudioBufferList>
    private var atomic = ManagedAtomic<Int32>(0)

    public init(_ pcmBuffer: AVAudioPCMBuffer) {
        self.pcmBuffer = pcmBuffer
        self.abl = pcmBuffer.mutableAudioBufferList
    }

    func endWriting() {
        atomic.wrappingIncrement(ordering: .releasing)
    }

    func beginReading() {
        atomic.wrappingIncrement(ordering: .acquiring)
    }
}
