//
//  AKManager.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/4/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/** Top level AudioKit managing class */
public class AKManager {
    
    /** Globally accessible singleton */
    public static let sharedInstance = AKManager()
    
    public static let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)
    /** Reference to the AV Audio Engine */
    public var engine = AVAudioEngine()
    public var tester: AKTester?
    
    /** An audio output operation that most applications will need to use last */
    public var audioOutput: AKNode? {
        didSet {
            engine.connect(audioOutput!.avAudioNode, to: engine.outputNode, format: AKManager.format)
        }
    }
    
    /** Start up the audio engine */
    public func start() {
        // Start the engine.
        do {
            try self.engine.start()
        } catch {
            fatalError("Could not start engine. error: \(error).")
        }
    }
    
    /** Stop the audio engine */
    public func stop() {
        // Stop the engine.
        self.engine.stop()
    }

    
    public func testOutput(node: AKNode, samples: Int) {
        tester = AKTester(node, samples: samples)
        audioOutput = tester
    }
}
