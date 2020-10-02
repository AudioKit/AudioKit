// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// Audition a buffer, especially useful in AudioKit testing
/// - Parameter buffer: Buffer to play
public func audition(_ buffer: AVAudioPCMBuffer) {
    let auditionEngine = AudioEngine()
    let auditionPlayer = AudioPlayer()
    auditionEngine.output = auditionPlayer
    try! auditionEngine.start()
    auditionPlayer.scheduleBuffer(buffer, at: nil)
    auditionPlayer.play()
    sleep(buffer.frameCapacity / 44100)
    auditionEngine.stop()
}
