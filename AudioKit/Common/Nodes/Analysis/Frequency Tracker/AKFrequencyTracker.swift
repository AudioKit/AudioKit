//
//  AKFrequencyTracker.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// This is based on an algorithm originally created by Miller Puckette.
///
open class AKFrequencyTracker: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKFrequencyTrackerAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "ptrk")

    // MARK: - Properties

    fileprivate var internalAU: AKAudioUnitType?

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    /// Detected Amplitude (Use AKAmplitude tracker if you don't need frequency)
    open dynamic var amplitude: Double {
        return Double(internalAU?.amplitude ?? 0) / 2.0 // Stereo Hack
    }

    /// Detected frequency
    open dynamic var frequency: Double {
        return Double(internalAU?.frequency ?? 0) * 2.0 // Stereo Hack
    }

    // MARK: - Initialization

    /// Initialize this Pitch-tracker node
    ///
    /// - parameter input: Input node to process
    /// - parameter hopSize: Hop size.
    /// - parameter peakCount: Number of peaks.
    ///
    public init(
        _ input: AKNode,
        hopSize: Double = 512,
        peakCount: Double = 20) {

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input.addConnectionPoint(self!)
        }
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU?.stop()
    }
}
