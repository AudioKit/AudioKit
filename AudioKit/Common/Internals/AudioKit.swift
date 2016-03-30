//
//  AudioKit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Top level AudioKit managing class
@objc public class AudioKit : NSObject {
    
    // MARK: Global audio format (44.1K, Stereo)
    
    /// Format of AudioKit Nodes
    public static let format = AKSettings.audioFormat

    // MARK: - Internal audio engine mechanics
    
    /// Reference to the AV Audio Engine
    public static let engine = AVAudioEngine()
    
    static var shouldBeRunning = false
    
    /// An audio output operation that most applications will need to use last
    public static var output: AKNode? {
        didSet {
            engine.connect(output!.avAudioNode, to: engine.outputNode, format: AudioKit.format)
        }
    }
    
    /// Start up the audio engine
    public static func start() {
        // Start the engine.
        do {
            self.engine.prepare()
            #if !os(OSX)
                if AKSettings.audioInputEnabled {
                    if AKSettings.defaultToSpeaker {
                        
                        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions:AVAudioSessionCategoryOptions.DefaultToSpeaker)
                        
                        // listen to AVAudioEngineConfigurationChangeNotification
                        // and restart the engine if it's stopped.
                        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AudioKit.audioEngineConfigurationChange(_:)), name: AVAudioEngineConfigurationChangeNotification, object: engine)
                        
                        //print("current route (after force speaker): \(AVAudioSession.sharedInstance().currentRoute)")
                        
                    } else {
                        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
                        
                    }
                    
                } else if AKSettings.playbackWhileMuted {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                } else {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
                }
                try AVAudioSession.sharedInstance().setActive(true)
                
                try self.engine.start()
                
            #endif
        } catch {
            fatalError("Could not start engine. error: \(error).")
        }
        shouldBeRunning = true
    }
    
    /// Stop the audio engine
    public static func stop() {
        // Stop the engine.
        self.engine.stop()
        shouldBeRunning = false
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("couldn't stop session \(error)")
        }
    }
    
    // MARK: Testing
    
    /// Testing AKNode
    public static var tester: AKTester?

    /// Test the output of a given node
    ///
    /// - parameter node: AKNode to test
    /// - parameter samples: Number of samples to generate in the test
    ///
    public static func testOutput(node: AKNode, samples: Int) {
        tester = AKTester(node, samples: samples)
        output = tester
    }
    
    // Listen to changes in audio configuration 
    // and restart the audio engine if it stops and should be playing
    @objc private static func audioEngineConfigurationChange(notification: NSNotification) -> Void {
        
        if (shouldBeRunning == true && self.engine.running == false){
            do {
                try self.engine.start()
            } catch {
                print("couldn't start engine after configuration change \(error)")
            }
        }

    }
    
}
