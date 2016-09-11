//
//  AKKorgLowPassFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Analogue model of the Korg 35 Lowpass Filter
///
/// - parameter input: Input node to process
/// - parameter cutoffFrequency: Filter cutoff
/// - parameter resonance: Filter resonance (should be between 0-2)
/// - parameter saturation: Filter saturation.
///
public class AKKorgLowPassFilter: AKNode, AKToggleable {

    // MARK: - Properties

    internal var internalAU: AKKorgLowPassFilterAudioUnit?
    internal var token: AUParameterObserverToken?

    private var cutoffFrequencyParameter: AUParameter?
    private var resonanceParameter: AUParameter?
    private var saturationParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    public var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// Filter cutoff
    public var cutoffFrequency: Double = 1000.0 {
        willSet {
            if cutoffFrequency != newValue {
                if internalAU!.isSetUp() {
                    cutoffFrequencyParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.cutoffFrequency = Float(newValue)
                }
            }
        }
    }
    /// Filter resonance (should be between 0-2)
    public var resonance: Double = 1.0 {
        willSet {
            if resonance != newValue {
                if internalAU!.isSetUp() {
                    resonanceParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.resonance = Float(newValue)
                }
            }
        }
    }
    /// Filter saturation.
    public var saturation: Double = 0.0 {
        willSet {
            if saturation != newValue {
                if internalAU!.isSetUp() {
                    saturationParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.saturation = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - parameter input: Input node to process
    /// - parameter cutoffFrequency: Filter cutoff
    /// - parameter resonance: Filter resonance (should be between 0-2)
    /// - parameter saturation: Filter saturation.
    ///
    public init(
        _ input: AKNode,
        cutoffFrequency: Double = 1000.0,
        resonance: Double = 1.0,
        saturation: Double = 0.0) {

        self.cutoffFrequency = cutoffFrequency
        self.resonance = resonance
        self.saturation = saturation

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = fourCC("klpf")
        description.componentManufacturer = fourCC("AuKt")
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKKorgLowPassFilterAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKKorgLowPassFilter",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKKorgLowPassFilterAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        cutoffFrequencyParameter = tree.valueForKey("cutoffFrequency") as? AUParameter
        resonanceParameter       = tree.valueForKey("resonance")       as? AUParameter
        saturationParameter      = tree.valueForKey("saturation")      as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.cutoffFrequencyParameter!.address {
                    self.cutoffFrequency = Double(value)
                } else if address == self.resonanceParameter!.address {
                    self.resonance = Double(value)
                } else if address == self.saturationParameter!.address {
                    self.saturation = Double(value)
                }
            }
        }

        internalAU?.cutoffFrequency = Float(cutoffFrequency)
        internalAU?.resonance = Float(resonance)
        internalAU?.saturation = Float(saturation)
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
