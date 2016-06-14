//
//  AKPeakingParametricEqualizerFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// This is an implementation of Zoelzer's parametric equalizer filter.
///
/// - parameter input: Input node to process
/// - parameter centerFrequency: Center frequency.
/// - parameter gain: Amount at which the center frequency value shall be increased or decreased. A value of 1 is a flat response.
/// - parameter q: Q of the filter. sqrt(0.5) is no resonance.
///
public class AKPeakingParametricEqualizerFilter: AKNode, AKToggleable {

    // MARK: - Properties

    internal var internalAU: AKPeakingParametricEqualizerFilterAudioUnit?
    internal var token: AUParameterObserverToken?

    private var centerFrequencyParameter: AUParameter?
    private var gainParameter: AUParameter?
    private var qParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    public var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// Center frequency.
    public var centerFrequency: Double = 1000 {
        willSet {
            if centerFrequency != newValue {
                if internalAU!.isSetUp() {
                    centerFrequencyParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.centerFrequency = Float(newValue)
                }
            }
        }
    }
    /// Amount at which the center frequency value shall be increased or decreased. A value of 1 is a flat response.
    public var gain: Double = 1.0 {
        willSet {
            if gain != newValue {
                if internalAU!.isSetUp() {
                    gainParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.gain = Float(newValue)
                }
            }
        }
    }
    /// Q of the filter. sqrt(0.5) is no resonance.
    public var q: Double = 0.707 {
        willSet {
            if q != newValue {
                if internalAU!.isSetUp() {
                    qParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.q = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this equalizer node
    ///
    /// - parameter input: Input node to process
    /// - parameter centerFrequency: Center frequency.
    /// - parameter gain: Amount at which the center frequency value shall be increased or decreased. A value of 1 is a flat response.
    /// - parameter q: Q of the filter. sqrt(0.5) is no resonance.
    ///
    public init(
        _ input: AKNode,
        centerFrequency: Double = 1000,
        gain: Double = 1.0,
        q: Double = 0.707) {

        self.centerFrequency = centerFrequency
        self.gain = gain
        self.q = q

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x70657130 /*'peq0'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKPeakingParametricEqualizerFilterAudioUnit.self,
            as: description,
            name: "Local AKPeakingParametricEqualizerFilter",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiate(with: description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.auAudioUnit as? AKPeakingParametricEqualizerFilterAudioUnit

            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        centerFrequencyParameter = tree.value(forKey: "centerFrequency") as? AUParameter
        gainParameter            = tree.value(forKey: "gain")            as? AUParameter
        qParameter               = tree.value(forKey: "q")               as? AUParameter

        let observer: AUParameterObserver = {
            address, value in
            
            let executionBlock = {
                if address == self.centerFrequencyParameter!.address {
                    self.centerFrequency = Double(value)
                } else if address == self.gainParameter!.address {
                    self.gain = Double(value)
                } else if address == self.qParameter!.address {
                    self.q = Double(value)
                }
            }
            
            DispatchQueue.main.async(execute: executionBlock)
        }
        
        token = tree.token(byAddingParameterObserver: observer)
        internalAU?.centerFrequency = Float(centerFrequency)
        internalAU?.gain = Float(gain)
        internalAU?.q = Float(q)
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
