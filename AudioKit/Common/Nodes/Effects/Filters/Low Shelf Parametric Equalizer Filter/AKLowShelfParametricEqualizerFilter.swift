//
//  AKLowShelfParametricEqualizerFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// This is an implementation of Zoelzer's parametric equalizer filter.
///
/// - parameter input: Input node to process
/// - parameter cornerFrequency: Corner frequency.
/// - parameter gain: Amount at which the corner frequency value shall be increased or decreased. A value of 1 is a flat response.
/// - parameter q: Q of the filter. sqrt(0.5) is no resonance.
///
public class AKLowShelfParametricEqualizerFilter: AKNode, AKToggleable {

    // MARK: - Properties

    internal var internalAU: AKLowShelfParametricEqualizerFilterAudioUnit?
    internal var token: AUParameterObserverToken?

    private var cornerFrequencyParameter: AUParameter?
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

    /// Corner frequency.
    public var cornerFrequency: Double = 1000 {
        willSet {
            if cornerFrequency != newValue {
                if internalAU!.isSetUp() {
                    cornerFrequencyParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.cornerFrequency = Float(newValue)
                }
            }
        }
    }
    /// Amount at which the corner frequency value shall be increased or decreased. A value of 1 is a flat response.
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
    /// - parameter cornerFrequency: Corner frequency.
    /// - parameter gain: Amount at which the corner frequency value shall be increased or decreased. A value of 1 is a flat response.
    /// - parameter q: Q of the filter. sqrt(0.5) is no resonance.
    ///
    public init(
        _ input: AKNode,
        cornerFrequency: Double = 1000,
        gain: Double = 1.0,
        q: Double = 0.707) {

        self.cornerFrequency = cornerFrequency
        self.gain = gain
        self.q = q

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x70657131 /*'peq1'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKLowShelfParametricEqualizerFilterAudioUnit.self,
            as: description,
            name: "Local AKLowShelfParametricEqualizerFilter",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiate(with: description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.auAudioUnit as? AKLowShelfParametricEqualizerFilterAudioUnit

            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        cornerFrequencyParameter = tree.value(forKey: "cornerFrequency") as? AUParameter
        gainParameter            = tree.value(forKey: "gain")            as? AUParameter
        qParameter               = tree.value(forKey: "q")               as? AUParameter
        
        let observer: AUParameterObserver = {
            address, value in
            
            let executionBlock = {
                if address == self.cornerFrequencyParameter!.address {
                    self.cornerFrequency = Double(value)
                } else if address == self.gainParameter!.address {
                    self.gain = Double(value)
                } else if address == self.qParameter!.address {
                    self.q = Double(value)
                }
            }
            
            DispatchQueue.main.async(execute: executionBlock)
        }
        
        token = tree.token(byAddingParameterObserver: observer)
        internalAU?.cornerFrequency = Float(cornerFrequency)
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
