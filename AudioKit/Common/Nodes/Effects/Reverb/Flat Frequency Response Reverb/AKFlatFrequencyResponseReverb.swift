//
//  AKFlatFrequencyResponseReverb.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// This filter reiterates the input with an echo density determined by loop
/// time. The attenuation rate is independent and is determined by the
/// reverberation time (defined as the time in seconds for a signal to decay to
/// 1/1000, or 60dB down from its original amplitude).  Output will begin to
/// appear immediately.
///
/// - parameter input: Input node to process
/// - parameter reverbDuration: The duration in seconds for a signal to decay to 1/1000, or 60dB down from its original amplitude.
/// - parameter loopDuration: The loop duration of the filter, in seconds. This can also be thought of as the delay time or “echo density” of the reverberation.
///
public class AKFlatFrequencyResponseReverb: AKNode, AKToggleable {

    // MARK: - Properties

    internal var internalAU: AKFlatFrequencyResponseReverbAudioUnit?
    internal var token: AUParameterObserverToken?

    private var reverbDurationParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    public var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// The duration in seconds for a signal to decay to 1/1000, or 60dB down from its original amplitude.
    public var reverbDuration: Double = 0.5 {
        willSet {
            if reverbDuration != newValue {
                if internalAU!.isSetUp() {
                    reverbDurationParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.reverbDuration = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this reverb node
    ///
    /// - parameter input: Input node to process
    /// - parameter reverbDuration: The duration in seconds for a signal to decay to 1/1000, or 60dB down from its original amplitude.
    /// - parameter loopDuration: The loop duration of the filter, in seconds. This can also be thought of as the delay time or “echo density” of the reverberation.
    ///
    public init(
        _ input: AKNode,
        reverbDuration: Double = 0.5,
        loopDuration: Double = 0.1) {

        self.reverbDuration = reverbDuration

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x616c7073 /*'alps'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKFlatFrequencyResponseReverbAudioUnit.self,
            as: description,
            name: "Local AKFlatFrequencyResponseReverb",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiate(with: description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.auAudioUnit as? AKFlatFrequencyResponseReverbAudioUnit

            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)
            self.internalAU!.setLoopDuration(Float(loopDuration))
        }

        guard let tree = internalAU?.parameterTree else { return }

        reverbDurationParameter = tree.value(forKey: "reverbDuration") as? AUParameter

        token = tree.token {
            address, value in

            DispatchQueue.main.async {
                if address == self.reverbDurationParameter!.address {
                    self.reverbDuration = Double(value)
                }
            }
        }
        internalAU?.reverbDuration = Float(reverbDuration)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        self.internalAU!.stop()
    }
}
