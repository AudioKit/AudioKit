// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import Atomics
import CoreAudioTypes

class SynchronizedAudioBufferList {
    var abl: UnsafeMutablePointer<AudioBufferList>
    var atomic = ManagedAtomic<Int32>(0)

    init(_ abl: UnsafeMutablePointer<AudioBufferList>) {
        self.abl = abl
    }

    func endWriting() {
        atomic.wrappingIncrement(ordering: .acquiring)
    }

    func beginReading() {
        atomic.wrappingIncrement(ordering: .releasing)
    }
}
