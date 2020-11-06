// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

extension AudioPlayer2 {

    /// Schedule a file or buffer
    /// - Parameters:
    ///   - when: What time to schedule for
    ///   - completionHandler: Callback on completion
    public func schedule(at when: AVAudioTime? = nil,
                         completionHandler: AVAudioNodeCompletionHandler? = nil) {
        guard playerNode.engine != nil else {
            Log("🛑 Error: AudioPlayer must be attached before scheduling playback.")
            return
        }
        duration = file.duration

        playerNode.scheduleFile(file,
                                at: when,
                                completionCallbackType: .dataPlayedBack) { callbackType in
            completionHandler?()
        }

//        playerNode.scheduleSegment(file,
//                                   startingFrame: 0,
//                                   frameCount: AVAudioFrameCount(file.length),
//                                   at: when,
//                                   completionCallbackType: .dataPlayedBack) { callbackType in
//        }
    }


    public func scheduleBuffer(at when: AVAudioTime? = nil,
                               options: AVAudioPlayerNodeBufferOptions = .interrupts,
                               completionHandler: AVAudioNodeCompletionHandler? = nil) {
        guard playerNode.engine != nil else {
            Log("🛑 Error: AudioPlayer must be attached before scheduling playback.")
            return
        }

        do {
            let file = try AVAudioFile(forReading: url)

            guard let buffer = try AVAudioPCMBuffer(file: file) else {
                Log("🛑 Error: AVAudioPCMBuffer could not be initialized from file.")
                return
            }

            scheduleBuffer(buffer, at: when, options: options, completionHandler: completionHandler)
        } catch {
            Log("Failed to schedule file at \(url): \(error)", type: .error)
        }
    }

    /// Schedule a buffer
    /// - Parameters:
    ///   - buffer: PCM Buffer
    ///   - when: What time to schedule for, nil for now
    ///   - options: Options controlling buffer scheduling
    ///   - completionHandler: Callbackk on completion
    public func scheduleBuffer(_ buffer: AVAudioPCMBuffer,
                               at when: AVAudioTime? = nil,
                               options: AVAudioPlayerNodeBufferOptions = [],
                               completionHandler: AVAudioNodeCompletionHandler? = nil) {
        if playerNode.engine == nil {
            Log("🛑 Error: AudioPlayer must be attached before scheduling playback.")
            return
        }

        duration = TimeInterval(buffer.frameLength) / buffer.format.sampleRate
        playerNode.scheduleBuffer(buffer,
                                  at: when,
                                  options: options,
                                  completionHandler: completionHandler)
    }
}
