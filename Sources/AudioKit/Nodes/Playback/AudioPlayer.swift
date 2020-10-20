// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Wrapper for AVAudioPlayerNode.
public class AudioPlayer: Node, Toggleable {
    /// Is player playing?
    public var isStarted: Bool {
        playerNode.isPlaying
    }

    public var volume: AUValue {
        get { playerNode.volume }
        set { playerNode.volume = newValue }
    }

    /// The underlying player node
    public var playerNode = AVAudioPlayerNode()

    /// If sample rate conversion is needed
    public var mixerNode = AVAudioMixerNode()

    /// Initialize audio player
    public init() {
        super.init(avAudioNode: mixerNode)
    }

    override func makeAVConnections() {
        if let engine = mixerNode.engine {
            engine.attach(playerNode)
            engine.connect(playerNode, to: mixerNode, format: nil)
        }
    }

    /// Schedule a file
    /// - Parameters:
    ///   - file: AVAudioFile to schedule
    ///   - when: What time to schedule for
    ///   - completionHandler: Callback on completion
    public func scheduleFile(_ file: AVAudioFile,
                             at when: AVAudioTime?,
                             completionHandler: AVAudioNodeCompletionHandler? = nil) {
        if playerNode.engine == nil {
            Log("🛑 Error: AudioPlayer must be attached before scheduling playback.")
            return
        }
        playerNode.scheduleFile(file, at: when, completionHandler: completionHandler)
    }

    /// Schedule a file from a URL
    /// - Parameters:
    ///   - url: URL for a file to schedule
    ///   - when: What time to schedule for
    ///   - options: Options for looping
    ///   - completionHandler: Callback on completion
    public func scheduleFile(_ url: URL,
                             at when: AVAudioTime?,
                             options: AVAudioPlayerNodeBufferOptions = [],
                             completionHandler: AVAudioNodeCompletionHandler? = nil) {
        if playerNode.engine == nil {
            Log("🛑 Error: AudioPlayer must be attached before scheduling playback.")
            return
        }

        do {
            let file = try AVAudioFile(forReading: url)
            guard let buffer = try AVAudioPCMBuffer(file: file) else {
                Log("🛑 Error: AVAudioPCMBuffer could not be initialized from file.")
                return
            }

            playerNode.scheduleBuffer(buffer,
                                      at: when,
                                      options: options,
                                      completionHandler: completionHandler)
        } catch {
            fatalError("Failed to schedule file at \(url): \(error)")
        }
    }

    /// Schedule a buffer
    /// - Parameters:
    ///   - buffer: PCM Buffer
    ///   - when: What time to schedule for
    ///   - options: Options for looping
    ///   - completionHandler: Callbackk on completion
    public func scheduleBuffer(_ buffer: AVAudioPCMBuffer,
                               at when: AVAudioTime?,
                               options: AVAudioPlayerNodeBufferOptions = [],
                               completionHandler: AVAudioNodeCompletionHandler? = nil) {
        if playerNode.engine == nil {
            Log("🛑 Error: AudioPlayer must be attached before scheduling playback.")
            return
        }
        playerNode.scheduleBuffer(buffer,
                                  at: when,
                                  options: options,
                                  completionHandler: completionHandler)
    }

    /// Play audio player
    public func play() {
        playerNode.play()
    }

    /// Start audio player
    public func start() {
        playerNode.play()
    }

    /// Stop audio player
    public func stop() {
        playerNode.stop()
    }

    /// Pause audio player
    public func pause() {
        playerNode.pause()
    }

}
