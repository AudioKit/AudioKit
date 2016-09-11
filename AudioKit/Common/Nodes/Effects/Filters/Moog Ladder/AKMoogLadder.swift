//
//  AKMoogLadder.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Moog Ladder is an new digital implementation of the Moog ladder filter based
/// on the work of Antti Huovilainen, described in the paper "Non-Linear Digital
/// Implementation of the Moog Ladder Filter" (Proceedings of DaFX04, Univ of
/// Napoli). This implementation is probably a more accurate digital
/// representation of the original analogue filter.
///
/// - Parameters:
///   - input: Input node to process
///   - cutoffFrequency: Filter cutoff frequency.
///   - resonance: Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1.
///
public class AKMoogLadder: AKNode, AKToggleable {

    // MARK: - Properties

    internal var internalAU: AKMoogLadderAudioUnit?
    internal var token: AUParameterObserverToken?

    private var cutoffFrequencyParameter: AUParameter?
    private var resonanceParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    public var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// Filter cutoff frequency.
    public var cutoffFrequency: Double = 1000 {
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
    /// Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1.
    public var resonance: Double = 0.5 {
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

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cutoffFrequency: Filter cutoff frequency.
    ///   - resonance: Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1.
    ///
    public init(
        _ input: AKNode,
        cutoffFrequency: Double = 1000,
        resonance: Double = 0.5) {

        self.cutoffFrequency = cutoffFrequency
        self.resonance = resonance

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = fourCC("mgld")
        description.componentManufacturer = fourCC("AuKt")
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKMoogLadderAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKMoogLadder",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKMoogLadderAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        cutoffFrequencyParameter = tree.valueForKey("cutoffFrequency") as? AUParameter
        resonanceParameter       = tree.valueForKey("resonance")       as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.cutoffFrequencyParameter!.address {
                    self.cutoffFrequency = Double(value)
                } else if address == self.resonanceParameter!.address {
                    self.resonance = Double(value)
                }
            }
        }

        internalAU?.cutoffFrequency = Float(cutoffFrequency)
        internalAU?.resonance = Float(resonance)
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
