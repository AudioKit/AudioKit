//
//  AKMicrophoneTracker.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// An easy to use class to do usual microphone tracking
public class AKMicrophoneTracker {

    private let microphone: AKMicrophone
    private let tracker: AKFrequencyTracker

    /// Tracked amplitude
    public var amplitude: Double {
        return tracker.amplitude
    }

    /// Tracked frquency
    public var frequency: Double {
        return tracker.frequency
    }

    /// Initialize the tracker
    @objc public init(hopSize: Int = 4_096, peakCount: Int = 20) {
        tracker = AKFrequencyTracker(hopSize: hopSize, peakCount: peakCount)
        microphone = AKMicrophone()
        microphone.connect(to: tracker)
    }
}

extension AKMicrophoneTracker: AKOutput {

    public var outputNode: AVAudioNode {
        return tracker.avAudioNode
    }
}

extension AKMicrophoneTracker: AKToggleable {

    public var isStarted: Bool {
        return microphone.isStarted && tracker.isStarted
    }

    public func start() {
        microphone.start()
        tracker.start()
    }

    public func stop() {
        microphone.stop()
        tracker.stop()
    }

}
