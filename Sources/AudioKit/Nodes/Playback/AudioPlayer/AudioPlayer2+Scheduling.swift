// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

extension AudioPlayer2 {
    /// Schedule a file or buffer
    /// - Parameters:
    ///   - when: What time to schedule for
    ///   - completionHandler: Callback on completion
    public func schedule(at when: AVAudioTime? = nil,
                         completionHandler: AVAudioNodeCompletionHandler? = nil) {

        if buffered, let buffer = buffer {
            playerNode.scheduleBuffer(buffer,
                                      at: nil,
                                      options: .interrupts,
                                      completionCallbackType: .dataPlayedBack) { callbackType in
                completionHandler?()
            }

        } else if let file = file {
            playerNode.scheduleFile(file,
                                    at: when,
                                    completionCallbackType: .dataPlayedBack) { callbackType in
                completionHandler?()
            }
        }

//        playerNode.scheduleSegment(file,
//                                   startingFrame: 0,
//                                   frameCount: AVAudioFrameCount(file.length),
//                                   at: when,
//                                   completionCallbackType: .dataPlayedBack) { callbackType in
//        }
    }

}
