//
//  AKAudioPlayer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/5/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

public class AKAudioPlayer: AKOperation {
    
    private var audioFile: AVAudioFile
    private var internalPlayer: AVAudioPlayerNode
    
    public init(_ file: String) {
        let url = NSURL.fileURLWithPath(file, isDirectory: false)
        audioFile = try! AVAudioFile(forReading: url)
        print(audioFile.url)
        internalPlayer = AVAudioPlayerNode()
        AKManager.sharedInstance.engine.attachNode(internalPlayer)
        internalPlayer.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        internalPlayer.volume = 0.3
        super.init()
        output = internalPlayer
        
    }
    
    
    public func play() {
        if !internalPlayer.playing {
            internalPlayer.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        }
        internalPlayer.play()
    }
    
    public func pause() {
        internalPlayer.pause()
    }

    
    public func stop() {
        internalPlayer.stop()
    }

}