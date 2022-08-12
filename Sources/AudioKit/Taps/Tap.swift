// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AVFAudio

public protocol Tap {
    func handleTap(buffer: AVAudioPCMBuffer, at time: AVAudioTime) async
}

extension Node {

    public func install(tap: Tap, bufferSize: UInt32) {
        // Should we throw an exception instead?
        guard avAudioNode.engine != nil else {
            Log("The tapped node isn't attached to the engine")
            return
        }

        let bus = 0 // Should be a ctor argument?
        avAudioNode.installTap(onBus: bus,
                                     bufferSize: bufferSize,
                                     format: nil,
                                     block: { (buffer, time) in
            Task {
                await tap.handleTap(buffer: buffer, at: time)
            }
        })
    }

}
