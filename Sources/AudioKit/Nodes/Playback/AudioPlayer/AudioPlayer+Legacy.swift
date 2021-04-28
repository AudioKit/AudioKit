// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

extension AudioPlayer {
    /// Schedule a buffer to play at a a specific time, with options
    /// - Parameters:
    ///   - buffer: Buffer to play
    ///   - when: Time to pay
    ///   - options: Buffer options
    @available(*, deprecated, renamed: "schedule(at:)")
    public func scheduleBuffer(_ buffer: AVAudioPCMBuffer,
                               at when: AVAudioTime?,
                               options: AVAudioPlayerNodeBufferOptions = []) {
        self.buffer = buffer
        isLooping = options == .loops
        schedule(at: when)
    }

    /// Schedule a buffer to play from a URL, at a a specific time, with options
    /// - Parameters:
    ///   - url: URL Location of buffer
    ///   - when: Time to pay
    ///   - options: Buffer options
    @available(*, deprecated, renamed: "schedule(at:)")
    public func scheduleBuffer(url: URL,
                               at when: AVAudioTime?,
                               options: AVAudioPlayerNodeBufferOptions = []) {
        guard let buffer = try? AVAudioPCMBuffer(url: url) else {
            Log("Failed to create buffer", type: .error)
            return
        }
        scheduleBuffer(buffer, at: when, options: options)
    }

    /// Schedule a file to play at a a specific time
    /// - Parameters:
    ///   - file: File to play
    ///   - when: Time to play
    ///   - options: Buffer options
    @available(*, deprecated, renamed: "schedule(at:)")
    public func scheduleFile(_ file: AVAudioFile,
                             at when: AVAudioTime?) {
        self.file = file
        schedule(at: when)
    }
}
