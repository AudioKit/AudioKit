// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFAudio

func instantiate(componentDescription: AudioComponentDescription) -> AVAudioUnit {
    let (avAudioUnit, error) = instantiate(description: componentDescription)
    guard let avAudioUnit else {
        fatalError("Unable to instantiate AVAudioUnit: \(error?.localizedDescription ?? "no error")")
    }
    return avAudioUnit
}

func instantiate(description: AudioComponentDescription) -> (AVAudioUnit?, Error?) {
    let semaphore = DispatchSemaphore(value: 0)
    #if Swift6
    // This is safe as it is synchronised by the semaphore
    nonisolated(unsafe) var result: AVAudioUnit?
    nonisolated(unsafe) var resultError: Error?
    #else
    var result: AVAudioUnit?
    var resultError: Error?
    #endif
    AVAudioUnit.instantiate(with: description) { avAudioUnit, error in
        result = avAudioUnit
        resultError = error
        semaphore.signal()
    }
    _ = semaphore.wait(wallTimeout: .distantFuture)
    return (result, resultError)
}
