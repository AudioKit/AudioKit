//
//  AKAudioPlayer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Simple audio playback class
public class AKAudioPlayer: AKNode, AKToggleable {
    
    private var audioFileBuffer: AVAudioPCMBuffer
    private var internalPlayer: AVAudioPlayerNode
    private var audioFile: AVAudioFile
    
    private var internalFile: String
    private var sampleRate: Double = 1.0
    private var totalFrameCount: Int64
    private var initialFrameCount: Int64 = -1
    private var skippedToTime: Double
    
    /// Boolean indicating whether or not to loop the playback
    public var looping = false
    private var paused = false
    
    /// Total duration of one loop through of the file
    public var duration: Double {
        return Double(totalFrameCount) / Double(sampleRate)
    }
    
    /// Output Volume (Default 1)
    public var volume: Double = 1.0 {
        didSet {
            if volume < 0 {
                volume = 0
            }
            internalPlayer.volume = Float(volume)
        }
    }
    
    /// Time within the audio file at the current time
    public var playhead: Double {
        if looping {
            return currentTime % duration
        } else {
            if currentTime > duration {
                return duration
            } else {
                return currentTime
            }
        }
    }
    
    /// Pan (Default Center = 0)
    public var pan: Double = 0.0 {
        didSet {
            if pan < -1 {
                pan = -1
            }
            if pan > 1 {
                pan = 1
            }
            internalPlayer.pan = Float(pan)
        }
    }
    
    /// Whether or not the audio player is currently playing
    public var isStarted: Bool {
        return  internalPlayer.playing
    }
    
    /// Initialize the player
    ///
    /// - parameter file: Path to the audio file
    ///
    public init(_ file: String) {
        internalFile = file
        let url = NSURL.fileURLWithPath(file, isDirectory: false)
        audioFile = try! AVAudioFile(forReading: url)
        let audioFormat = audioFile.processingFormat
        let audioFrameCount = UInt32(audioFile.length)
        audioFileBuffer = AVAudioPCMBuffer(PCMFormat: audioFormat,
                                           frameCapacity: audioFrameCount)
        try! audioFile.readIntoBuffer(audioFileBuffer)
        
        // added for currentTime calculation later on
        sampleRate = audioFile.fileFormat.sampleRate
        totalFrameCount = Int64(audioFrameCount)
        skippedToTime = 0
        
        internalPlayer = AVAudioPlayerNode()
        super.init()
        AudioKit.engine.attachNode(internalPlayer)
        
        let mixer = AVAudioMixerNode()
        AudioKit.engine.attachNode(mixer)
        AudioKit.engine.connect(internalPlayer, to: mixer, format: audioFormat)
        self.avAudioNode = mixer

        internalPlayer.scheduleBuffer(
            audioFileBuffer,
            atTime: nil,
            options: .Loops,
            completionHandler: nil)
        internalPlayer.volume = 1.0
    }
    
    /// Reload the file from the disk
    public func reloadFile() {
        let url = NSURL.fileURLWithPath(internalFile, isDirectory: false)
        let audioFile = try! AVAudioFile(forReading: url)
        let audioFormat = audioFile.processingFormat
        let audioFrameCount = UInt32(audioFile.length)
        audioFileBuffer = AVAudioPCMBuffer(PCMFormat: audioFormat,
                                           frameCapacity: audioFrameCount)
        try! audioFile.readIntoBuffer(audioFileBuffer)
    }
    
    /// Start playback
    public func start() {
        if (!internalPlayer.playing && !paused) || playhead == duration {
            var options = AVAudioPlayerNodeBufferOptions.Interrupts
            if looping {
                options = .Loops
            }
            internalPlayer.scheduleBuffer(
                audioFileBuffer,
                atTime: nil,
                options: options,
                completionHandler: nil)
        }
        
        internalPlayer.play()
        // get the initialFrameCount for currentTime as it's relative to the audio engine's time.
        if initialFrameCount == -1 {
            resetFrameCount()
        }
    }
    
    /// Pause playback
    public func pause() {
        paused = true
        internalPlayer.pause()
    }

    /// Stop playback
    public func stop() {
        internalPlayer.stop()
        resetFrameCount()
    }
    
    func resetFrameCount() {
        if let t = internalPlayer.lastRenderTime {
            initialFrameCount = t.sampleTime
        }
    }
    
    /// Current playback time (in seconds)
    public var currentTime: Double {
        
        if internalPlayer.playing {
            if let nodeTime = internalPlayer.lastRenderTime,
                let playerTime = internalPlayer.playerTimeForNodeTime(nodeTime) {
                return Double( Double( playerTime.sampleTime ) / playerTime.sampleRate ) + skippedToTime
            }
        }
        
        return skippedToTime
    }
    
    /// Play the file back from a certain time (non-looping)
    ///
    /// - parameter time: Time into the file at which to start playing back
    ///
    public func playFrom(time: Double) {
        internalPlayer.stop()
        skippedToTime = time
        let startingFrame = Int64(sampleRate * time)
        let frameCount = UInt32(totalFrameCount - startingFrame)
        internalPlayer.prepareWithFrameCount(frameCount)
        internalPlayer.scheduleSegment(
            audioFile,
            startingFrame: startingFrame,
            frameCount: frameCount,
            atTime: nil,
            completionHandler: nil)
        internalPlayer.play()
    }
    
    /// Replace the current audio file with a new audio file
    public func replaceFile(newFile: String) {
        internalFile = newFile
        reloadFile()
    }
    
}
