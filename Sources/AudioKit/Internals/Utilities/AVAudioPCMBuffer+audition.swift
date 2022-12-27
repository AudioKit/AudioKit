// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public extension AVAudioPCMBuffer {
    /// Audition the buffer. Especially useful in AudioKit testing
    func audition() {
        let engine = AudioEngine()
        let sampler = Sampler()
        engine.output = sampler
        do {
            try engine.start()
        } catch let error as NSError {
            Log(error, type: .error)
            return
        }
        sampler.play(self)
        sleep(frameCapacity / UInt32(format.sampleRate))
        engine.stop()
    }
}
