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
    
    /// Inertia represents the speed at which parameters are allowed to change
    public var inertia: Double = 0.0002 {
        willSet(newValue) {
            if inertia != newValue {
                internalAU?.inertia = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// Corner frequency.
    public var cornerFrequency: Double = 1000 {
        willSet(newValue) {
            if cornerFrequency != newValue {
                cornerFrequencyParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }
    /// Amount at which the corner frequency value shall be increased or decreased. A value of 1 is a flat response.
    public var gain: Double = 1.0 {
        willSet(newValue) {
            if gain != newValue {
                gainParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }
    /// Q of the filter. sqrt(0.5) is no resonance.
    public var q: Double = 0.707 {
        willSet(newValue) {
            if q != newValue {
                qParameter?.setValue(Float(newValue), originator: token!)
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
            asComponentDescription: description,
            name: "Local AKLowShelfParametricEqualizerFilter",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKLowShelfParametricEqualizerFilterAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        cornerFrequencyParameter = tree.valueForKey("cornerFrequency") as? AUParameter
        gainParameter            = tree.valueForKey("gain")            as? AUParameter
        qParameter               = tree.valueForKey("q")               as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.cornerFrequencyParameter!.address {
                    self.cornerFrequency = Double(value)
                } else if address == self.gainParameter!.address {
                    self.gain = Double(value)
                } else if address == self.qParameter!.address {
                    self.q = Double(value)
                }
            }
        }
        cornerFrequencyParameter?.setValue(Float(cornerFrequency), originator: token!)
        gainParameter?.setValue(Float(gain), originator: token!)
        qParameter?.setValue(Float(q), originator: token!)
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
