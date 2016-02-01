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
    
    private var sampleRate : Double = 1.0
    private var totalFrameCount : Int64
    
    /// Boolean indicating whether or not to loop the playback
    public var looping = false
    
    /// Output Volume (Default 1)
    public var volume: Double = 1.0 {
        didSet {
            if volume < 0 {
                volume = 0
            }
            internalPlayer.volume = Float(volume)
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
        let url = NSURL.fileURLWithPath(file, isDirectory: false)
        let audioFile = try! AVAudioFile(forReading: url)
        let audioFormat = audioFile.processingFormat
        let audioFrameCount = UInt32(audioFile.length)
        audioFileBuffer = AVAudioPCMBuffer(PCMFormat: audioFormat, frameCapacity: audioFrameCount)
        try! audioFile.readIntoBuffer(audioFileBuffer)
        // added for currentTime calculation later on
        sampleRate = audioFile.fileFormat.sampleRate
        totalFrameCount = Int64( audioFrameCount )
        
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
    
    /// Start playback
    public func start() {
        if !internalPlayer.playing {
            var options: AVAudioPlayerNodeBufferOptions = AVAudioPlayerNodeBufferOptions.Interrupts
            if looping {
                options = .Loops
            }
            internalPlayer.scheduleBuffer(audioFileBuffer, atTime: nil, options: options, completionHandler: nil)
        }
        internalPlayer.play()
    }
    
    /// Pause playback
    public func pause() {
        internalPlayer.pause()
    }

    /// Stop playback
    public func stop() {
        internalPlayer.stop()
    }
    
    // The currentTime
    public var currentTime : Double {
        
        if internalPlayer.playing {
            if let time = internalPlayer.lastRenderTime {
                // wrap the sampleTime by the totalFrameCount as sampleTime does not reset when audio loops.
                return Double( ( Int64(time.sampleTime) % totalFrameCount) ) / sampleRate
            }
        }
        return 0.0
    }
}
