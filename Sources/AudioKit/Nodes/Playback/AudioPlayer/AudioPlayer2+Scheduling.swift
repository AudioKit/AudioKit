// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

extension AudioPlayer2 {
    /// Schedule a file or buffer. You can call this to schedule playback in the future
    /// or the player will call it when play() is called to load the audio data
    /// - Parameters:
    ///   - when: What time to schedule for
    public func schedule(at when: AVAudioTime? = nil) {
        if isBuffered, let buffer = buffer {
            playerNode.scheduleBuffer(buffer,
                                      at: nil,
                                      options: bufferOptions,
                                      completionCallbackType: .dataPlayedBack) { callbackType in
                self.internalCompletionHandler()
            }
            scheduleTime = when ?? AVAudioTime.now()

        } else if let file = file {
            playerNode.scheduleFile(file,
                                    at: when,
                                    completionCallbackType: .dataPlayedBack) { callbackType in
                self.internalCompletionHandler()
            }
            scheduleTime = when ?? AVAudioTime.now()

        } else {
            Log("The player needs a file or a valid buffer to schedule", type: .error)
            scheduleTime = nil
        }
    }
}
