// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
@preconcurrency import AVFAudio

public protocol Tap: Sendable {
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
        // Install via nonisolated static helper to avoid @MainActor closure tagging
        Self.installTapOnNode(avAudioNode, bus: bus, bufferSize: bufferSize, tap: tap)
    }

    nonisolated private static func installTapOnNode(_ node: AVAudioNode, bus: Int, bufferSize: UInt32, tap: Tap) {
        node.installTap(onBus: bus, bufferSize: bufferSize, format: nil) { buffer, time in
            nonisolated(unsafe) let buf = buffer
            Task {
                await tap.handleTap(buffer: buf, at: time)
            }
        }
    }

}
