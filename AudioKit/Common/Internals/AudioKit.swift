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
    
    /// An audio output operation that most applications will need to use last
    public static var output: AKNode? {
        didSet {
            engine.connect(output!.avAudioNode, to: engine.outputNode, format: AudioKit.format)
        }
    }
    
    /// Enumerate the list of available input devices.
    public static var availableInputs: [String]?
    {
        #if os(OSX)
            // TODO: Do this in Objective-C
        #else
            if let devices = AVAudioSession.sharedInstance().availableInputs {
                return devices.map({ $0.portName })
            }
        #endif
        return nil
    }

    /// The name of the current preferred input device, if available.
    public static var inputName: String? {
        #if os(OSX)
            return nil // TODO
        #else
            return AVAudioSession.sharedInstance().preferredInput?.portName
        #endif
    }

    /// Change the preferred input device, giving it one of the names from the list of available inputs.
    public static func setInput(inputName: String) throws
    {
        #if os(OSX)
            // TODO
        #else
            if let devices = AVAudioSession.sharedInstance().availableInputs {
                for dev in devices {
                    if dev.portName == inputName {
                        try AVAudioSession.sharedInstance().setPreferredInput(dev)
                    }
                }
            }
        #endif
    }
    
    /// Start up the audio engine
    public static func start() {
        if output == nil {
            NSLog("AudioKit: No output node has been set yet, no processing will happen.")
        }
        // Start the engine.
        do {
            try self.engine.start()
            #if !os(OSX)
                if AKSettings.audioInputEnabled {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
                } else if AKSettings.playbackWhileMuted {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                } else {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
                }
                try AVAudioSession.sharedInstance().setActive(true)
            #endif
        } catch {
            fatalError("AudioKit: Could not start engine. error: \(error).")
        }
    }
    
    /// Stop the audio engine
    public static func stop() {
        // Stop the engine.
        self.engine.stop()
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
}
