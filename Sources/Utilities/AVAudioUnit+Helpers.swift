// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFAudio

/// Instantiate an AVAudioUnit.
public func instantiate(componentDescription: AudioComponentDescription) -> AVAudioUnit {
    var result: AVAudioUnit!
    let runLoop = RunLoop.current
    AVAudioUnit.instantiate(with: componentDescription) { avAudioUnit, _ in
        guard let au = avAudioUnit else { fatalError("Unable to instantiate AVAudioUnit") }
        runLoop.perform {
            result = au
        }
    }
    while result == nil {
        runLoop.run(until: .now + 0.01)
    }
    return result
}

/// Instantiate AUAudioUnit
public func instantiateAU(componentDescription: AudioComponentDescription) -> AUAudioUnit {
    var result: AUAudioUnit!
    let runLoop = RunLoop.current
    AUAudioUnit.instantiate(with: componentDescription) { auAudioUnit, _ in
        guard let au = auAudioUnit else { fatalError("Unable to instantiate AUAudioUnit") }
        runLoop.perform {
            result = au
        }
    }
    while result == nil {
        runLoop.run(until: .now + 0.01)
    }
    return result
}
