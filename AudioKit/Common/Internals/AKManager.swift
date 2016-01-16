//
//  AKManager.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Top level AudioKit managing class
public class AKManager {
    
    /// Globally accessible singleton
    public static let sharedInstance = AKManager()
    
    // MARK: Global audio format (44.1K, Stereo)
    
    /// Format of AudioKit Nodes
    public static let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)

    // MARK: - Internal audio engine mechanics
    
    /// Reference to the AV Audio Engine
    public var engine = AVAudioEngine()
    
    /// An audio output operation that most applications will need to use last
    public var audioOutput: AKNode? {
        didSet {
            engine.connect(audioOutput!.avAudioNode, to: engine.outputNode, format: AKManager.format)
        }
    }
    
    /// Start up the audio engine
    public func start() {
        // Start the engine.
        do {
            try self.engine.start()
            #if !os(OSX)
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
            #endif
        } catch {
            fatalError("Could not start engine. error: \(error).")
        }
    }
    
    /// Stop the audio engine
    public func stop() {
        // Stop the engine.
        self.engine.stop()
    }
    
    // MARK: Testing
    
    /// Testing AKNode
    public var tester: AKTester?

    /// Test the output of a given node
    ///
    /// - parameter node: AKNode to test
    /// - parameter samples: Number of samples to generate in the test
    ///
    public func testOutput(node: AKNode, samples: Int) {
        tester = AKTester(node, samples: samples)
        audioOutput = tester
    }
}
