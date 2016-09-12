//
//  AKBitCrusher.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// This will digitally degrade a signal.
///
/// - Parameters:
///   - input: Input node to process
///   - bitDepth: The bit depth of signal output. Typically in range (1-24). Non-integer values are OK.
///   - sampleRate: The sample rate of signal output.
///
public class AKBitCrusher: AKNode, AKToggleable {

    // MARK: - Properties

    internal var internalAU: AKBitCrusherAudioUnit?
    internal var token: AUParameterObserverToken?

    private var bitDepthParameter: AUParameter?
    private var sampleRateParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    public var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// The bit depth of signal output. Typically in range (1-24). Non-integer values are OK.
    public var bitDepth: Double = 8 {
        willSet {
            if bitDepth != newValue {
                if internalAU!.isSetUp() {
                    bitDepthParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.bitDepth = Float(newValue)
                }
            }
        }
    }
    /// The sample rate of signal output.
    public var sampleRate: Double = 10000 {
        willSet {
            if sampleRate != newValue {
                if internalAU!.isSetUp() {
                    sampleRateParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.sampleRate = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this bitcrusher node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - bitDepth: The bit depth of signal output. Typically in range (1-24). Non-integer values are OK.
    ///   - sampleRate: The sample rate of signal output.
    ///
    public init(
        _ input: AKNode,
        bitDepth: Double = 8,
        sampleRate: Double = 10000) {

        self.bitDepth = bitDepth
        self.sampleRate = sampleRate

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = fourCC("btcr")
        description.componentManufacturer = fourCC("AuKt")
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKBitCrusherAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKBitCrusher",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKBitCrusherAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        bitDepthParameter   = tree.valueForKey("bitDepth")   as? AUParameter
        sampleRateParameter = tree.valueForKey("sampleRate") as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.bitDepthParameter!.address {
                    self.bitDepth = Double(value)
                } else if address == self.sampleRateParameter!.address {
                    self.sampleRate = Double(value)
                }
            }
        }

        internalAU?.bitDepth = Float(bitDepth)
        internalAU?.sampleRate = Float(sampleRate)
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
