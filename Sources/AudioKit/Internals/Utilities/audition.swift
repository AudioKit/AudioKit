// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public func audition(_ buffer: AVAudioPCMBuffer) {
    let auditionEngine = AudioEngine()
    let auditionPlayer = AudioPlayer()
    auditionEngine.output = auditionPlayer
    try! auditionEngine.start()
    auditionPlayer.scheduleBuffer(buffer, at: nil)
    auditionPlayer.play()
    print("audition samples", buffer.frameCapacity)
    sleep(buffer.frameCapacity / 44100)
    auditionEngine.stop()
}
