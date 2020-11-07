// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// Audition a buffer, especially useful in AudioKit testing
/// - Parameter buffer: Buffer to play
public func audition(_ buffer: AVAudioPCMBuffer) {
    let engine = AudioEngine()
    let player = AudioPlayer()
    engine.output = player
    do {
        try engine.start()
    } catch let error as NSError {
        Log(error, type: .error)
        return
    }
    player.buffer = buffer
    player.play()
    sleep(buffer.frameCapacity / UInt32(buffer.format.sampleRate))
    engine.stop()
}
