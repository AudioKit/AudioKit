//
//  AKMicrophoneTracker.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 5/9/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

/// An easy to use class to do usual microphone tracking
public class AKMicrophoneTracker {
    
    var engine = AKMicrophoneTrackerEngine()

    /// Tracked amplitude
    public var amplitude: Double {
        return Double(engine.amplitude)
    }

    /// Tracked frquency
    public var frequency: Double {
        return Double(engine.frequency)
    }

    /// Start the analysis
    public func start() {
        engine.start()
    }

    /// Stop the analysis
    public func stop() {
        engine.stop()
    }

    /// Initialize the tracker
    public init() {
        // Could automatically start the tracker here, but elected not to at BlackBox/Ryan McLeod's request
        // Subclass and change this if you like
    }
}
