// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

extension AVAudioPCMBuffer {

    /// Audition the buffer. Especially useful in AudioKit testing
    public func audition() {
        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        do {
            try engine.start()
        } catch let error as NSError {
            Log(error, type: .error)
            return
        }
        player.buffer = self
        player.play()
        sleep(self.frameCapacity / UInt32(self.format.sampleRate))
        engine.stop()
    }
}
