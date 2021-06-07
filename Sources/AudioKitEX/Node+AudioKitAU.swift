// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKitEX
import AudioKit

/// Convenience for getting the AudioKitAU from a Node.
extension Node {

    /// Audio Unit for AudioKit
    public var au: AudioKitAU {
        guard let au = avAudioNode.auAudioUnit as? AudioKitAU else {
            fatalError("Wrong audio unit type.")
        }
        return au
    }
}

/// Create an AVAudioUnit for the given description
/// - Parameter componentDescription: Audio Component Description
func instantiate(componentDescription: AudioComponentDescription) -> AVAudioUnit {

    let semaphore = DispatchSemaphore(value: 0)
    var result: AVAudioUnit!

    AUAudioUnit.registerSubclass(AudioKitAU.self,
                                 as: componentDescription,
                                 name: "Local internal AU",
                                 version: .max)
    AVAudioUnit.instantiate(with: componentDescription) { avAudioUnit, _ in
        guard let au = avAudioUnit else {
            fatalError("Unable to instantiate AVAudioUnit")
        }
        result = au
        semaphore.signal()
    }

    _ = semaphore.wait(wallTimeout: .distantFuture)

    return result
}

/// Create a generator for the given unique identifier
/// - Parameter code: Unique four letter identifier
public func instantiate(generator code: String) -> AVAudioNode {
    instantiate(componentDescription: AudioComponentDescription(generator: code))
}

/// Create an instrument for the given unique identifier
/// - Parameter code: Unique four letter identifier
public func instantiate(instrument code: String) -> AVAudioNode {
    instantiate(componentDescription: AudioComponentDescription(instrument: code))
}

/// Create an effect for the given unique identifier
/// - Parameter code: Unique four letter identifier
public func instantiate(effect code: String) -> AVAudioNode {
    instantiate(componentDescription: AudioComponentDescription(effect: code))
}

/// Create a mixer for the given unique identifier
/// - Parameter code: Unique four letter identifier
public func instantiate(mixer code: String) -> AVAudioNode {
    instantiate(componentDescription: AudioComponentDescription(mixer: code))
}
