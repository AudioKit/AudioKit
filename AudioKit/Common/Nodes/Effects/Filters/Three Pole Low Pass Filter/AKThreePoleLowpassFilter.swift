//
//  AKThreePoleLowpassFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// 3-pole (18 db/oct slope) Low-Pass filter with resonance and tanh distortion.
///
/// - parameter input: Input node to process
/// - parameter distortion: Distortion amount.  Zero gives a clean output. Greater than zero adds tanh distortion controlled by the filter parameters, in such a way that both low cutoff and high resonance increase the distortion amount.
/// - parameter cutoffFrequency: Filter cutoff frequency in Hertz.
/// - parameter resonance: Resonance. Usually a value in the range 0-1. A value of 1.0 will self oscillate at the cutoff frequency. Values slightly greater than 1 are possible for more sustained oscillation and an “overdrive” effect.
///
public class AKThreePoleLowpassFilter: AKNode, AKToggleable {

    // MARK: - Properties

    internal var internalAU: AKThreePoleLowpassFilterAudioUnit?
    internal var token: AUParameterObserverToken?

    private var distortionParameter: AUParameter?
    private var cutoffFrequencyParameter: AUParameter?
    private var resonanceParameter: AUParameter?
    
    /// Inertia represents the speed at which parameters are allowed to change
    public var inertia: Double = 0.0002 {
        willSet(newValue) {
            if inertia != newValue {
                internalAU?.inertia = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// Distortion amount.  Zero gives a clean output. Greater than zero adds tanh distortion controlled by the filter parameters, in such a way that both low cutoff and high resonance increase the distortion amount.
    public var distortion: Double = 0.5 {
        willSet(newValue) {
            if distortion != newValue {
                distortionParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }
    /// Filter cutoff frequency in Hertz.
    public var cutoffFrequency: Double = 1500 {
        willSet(newValue) {
            if cutoffFrequency != newValue {
                cutoffFrequencyParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }
    /// Resonance. Usually a value in the range 0-1. A value of 1.0 will self oscillate at the cutoff frequency. Values slightly greater than 1 are possible for more sustained oscillation and an “overdrive” effect.
    public var resonance: Double = 0.5 {
        willSet(newValue) {
            if resonance != newValue {
                resonanceParameter?.setValue(Float(newValue), originator: token!)
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
    /// - parameter distortion: Distortion amount.  Zero gives a clean output. Greater than zero adds tanh distortion controlled by the filter parameters, in such a way that both low cutoff and high resonance increase the distortion amount.
    /// - parameter cutoffFrequency: Filter cutoff frequency in Hertz.
    /// - parameter resonance: Resonance. Usually a value in the range 0-1. A value of 1.0 will self oscillate at the cutoff frequency. Values slightly greater than 1 are possible for more sustained oscillation and an “overdrive” effect.
    ///
    public init(
        _ input: AKNode,
        distortion: Double = 0.5,
        cutoffFrequency: Double = 1500,
        resonance: Double = 0.5) {

        self.distortion = distortion
        self.cutoffFrequency = cutoffFrequency
        self.resonance = resonance

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x6c703138 /*'lp18'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKThreePoleLowpassFilterAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKThreePoleLowpassFilter",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKThreePoleLowpassFilterAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        distortionParameter      = tree.valueForKey("distortion")      as? AUParameter
        cutoffFrequencyParameter = tree.valueForKey("cutoffFrequency") as? AUParameter
        resonanceParameter       = tree.valueForKey("resonance")       as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.distortionParameter!.address {
                    self.distortion = Double(value)
                } else if address == self.cutoffFrequencyParameter!.address {
                    self.cutoffFrequency = Double(value)
                } else if address == self.resonanceParameter!.address {
                    self.resonance = Double(value)
                }
            }
        }
        distortionParameter?.setValue(Float(distortion), originator: token!)
        cutoffFrequencyParameter?.setValue(Float(cutoffFrequency), originator: token!)
        resonanceParameter?.setValue(Float(resonance), originator: token!)
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
