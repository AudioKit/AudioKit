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
    
    /** Reference to the AV Audio Engine */
    public var engine = AVAudioEngine()

    public var test: UnsafeMutablePointer<sp_test> = nil
    public var isTesting = false
    
    /** An audio output operation that most applications will need to use last */
    public var audioOutput: AKOperation? {
        didSet {
            engine.connect(audioOutput!.output!, to: engine.outputNode, format: nil)
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
    
    public func testOutput(operation: AKOperation, samples: Int) {
        isTesting = true
        sp_test_create(&test, 44100)
        let tester = AKTester(operation, samples: samples)
    }
}
