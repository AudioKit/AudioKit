//
//  AKMicrophoneTracker.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// An easy to use class to do usual microphone tracking
public class AKMicrophoneTracker {

    var engine: AKMicrophoneTrackerEngine

    /// Tracked amplitude
    public var amplitude: Double {
        return Double(engine.amplitude)
    }

    /// Tracked frequency
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
    @objc public init(hopSize: Int = 4_096, peakCount: Int = 20) {
        engine = AKMicrophoneTrackerEngine(hopSize: UInt32(hopSize), peakCount: UInt32(peakCount))
        // Could automatically start the tracker here, but elected not to at BlackBox/Ryan McLeod's request
        // Subclass and change this if you like
    }
}
