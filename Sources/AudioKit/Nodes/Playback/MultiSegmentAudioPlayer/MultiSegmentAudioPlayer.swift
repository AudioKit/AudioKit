// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// audio player that can schedule many file segments
public class MultiSegmentAudioPlayer: Node {
    /// Nodes providing input to this node.
    public var connections: [Node] { [] }
    
    /// The underlying player node
    public private(set) var playerNode = AVAudioPlayerNode()

    /// The output of the AudioPlayer and provides sample rate conversion if needed
    public private(set) var mixerNode = AVAudioMixerNode()
    
    /// The internal AVAudioEngine AVAudioNode
    public var avAudioNode: AVAudioNode { return mixerNode }
    
    /// Just the playerNode's property, values above 1 will have gain applied
    public var volume: AUValue {
        get { playerNode.volume }
        set { playerNode.volume = newValue }
    }
    
    var engine: AVAudioEngine? { mixerNode.engine }
    
    public init() {}
    
    /// starts the player
    public func play() {
        playerNode.play()
    }
    
    /// stops the player
    public func stop() {
        playerNode.stop()
    }
    
    /// schedules an array of segments of audio files and then starts the player
    /// - Parameters:
    ///     - audioSegments: segments of audio files to be scheduled for playback
    ///     - referenceTimeStamp: time to schedule against (think global time / timeline location / studio time)
    ///     - referenceNowTime: used to share a single now time between many players
    ///     - processingDelay: used to allow many players to process the scheduling of segments and then play in sync
    public func playSegments(audioSegments: [StreamableAudioSegment],
                             referenceTimeStamp: TimeInterval = 0,
                             referenceNowTime: AVAudioTime? = nil,
                             processingDelay: TimeInterval = 0) {
        scheduleSegments(audioSegments: audioSegments,
                         referenceTimeStamp: referenceTimeStamp,
                         referenceNowTime: referenceNowTime,
                         processingDelay: processingDelay)
        play()
    }
    
    /// schedules an array of segments of audio files for playback
    /// - Parameters:
    ///     - audioSegments: segments of audio files to be scheduled for playback
    ///     - referenceTimeStamp: time to schedule against (think global time / timeline location / studio time)
    ///     - referenceNowTime: used to share a single now time between many players
    ///     - processingDelay: used to allow many players to process the scheduling of segments and then play in sync
    /// - Description:
    ///     - the segments must be sorted by their playbackStartTime in chronological order
    ///     - this has not been tested on overlapped segments (any most likely does not work for this use case)
    public func scheduleSegments(audioSegments: [StreamableAudioSegment],
                                 referenceTimeStamp: TimeInterval = 0,
                                 referenceNowTime: AVAudioTime? = nil,
                                 processingDelay: TimeInterval = 0) {
        // will not schedule if the engine is not running or if the node is disconnected
        guard let lastRenderTime = playerNode.lastRenderTime else { return }

        for segment in audioSegments {
            let sampleTime = referenceNowTime ?? AVAudioTime.sampleTimeZero(sampleRate: lastRenderTime.sampleRate)

            // how long the file will be playing back for in seconds
            let durationToSchedule = segment.fileEndTime - segment.fileStartTime
            
            let endTimeWithRespectToReference = segment.playbackStartTime + durationToSchedule
            
            if endTimeWithRespectToReference <= referenceTimeStamp { continue } // skip the clip if it's already past

            // either play right away or schedule for a future time to begin playback
            var whenToPlay = sampleTime.offset(seconds: processingDelay)
            
            // the specific location in the audio file we will start playing from
            var fileStartTime = segment.fileStartTime
            
            if segment.playbackStartTime > referenceTimeStamp {
                // there's space before we should start playing
                let offsetSeconds = segment.playbackStartTime - referenceTimeStamp
                whenToPlay = whenToPlay.offset(seconds: offsetSeconds)
            } else {
                // adjust for playing somewhere in the middle of a segment
                fileStartTime = segment.fileStartTime + referenceTimeStamp - segment.playbackStartTime
            }
            
            // skip if invalid sample rate or fileStartTime (prevents crash)
            let sampleRate = segment.audioFile.fileFormat.sampleRate
            guard sampleRate.isFinite else { continue }
            guard fileStartTime.isFinite else { continue }

            let fileLengthInSamples = segment.audioFile.length
            let startFrame = AVAudioFramePosition(fileStartTime * sampleRate)
            let endFrame = AVAudioFramePosition(segment.fileEndTime * sampleRate)
            let totalFrames = (fileLengthInSamples - startFrame) - (fileLengthInSamples - endFrame)

            guard totalFrames > 0 else { continue } // skip if invalid number of frames (prevents crash)

            playerNode.scheduleSegment(segment.audioFile,
                                       startingFrame: startFrame,
                                       frameCount: AVAudioFrameCount(totalFrames),
                                       at: whenToPlay,
                                       completionHandler: segment.completionHandler)

            playerNode.prepare(withFrameCount: AVAudioFrameCount(totalFrames))
        }
    }
}

extension MultiSegmentAudioPlayer: HasInternalConnections {
    /// Check if the playerNode is already connected to the mixerNode
    var isPlayerConnectedToMixerNode: Bool {
        var iBus = 0
        let engine = playerNode.engine
        if let engine = engine {
            while iBus < playerNode.numberOfOutputs {
                for playercp in engine.outputConnectionPoints(for: playerNode, outputBus: iBus) where playercp.node == mixerNode {
                    return true
                }
                iBus += 1
            }
        }
        return false
    }

    /// called in the connection chain to attach the playerNode
    public func makeInternalConnections() {
        guard let engine = engine else {
            Log("Engine is nil", type: .error)
            return
        }
        if playerNode.engine == nil {
            engine.attach(playerNode)
        }
        if !isPlayerConnectedToMixerNode {
            engine.connect(playerNode, to: mixerNode, format: nil)
        }
    }
}

public protocol StreamableAudioSegment {
    var audioFile: AVAudioFile { get }
    var playbackStartTime: TimeInterval { get }
    var fileStartTime: TimeInterval { get }
    var fileEndTime: TimeInterval { get }
    var completionHandler: AVAudioNodeCompletionHandler? { get }
}
