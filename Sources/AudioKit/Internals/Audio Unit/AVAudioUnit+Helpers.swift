// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFAudio

/// Instantiate an AVAudioUnit.
func instantiate(componentDescription: AudioComponentDescription) -> AVAudioUnit {
    let semaphore = DispatchSemaphore(value: 0)
    var result: AVAudioUnit!
    AVAudioUnit.instantiate(with: componentDescription) { avAudioUnit, _ in
        guard let au = avAudioUnit else { fatalError("Unable to instantiate AVAudioUnit") }
        result = au
        semaphore.signal()
    }
    _ = semaphore.wait(wallTimeout: .distantFuture)
    return result
}

/// Sometimes we don't want an AVAudioUnit.
func instantiateAU(componentDescription: AudioComponentDescription) -> AUAudioUnit {
    let semaphore = DispatchSemaphore(value: 0)
    var result: AUAudioUnit!
    AUAudioUnit.instantiate(with: componentDescription) { auAudioUnit, _ in
        guard let au = auAudioUnit else { fatalError("Unable to instantiate AUAudioUnit") }
        result = au
        semaphore.signal()
    }
    _ = semaphore.wait(wallTimeout: .distantFuture)
    return result
}
