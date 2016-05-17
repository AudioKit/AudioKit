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
    
    private var audioFileBuffer: AVAudioPCMBuffer?
    private var internalPlayer: AVAudioPlayerNode
    private var audioFile: AVAudioFile?
    
    private var internalFile: String
    private var sampleRate: Double = 1.0
    private var totalFrameCount: Int64 = 0
    private var initialFrameCount: Int64 = -1
    private var skippedToTime: Double = 0
    
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
        internalPlayer = AVAudioPlayerNode()
        super.init()
        reloadFile()
        AudioKit.engine.attachNode(internalPlayer)
        
        let mixer = AVAudioMixerNode()
        AudioKit.engine.attachNode(mixer)
        AudioKit.engine.connect(internalPlayer, to: mixer, format: AudioKit.format)
        self.avAudioNode = mixer
        
        internalPlayer.scheduleBuffer(
            audioFileBuffer!,
            atTime: nil,
            options: .Loops,
            completionHandler: nil)
        internalPlayer.volume = 1.0
        
    }
    
    /// Start playback
    public func start() {
        if (!internalPlayer.playing && !paused) || playhead == duration {
            var options = AVAudioPlayerNodeBufferOptions.Interrupts
            if looping {
                options = .Loops
            }
            internalPlayer.scheduleBuffer(
                audioFileBuffer!,
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
            audioFile!,
            startingFrame: startingFrame,
            frameCount: frameCount,
            atTime: nil,
            completionHandler: nil)
        internalPlayer.play()
    }
    
    /// Replace the current audio file with a new audio file
    ///
    /// - parameter newFile: Path to the new audiofile
    public func replaceFile(newFile: String) {
        internalFile = newFile
        reloadFile()
    }
    
    /// Reload the file from the disk
    public func reloadFile() {
        let url = NSURL.fileURLWithPath(internalFile, isDirectory: false)
        do {
            audioFile = try AVAudioFile(forReading: url)
        } catch {
            print("Could not load audio file.")
            return
        }
        if let actualAudioFile = audioFile {
            let audioFrameCount = UInt32(actualAudioFile.length)
            if audioFrameCount == 0 {
                print("No Audio to load.")
                return
            }
            audioFileBuffer = AVAudioPCMBuffer(PCMFormat: AudioKit.format,
                                               frameCapacity: audioFrameCount)

            do {
                try actualAudioFile.readIntoBuffer(audioFileBuffer!)
            } catch {
                print("Could not read data into buffer.")
                return
            }
            
            // added for currentTime calculation later on
            sampleRate = actualAudioFile.fileFormat.sampleRate
            totalFrameCount = Int64(audioFrameCount)
        }

    }
}
