//
//  AKFrequencyTracker.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// This is based on an algorithm originally created by Miller Puckette.
///
open class AKFrequencyTracker: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKFrequencyTrackerAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "ptrk")

    // MARK: - Properties

    fileprivate var internalAU: AKAudioUnitType?

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    /// Detected Amplitude (Use AKAmplitude tracker if you don't need frequency)
    @objc open dynamic var amplitude: Double {
        return Double(internalAU?.amplitude ?? 0) / Double(AKSettings.channelCount)
    }

    /// Detected frequency
    @objc open dynamic var frequency: Double {
        return Double(internalAU?.frequency ?? 0) * Double(AKSettings.channelCount)
    }

    // MARK: - Initialization

    /// Initialize this Pitch-tracker node
    ///
    /// - parameter input: Input node to process
    /// - parameter hopSize: Hop size.
    /// - parameter peakCount: Number of peaks.
    ///
    @objc public init(
        _ input: AKNode? = nil,
        hopSize: Int = 4_096,
        peakCount: Int = 20) {

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
            strongSelf.avAudioUnit = avAudioUnit
            strongSelf.avAudioNode = avAudioUnit
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.connect(to: strongSelf)
        }
        internalAU?.setPeakCount(UInt32(peakCount))
        internalAU?.setHopSize(UInt32(hopSize))
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        internalAU?.stop()
    }
}
