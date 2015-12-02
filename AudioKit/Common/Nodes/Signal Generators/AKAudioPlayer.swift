//
//  AKAudioPlayer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/5/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Simple audio playback class
public class AKAudioPlayer: AKNode {
    
    private var audioFileBuffer: AVAudioPCMBuffer
    private var internalPlayer: AVAudioPlayerNode
    
    /// Boolean indicating whether or not to loop the playback
    public var looping = false
    
    /// Initialize the player
    public init(_ file: String) {
        let url = NSURL.fileURLWithPath(file, isDirectory: false)
        let audioFile = try! AVAudioFile(forReading: url)
        let audioFormat = audioFile.processingFormat
        let audioFrameCount = UInt32(audioFile.length)
        audioFileBuffer = AVAudioPCMBuffer(PCMFormat: audioFormat, frameCapacity: audioFrameCount)
        try! audioFile.readIntoBuffer(audioFileBuffer)
        
        internalPlayer = AVAudioPlayerNode()
        AKManager.sharedInstance.engine.attachNode(internalPlayer)
        internalPlayer.scheduleBuffer(
            audioFileBuffer,
            atTime: nil,
            options: .Loops,
            completionHandler: nil)
        internalPlayer.volume = 0.3
        super.init()
        output = internalPlayer
        
    }
    
    /// Start playback
    public func play() {
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
}
