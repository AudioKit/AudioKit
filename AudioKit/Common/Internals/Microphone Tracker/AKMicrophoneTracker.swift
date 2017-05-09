//
//  AKMicrophoneTracker.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 5/9/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

public class AKMicrophoneTracker {
    var engine = AKMicrophoneTrackerEngine()
    
    public var amplitude: Double {
        return Double(engine.amplitude)
    }

    public var frequency: Double {
        return Double(engine.frequency)
    }
    
    public func start() {
        engine.start()
    }

    public func stop() {
        engine.stop()
    }

    public init() {
        // should do start stuff
    }
}
