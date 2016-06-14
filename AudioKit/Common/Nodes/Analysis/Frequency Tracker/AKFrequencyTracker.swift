//
//  AKFrequencyTracker.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// This tracks the pitch of signal using the 
/// AMDF (Average Magnitude Difference Function) method of pitch following.
public class AKFrequencyTracker: AKNode, AKToggleable {

    // MARK: - Properties

    private var internalAU: AKFrequencyTrackerAudioUnit?
    private var token: AUParameterObserverToken?

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }
    
    /// Detected Amplitude (Use AKAmplitude tracker if you don't need frequency)
    public var amplitude: Double {
        return Double(self.internalAU!.getAmplitude()) / sqrt(2.0) * 2.0
    }
    
    /// Detected frequency
    public var frequency: Double {
        return Double(self.internalAU!.getFrequency()) * 2.0
    }

    // MARK: - Initialization

    /// Initialize this Pitch-detection node 
    ///
    /// - parameter input: Input node to process
    /// - parameter minimumFrequency: Lower bound of frequency detection
    /// - parameter maximumFrequency: Upper bound of frequency detection
    public init(_ input: AKNode, minimumFrequency: Double, maximumFrequency: Double) {

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x616d6466 /*'amdf'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKFrequencyTrackerAudioUnit.self,
            as: description,
            name: "Local AKFrequencyTracker",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiate(with: description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.auAudioUnit as? AKFrequencyTrackerAudioUnit
            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)
            self.internalAU?.setFrequencyLimitsWithMinimum(Float(minimumFrequency/2), maximum: Float(maximumFrequency/2))
        }
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        internalAU!.start()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        internalAU!.stop()
    }
}
